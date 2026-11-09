import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mastery300_curriculum.dart';
import '../../data/sprint_references.dart';
import '../../domain/lesson.dart';
import '../../ui/looploom_theme.dart';
import '../../ui/save_status.dart';
import '../../ui/code_workspace.dart';
import '../../ui/readable_surface.dart';
import 'firebase_ai_coach_provider.dart';
import 'session_controller.dart';

enum _OfflineCoachAction { clarify, example, edgeCase, selfCheck, nextHint }

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.session, required this.store});
  final SessionController session;
  final PracticeStore store;
  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final composer = TextEditingController();
  final editor = TextEditingController();
  final scroll = ScrollController();
  final questionKey = GlobalKey();
  final checkpointKey = GlobalKey();
  bool get focusView => session.focusView;
  SessionController get session => widget.session;
  @override
  void initState() {
    super.initState();
    editor.text = session.draft;
    composer.text = session.reasoningDraft;
  }

  @override
  void dispose() {
    unawaited(widget.store.flush());
    composer.dispose();
    editor.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> reveal() async {
    if (session.solutionRevealed) {
      await _showGuidance('Solution explanation', session.lesson.explanation);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reveal the explanation?'),
        content: const Text(
          'Keep learning at your own pace. This attempt will record that you viewed the solution.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep thinking'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reveal explanation'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      session.revealSolution();
      unawaited(widget.store.flush());
      await _showGuidance('Solution explanation', session.lesson.explanation);
    }
  }

  Future<void> _showGuidance(String title, String guidance) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(title)),
            IconButton(
              tooltip: 'Close guidance',
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * .6,
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              guidance,
              style: const TextStyle(fontSize: 16, height: 1.65),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'Saved in your session notes',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('I understand'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNextHint() async {
    if (session.hintsUsed >= session.lesson.hints.length) return;
    session.requestHint();
    unawaited(widget.store.flush());
    await _showGuidance('Your next hint', session.messages.last.text);
  }

  void advance() {
    session.advanceAfterSelfCheck();
    unawaited(widget.store.flush());
    composer.text = session.reasoningDraft;
    revealTarget(questionKey);
  }

  void _saveCodeForSelfReview() {
    FocusScope.of(context).unfocus();
    session.submit(editor.text);
    unawaited(widget.store.flush());
    revealTarget(checkpointKey);
  }

  void _reviseThinking() {
    final saved = session.answerForReview;
    composer.text = saved;
    session.saveReasoningDraft(saved);
    revealTarget(questionKey);
  }

  void _reviseCode() {
    session.saveDraft(session.draft);
    revealTarget(questionKey);
  }

  Future<bool> _confirmAiConsent() async {
    if (session.coach is! FirebaseAiCoachProvider) return true;
    if (widget.store.preferences.aiCoachConsent) return true;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Allow Gemini to review this answer?'),
        content: const Text(
          'When you choose Ask AI, this answer and a short problem context are sent to Google Gemini. LoopLoom does not upload practice in the background. Gemini’s free tier may use submitted content to improve Google products. Avoid personal or confidential information. The AI cannot run or verify your code.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Allow and ask AI'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return false;
    try {
      await widget.store.updatePreferences(
        widget.store.preferences.copyWith(aiCoachConsent: true),
      );
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your AI consent could not be saved. No answer was sent.',
            ),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _requestAiReview() async {
    if (!session.coach.enabled ||
        !session.checkpointReady ||
        session.answerForReview.trim().isEmpty) {
      return;
    }
    if (!await _confirmAiConsent() || !mounted) return;
    FocusScope.of(context).unfocus();
    await session.reviewWithCoach();
    if (!mounted) return;
    final result = session.messages.last;
    if (result.kind == MessageKind.feedback ||
        result.kind == MessageKind.error) {
      await _showGuidance(
        result.kind == MessageKind.error
            ? 'AI coach unavailable'
            : 'AI coach suggestion',
        result.text,
      );
      if (mounted && result.kind == MessageKind.feedback) {
        revealTarget(checkpointKey);
      }
    } else {
      await _showGuidance(
        'AI coach unavailable',
        'No feedback arrived. Your thinking is saved. Use the offline review to continue.',
      );
    }
  }

  bool get _reviewedCurrentStep {
    if (!session.checkpointReady) return false;
    final messages = session.messages;
    final checkpoint = messages.lastIndexWhere(
      (message) => message.kind == MessageKind.checkpoint,
    );
    if (checkpoint < 0) return false;
    return messages
        .skip(checkpoint + 1)
        .any(
          (message) =>
              message.kind == MessageKind.feedback ||
              (message.kind == MessageKind.offlineCoach &&
                  message.text.startsWith('Self-check for ')),
        );
  }

  Future<void> _reviewOffline() async {
    if (session.reviewing || !session.checkpointReady) return;
    final guidance =
        'Self-check for ${session.stage.label.toLowerCase()}\n\n'
        '${session.selfCheck}\n\n'
        'Compare this with your saved thinking. What holds up, and what would you revise? '
        'This guide cannot judge whether your answer is correct.';
    session.addOfflineGuidance(guidance);
    unawaited(widget.store.flush());
    await _showGuidance('Review your thinking', guidance);
    if (mounted) revealTarget(checkpointKey);
  }

  Future<void> _openOfflineCoach() async {
    final action = await showModalBottomSheet<_OfflineCoachAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .86,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text('OFFLINE COACH', style: noteLabel),
                    ),
                    IconButton(
                      tooltip: 'Close offline coach',
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'What would help right now?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uses this problem’s own statement, example, checks, and hints. It will not grade your answer or change your draft.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                _coachAction(
                  sheetContext,
                  _OfflineCoachAction.clarify,
                  Icons.subject_outlined,
                  'Clarify the task',
                  'Restate what the problem asks you to produce.',
                ),
                _coachAction(
                  sheetContext,
                  _OfflineCoachAction.example,
                  Icons.play_circle_outline,
                  'Walk through the example',
                  'Trace the example by hand and name each state change.',
                ),
                _coachAction(
                  sheetContext,
                  _OfflineCoachAction.edgeCase,
                  Icons.tune,
                  'Think about edge cases',
                  'Use the constraints to choose boundary cases to consider.',
                ),
                _coachAction(
                  sheetContext,
                  _OfflineCoachAction.selfCheck,
                  Icons.fact_check_outlined,
                  'Use the current self-check',
                  'Compare your own reasoning with this step’s checkpoint.',
                ),
                _coachAction(
                  sheetContext,
                  _OfflineCoachAction.nextHint,
                  Icons.lightbulb_outline,
                  session.hintsUsed < session.lesson.hints.length
                      ? 'Give me the next hint'
                      : 'All hints have been used',
                  session.hintsUsed < session.lesson.hints.length
                      ? 'Reveal one authored hint. You can still solve it yourself.'
                      : 'You can revisit any hint in the session notes below.',
                  enabled: session.hintsUsed < session.lesson.hints.length,
                ),
                const SizedBox(height: 10),
                Text(
                  'Guidance is saved in session notes. Your step only advances when you choose to continue.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted || action == null) return;
    late String guidance;
    late String title;
    switch (action) {
      case _OfflineCoachAction.clarify:
        title = 'Clarify the task';
        guidance =
            'Task check\n\n${session.lesson.statement}\n\nYour turn: In one sentence, name the input and the exact result the solution must return. Which part of the statement tells you that?';
        break;
      case _OfflineCoachAction.example:
        title = 'Walk through the example';
        guidance =
            'Walk through this example\n\n${session.lesson.example}\n\nTrace it by hand. What is the state before each step, and what should the final output be?';
        break;
      case _OfflineCoachAction.edgeCase:
        title = 'Think about edge cases';
        guidance =
            'Edge-case prompt\n\nConstraints: ${session.lesson.constraints}\n\nChoose a smallest or largest valid input, plus a duplicate, empty, or boundary case when allowed by the statement. Which case would challenge your current approach, and why?';
        break;
      case _OfflineCoachAction.selfCheck:
        title = 'Check your reasoning';
        guidance =
            'Self-check for ${session.stage.label.toLowerCase()}\n\n${session.selfCheck}\n\nCompare your current thinking with each point. Which can you justify, and what still needs work? This is a reflection prompt, not a verdict.';
        break;
      case _OfflineCoachAction.nextHint:
        session.requestHint();
        unawaited(widget.store.flush());
        title = 'Your next hint';
        guidance = session.messages.last.text;
    }
    if (action != _OfflineCoachAction.nextHint) {
      session.addOfflineGuidance(guidance);
      unawaited(widget.store.flush());
    }
    await _showGuidance(title, guidance);
  }

  Widget _coachAction(
    BuildContext sheetContext,
    _OfflineCoachAction action,
    IconData icon,
    String title,
    String subtitle, {
    bool enabled = true,
  }) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: Icon(icon),
    title: Text(title, style: const TextStyle(fontSize: 16)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.4)),
    enabled: enabled,
    onTap: enabled ? () => Navigator.pop(sheetContext, action) : null,
  );

  void revealTarget(GlobalKey target) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = target.currentContext;
      if (mounted && targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          alignment: .12,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
        );
      }
    });
  }

  Future<void> _openOfficialChallenge() async {
    final entry = mastery300ByLessonId[session.lesson.id];
    if (entry == null) return;
    final opened = await launchUrl(
      entry.challengeUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the challenge page.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([session, widget.store]),
    builder: (context, _) => ReadableSurface(
      scale: widget.store.preferences.textScale,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            session.lesson.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: widget.store.isSaved(session.lesson)
                  ? 'Remove saved problem'
                  : 'Save problem',
              icon: Icon(
                widget.store.isSaved(session.lesson)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
              onPressed: () async {
                try {
                  await widget.store.toggleSaved(session.lesson);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not save this change locally. Try again.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            TextButton.icon(
              onPressed: () {
                session.toggleFocus();
                revealTarget(questionKey);
              },
              icon: Icon(
                focusView
                    ? Icons.fullscreen_exit
                    : Icons.center_focus_strong_outlined,
                size: 18,
              ),
              label: Text(focusView ? 'Overview' : 'Focus'),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final split = constraints.maxWidth >= 1000 && !focusView;
            final problem = focusView
                ? ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 20),
                    title: const Text(
                      'Problem & examples',
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      session.lesson.pattern,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.palette.muted,
                      ),
                    ),
                    children: [_problem()],
                  )
                : _problem();
            return SingleChildScrollView(
              controller: scroll,
              padding: EdgeInsets.all(split ? 36 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: focusView ? 720 : 1160),
                  child: split
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: problem),
                            const SizedBox(width: 48),
                            Expanded(flex: 6, child: _coaching()),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            problem,
                            const SizedBox(height: 28),
                            _coaching(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _problem() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(session.lesson.pattern.toUpperCase(), style: noteLabel),
      if (mastery300ByLessonId.containsKey(session.lesson.id)) ...[
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _openOfficialChallenge,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Open official problem statement'),
          ),
        ),
      ],
      const SizedBox(height: 18),
      const Text(
        'The problem',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: -.5,
        ),
      ),
      const SizedBox(height: 14),
      SelectableText(
        session.lesson.statement,
        style: const TextStyle(fontSize: 16, height: 1.7),
      ),
      const SizedBox(height: 22),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.palette.recess,
          border: Border(
            left: BorderSide(color: context.palette.line, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EXAMPLE / 01', style: noteLabel),
            const SizedBox(height: 10),
            SelectableText(
              session.lesson.example,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Text(
        session.lesson.constraints,
        style: TextStyle(
          fontSize: 14,
          color: context.palette.muted,
          height: 1.7,
        ),
      ),
      if (sprintReferences[session.lesson.id] case final reference?) ...[
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text(
            'Edge cases to watch',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Trace these before you write code.',
            style: TextStyle(fontSize: 14),
          ),
          children: [
            for (final edge in reference.edgeCases)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '• $edge',
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ],
    ],
  );

  Widget _message(CoachMessage message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.isLearner
              ? 'YOUR THINKING'
              : message.kind == MessageKind.feedback
              ? 'AI COACH / SUGGESTION'
              : message.kind == MessageKind.error
              ? 'AI COACH / UNAVAILABLE'
              : message.kind == MessageKind.offlineCoach
              ? 'OFFLINE COACH / CURATED GUIDANCE'
              : 'GUIDED NOTE',
          style: noteLabel,
        ),
        const SizedBox(height: 10),
        SelectableText(
          message.text,
          style: const TextStyle(fontSize: 16, height: 1.7),
        ),
      ],
    ),
  );

  Widget _coaching() {
    final complete = session.stage == CoachingStage.complete;
    final saved = session.checkpointReady;
    final reviewed = _reviewedCurrentStep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Guided practice progress',
          value: complete
              ? 'Self-review complete. Five of five steps.'
              : 'Step ${session.stage.index + 1} of five. ${session.stage.label}.',
          liveRegion: true,
          child: ExcludeSemantics(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        complete ? 'SELF-REVIEW COMPLETE' : 'YOUR NEXT STEP',
                        style: noteLabel,
                      ),
                    ),
                    Text(
                      complete ? '05 / 05' : '0${session.stage.index + 1} / 05',
                      style: noteLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    5,
                    (i) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 4 ? 5 : 0),
                        child: Container(
                          height: 3,
                          color: complete || i < session.stage.index
                              ? context.palette.accent
                              : i == session.stage.index
                              ? context.palette.ink
                              : context.palette.line,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          key: questionKey,
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .035),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey(session.stage),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complete ? 'Keep the insight.' : '${session.stage.label}.',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  complete
                      ? 'Reflection saved. This attempt is self-reviewed. No test verdict yet.'
                      : session.question,
                  style: const TextStyle(fontSize: 16, height: 1.7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SaveStatus(store: widget.store, compact: true),
        const SizedBox(height: 24),
        if (complete) ...[
          Text(
            'How did this attempt feel?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Your answer sets the next recall date. You can change it later.',
            style: TextStyle(fontSize: 14, color: context.palette.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final (rating, label) in [
                (RecallConfidence.needsWork, 'Needs work'),
                (RecallConfidence.okay, 'Okay'),
                (RecallConfidence.confident, 'Confident'),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: session.recallConfidence == rating,
                  onSelected: (_) => session.rateRecall(rating),
                ),
            ],
          ),
          if (widget.store.reviewSchedule
                  .where((item) => item.lesson.id == session.lesson.id)
                  .firstOrNull
              case final assignment?) ...[
            const SizedBox(height: 10),
            Text(
              'Next recall in ${assignment.intervalDays} ${assignment.intervalDays == 1 ? 'day' : 'days'} · self-assessed practice',
              style: TextStyle(fontSize: 14, color: context.palette.muted),
            ),
          ],
        ],
        if (session.stage == CoachingStage.code && !saved) ...[
          CodeWorkspace(
            lessonId: session.lesson.id,
            store: widget.store,
            language: session.language,
            editor: editor,
            enabled: !session.reviewing,
            onChanged: session.saveDraft,
            onLanguageChanged: (language) {
              session.changeLanguage(language);
              editor.text = session.draft;
            },
            editorAction: FilledButton(
              onPressed: session.reviewing ? null : _saveCodeForSelfReview,
              child: const Text('Save code for self-review'),
            ),
          ),
        ] else if (!complete && !saved) ...[
          TextField(
            controller: composer,
            enabled: !session.reviewing,
            onChanged: session.saveReasoningDraft,
            minLines: 4,
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 16, height: 1.65),
            decoration: const InputDecoration(
              labelText: 'Talk through your thinking',
              hintText: 'Start with the idea, then explain why it works.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: session.reviewing || composer.text.trim().isEmpty
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    session.submit(composer.text);
                    unawaited(widget.store.flush());
                    composer.clear();
                  },
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Save my thinking'),
          ),
        ],
        if (saved && !reviewed) ...[
          const Text(
            'Thinking saved. Choose how to review it.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 12),
          if (session.coach.enabled) ...[
            OutlinedButton.icon(
              onPressed: session.reviewing ? null : _requestAiReview,
              icon: session.reviewing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(
                session.reviewing ? 'AI coach is reviewing…' : 'Review with AI',
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: session.reviewing ? null : _reviewOffline,
            icon: const Icon(Icons.fact_check_outlined, size: 18),
            label: const Text('Review offline'),
          ),
        ],
        if (saved && reviewed) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 18),
          Text('CHECK YOUR REASONING', key: checkpointKey, style: noteLabel),
          const SizedBox(height: 10),
          Text(
            session.selfCheck,
            style: const TextStyle(height: 1.7, fontSize: 14),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: session.reviewing ? null : advance,
            icon: const Icon(Icons.check, size: 18),
            label: Text(
              session.stage == CoachingStage.reflect
                  ? 'Finish my self-review'
                  : 'I checked my work · continue',
            ),
          ),
        ],
        if (!complete) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: context.palette.muted,
                ),
                onPressed:
                    !session.reviewing &&
                        session.hintsUsed < session.lesson.hints.length
                    ? _showNextHint
                    : null,
                icon: const Icon(Icons.lightbulb_outline, size: 16),
                label: Text(
                  'Hint ${session.hintsUsed}/${session.lesson.hints.length}',
                ),
              ),
            ],
          ),
          if (saved)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('More options', style: TextStyle(fontSize: 15)),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: session.reviewing
                        ? null
                        : session.stage == CoachingStage.code
                        ? _reviseCode
                        : _reviseThinking,
                    child: Text(
                      session.stage == CoachingStage.code
                          ? 'Edit my code'
                          : 'Revise my thinking',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: session.reviewing ? null : reveal,
                    child: Text(
                      session.solutionRevealed
                          ? 'View explanation'
                          : 'Reveal explanation',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: session.reviewing ? null : _openOfflineCoach,
                    child: const Text('Explore offline prompts'),
                  ),
                ),
              ],
            ),
        ] else ...[
          Text(
            session.assisted
                ? 'Completed with assistance.'
                : 'Completed without hints.',
            style: TextStyle(color: context.palette.muted, height: 1.6),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to learning'),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Session notes / ${session.messages.length}',
            style: TextStyle(fontSize: 13, color: context.palette.muted),
          ),
          children: session.messages.map(_message).toList(),
        ),
      ],
    );
  }
}
