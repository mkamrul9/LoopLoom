import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/mastery300_curriculum.dart';
import '../../domain/lesson.dart';
import '../../ui/looploom_theme.dart';
import '../../ui/save_status.dart';
import '../../ui/code_workspace.dart';
import '../../ui/readable_surface.dart';
import 'session_controller.dart';

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
  final noteKey = GlobalKey();
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
      revealTarget(noteKey);
    }
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
              icon: Icon(widget.store.isSaved(session.lesson)
                  ? Icons.bookmark
                  : Icons.bookmark_border),
              onPressed: () async {
                try {
                  await widget.store.toggleSaved(session.lesson);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not save this change locally. Try again.')),
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
          border: Border(left: BorderSide(color: context.palette.line, width: 2)),
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
              ? 'LOCAL COACH / EXPERIMENTAL'
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
    final latest = session.messages.last;
    final complete = session.stage == CoachingStage.complete;
    final showNote =
        !complete &&
        !latest.isLearner &&
        latest.text != session.question &&
        latest.kind != MessageKind.question &&
        latest.kind != MessageKind.checkpoint;
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
        Text(
          complete ? 'Keep the insight.' : '${session.stage.label}.',
          key: questionKey,
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
        const SizedBox(height: 12),
        Text(
          session.coach.enabled
              ? 'Local coach · experimental feedback. Feedback does not execute code.'
              : 'Guided self-check · No AI grading. Saving code does not run it.',
          style: TextStyle(
            fontSize: 11,
            color: context.palette.muted,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 8),
        SaveStatus(store: widget.store),
        if (showNote) ...[
          const SizedBox(height: 12),
          Container(key: noteKey, child: _message(latest)),
        ],
        const SizedBox(height: 24),
        if (session.stage == CoachingStage.code) ...[
          CodeWorkspace(
            lessonId: session.lesson.id,
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
        ] else if (!complete) ...[
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
            onPressed: session.reviewing
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    session.submit(composer.text);
                    unawaited(widget.store.flush());
                    composer.clear();
                    revealTarget(checkpointKey);
                  },
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Save my thinking'),
          ),
        ],
        if (session.coach.enabled && !complete) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed:
                session.reviewing || session.answerForReview.trim().isEmpty
                ? null
                : () async {
                    FocusScope.of(context).unfocus();
                    await session.reviewWithCoach();
                    if (mounted) revealTarget(noteKey);
                  },
            icon: session.reviewing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chat_bubble_outline, size: 16),
            label: Text(
              session.reviewing ? 'Thinking locally…' : 'Ask local coach',
            ),
          ),
        ],
        if (session.checkpointReady) ...[
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
          OutlinedButton.icon(
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
                style: TextButton.styleFrom(foregroundColor: context.palette.muted),
                onPressed:
                    !session.reviewing &&
                        session.hintsUsed < session.lesson.hints.length
                    ? () {
                        session.requestHint();
                        revealTarget(noteKey);
                      }
                    : null,
                icon: const Icon(Icons.lightbulb_outline, size: 16),
                label: Text(
                  'Hint ${session.hintsUsed}/${session.lesson.hints.length}',
                ),
              ),
              TextButton(
                onPressed: session.solutionRevealed || session.reviewing
                    ? null
                    : reveal,
                child: const Text('Reveal explanation'),
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
