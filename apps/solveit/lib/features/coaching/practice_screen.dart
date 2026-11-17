import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mastery300_curriculum.dart';
import '../../data/sprint_references.dart';
import '../../domain/lesson.dart';
import '../../ui/looploom_theme.dart';
import '../../ui/save_status.dart';
import '../../ui/takeaway_dialog.dart';
import '../../ui/code_workspace.dart';
import '../../ui/readable_surface.dart';
import 'firebase_ai_coach_provider.dart';
import 'session_controller.dart';

enum _StepTool { revise, explanation, walkthrough }

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
  Timer? _aiProgressTimer;
  int _aiWaitSeconds = 0;
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
    _aiProgressTimer?.cancel();
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

  Future<void> _reviewHints() async {
    final revealed = session.messages
        .where((message) => message.kind == MessageKind.hint)
        .toList(growable: false);
    if (revealed.isEmpty) return;
    final text = [
      for (var i = 0; i < revealed.length; i++)
        'Hint ${i + 1}\n${revealed[i].text}',
    ].join('\n\n');
    await _showGuidance('Hints revealed', text);
  }

  Future<void> _showExampleWalkthrough() async {
    final lesson = session.lesson;
    final walkthrough =
        'Example\n${lesson.example}\n\n'
        'Dry run\n'
        '1. Start with the input shown above.\n'
        '2. ${_traceInstruction(lesson.pattern)}\n'
        '3. Record the state after each step, then compare your result with the example output.';
    final alreadySaved = session.messages.any(
      (message) =>
          message.kind == MessageKind.offlineCoach &&
          message.text == walkthrough,
    );
    if (!alreadySaved) {
      session.addOfflineGuidance(walkthrough);
      unawaited(widget.store.flush());
    }
    await _showGuidance('Walk through the example', walkthrough);
  }

  String _traceInstruction(String pattern) {
    final name = pattern.toLowerCase();
    if (name.contains('pointer')) {
      return 'Write down both pointer positions and the comparison that decides each move.';
    }
    if (name.contains('window')) {
      return 'Track the current window, its running value, and what enters or leaves.';
    }
    if (name.contains('prefix')) {
      return 'Track the running prefix and the earlier state that matches the current step.';
    }
    if (name.contains('stack')) {
      return 'Show the stack after each input and note which earlier items get resolved.';
    }
    if (name.contains('interval')) {
      return 'Compare each interval with the current range and record when that range changes.';
    }
    if (name.contains('binary search')) {
      return 'Record the low, middle, and high positions, then state why one half can be skipped.';
    }
    if (name.contains('tree')) {
      return 'Track the node being visited and the values waiting to be processed.';
    }
    if (name.contains('graph')) {
      return 'Track the current node, its neighbors, and which nodes have already been visited.';
    }
    if (name.contains('dynamic programming') || name.contains('dp')) {
      return 'Record each result and the earlier result it depends on.';
    }
    if (name.contains('backtrack')) {
      return 'Show each choice added to the partial answer and when that choice is undone.';
    }
    if (name.contains('heap')) {
      return 'Track the values kept in the heap and how each new value changes it.';
    }
    if (name.contains('hash') || name.contains('lookup')) {
      return 'Track what has been seen so far and what the current item needs to find.';
    }
    return 'Track the important state before and after processing each input item.';
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
    _aiProgressTimer?.cancel();
    setState(() => _aiWaitSeconds = 0);
    _aiProgressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !session.reviewing) return;
      setState(() => _aiWaitSeconds += 5);
    });
    await session.reviewWithCoach();
    _aiProgressTimer?.cancel();
    _aiProgressTimer = null;
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

  Widget _message(CoachMessage message) {
    final isLearner = message.isLearner;
    final bubbleColor = isLearner
        ? context.palette.accentWash
        : context.palette.sheet;
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * .82,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          border: isLearner ? null : Border.all(color: context.palette.line),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isLearner ? 16 : 5),
            bottomRight: Radius.circular(isLearner ? 5 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _messageSpeaker(message),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: message.kind == MessageKind.error
                    ? Theme.of(context).colorScheme.error
                    : context.palette.muted,
              ),
            ),
            const SizedBox(height: 5),
            SelectableText(
              message.text,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
    final tail = CustomPaint(
      size: const Size(8, 10),
      painter: _MessageTailPainter(
        color: bubbleColor,
        borderColor: context.palette.line,
        pointsRight: isLearner,
        outlined: !isLearner,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Align(
        alignment: isLearner ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: isLearner ? [bubble, tail] : [tail, bubble],
        ),
      ),
    );
  }

  String _messageSpeaker(CoachMessage message) {
    if (message.isLearner) return 'You';
    return switch (message.kind) {
      MessageKind.feedback => 'AI coach',
      MessageKind.error => 'AI coach · connection issue',
      MessageKind.offlineCoach => 'Offline coach',
      MessageKind.hint => 'Hint',
      MessageKind.solution => 'Explanation',
      MessageKind.checkpoint => 'Self-check',
      MessageKind.question => 'LoopLoom',
      MessageKind.note => 'Session note',
    };
  }

  Widget _hintAction({required bool complete}) {
    final used = session.hintsUsed;
    final total = session.lesson.hints.length;
    final canRevealNext = !complete && !session.reviewing && used < total;
    final canReview = !session.reviewing && used > 0;
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: context.palette.accent,
        foregroundColor: context.palette.onAccent,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      onPressed: canRevealNext
          ? _showNextHint
          : canReview
          ? _reviewHints
          : null,
      icon: Icon(
        canRevealNext ? Icons.lightbulb_outline : Icons.history,
        size: 16,
      ),
      label: Text(
        canRevealNext
            ? 'Hint ${used + 1}/$total'
            : used > 0
            ? 'Review $used/$total'
            : 'Hints 0/$total',
      ),
    );
  }

  Widget _stepTools() => Container(
    decoration: BoxDecoration(
      color: context.palette.sheet,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.palette.line),
    ),
    child: PopupMenuButton<_StepTool>(
      tooltip: 'Open step tools',
      onSelected: (tool) {
        switch (tool) {
          case _StepTool.revise:
            if (session.stage == CoachingStage.code) {
              _reviseCode();
            } else {
              _reviseThinking();
            }
          case _StepTool.explanation:
            reveal();
          case _StepTool.walkthrough:
            _showExampleWalkthrough();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _StepTool.revise,
          enabled: !session.reviewing,
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.edit_outlined),
            title: Text(
              session.stage == CoachingStage.code
                  ? 'Edit code'
                  : 'Revise thinking',
            ),
          ),
        ),
        PopupMenuItem(
          value: _StepTool.explanation,
          enabled: !session.reviewing,
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(
              session.solutionRevealed
                  ? 'View explanation'
                  : 'Reveal explanation',
            ),
          ),
        ),
        PopupMenuItem(
          value: _StepTool.walkthrough,
          enabled: !session.reviewing,
          child: const ListTile(
            dense: true,
            leading: Icon(Icons.route_outlined),
            title: Text('Walk through example'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Icon(Icons.more_horiz, color: context.palette.accent, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step tools',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Revise, explain, or trace an example',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: context.palette.muted),
          ],
        ),
      ),
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => editTakeaway(context, session, widget.store),
              icon: const Icon(Icons.edit_note, size: 18),
              label: Text(
                session.takeaway.isEmpty ? 'Save a takeaway' : 'Edit takeaway',
              ),
            ),
          ),
          if (session.takeaway.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              session.takeaway,
              style: const TextStyle(fontSize: 15, height: 1.55),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: context.palette.accent,
                backgroundColor: context.palette.accentWash,
                side: BorderSide(color: context.palette.accent),
                minimumSize: const Size.fromHeight(46),
              ),
              onPressed: session.reviewing ? null : _requestAiReview,
              icon: session.reviewing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chat_bubble_outline, size: 18),
              label: Text(
                !session.reviewing
                    ? 'Review with AI'
                    : _aiWaitSeconds >= 15
                    ? 'Still waiting · your answer is saved'
                    : _aiWaitSeconds >= 5
                    ? 'Waiting for Gemini…'
                    : 'Connecting securely…',
              ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: context.palette.ink,
              backgroundColor: context.palette.recess,
              side: BorderSide(color: context.palette.line),
              minimumSize: const Size.fromHeight(46),
            ),
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
          if (session.lesson.hints.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: _hintAction(complete: false),
            ),
          if (saved) _stepTools(),
        ] else ...[
          if (session.hintsUsed > 0) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _hintAction(complete: true),
            ),
          ],
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
            'Session conversation · ${session.messages.length}',
            style: TextStyle(fontSize: 15, color: context.palette.ink),
          ),
          children: [
            SizedBox(
              height: (session.messages.length * 112.0 + 24).clamp(
                160.0,
                480.0,
              ),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                itemCount: session.messages.length,
                itemBuilder: (context, index) =>
                    _message(session.messages[index]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageTailPainter extends CustomPainter {
  const _MessageTailPainter({
    required this.color,
    required this.borderColor,
    required this.pointsRight,
    required this.outlined,
  });

  final Color color;
  final Color borderColor;
  final bool pointsRight;
  final bool outlined;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsRight) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height - 1)
        ..close();
    } else {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height - 1)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
    if (outlined) {
      final outline = Path();
      if (pointsRight) {
        outline
          ..moveTo(0, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height - 1);
      } else {
        outline
          ..moveTo(size.width, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height - 1);
      }
      canvas.drawPath(
        outline,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MessageTailPainter oldDelegate) =>
      color != oldDelegate.color ||
      borderColor != oldDelegate.borderColor ||
      pointsRight != oldDelegate.pointsRight ||
      outlined != oldDelegate.outlined;
}
