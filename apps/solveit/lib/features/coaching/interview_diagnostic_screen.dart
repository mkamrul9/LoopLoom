import 'package:flutter/material.dart';

import '../../data/blind75_curriculum.dart';
import '../../data/interview_diagnostic.dart';
import '../../data/mastery300_curriculum.dart';
import '../../domain/lesson.dart';
import '../../features/coaching/session_controller.dart';
import '../../ui/looploom_theme.dart';
import '../../ui/readable_surface.dart';

class InterviewDiagnosticScreen extends StatefulWidget {
  const InterviewDiagnosticScreen({super.key, required this.store});

  final PracticeStore store;

  @override
  State<InterviewDiagnosticScreen> createState() =>
      _InterviewDiagnosticScreenState();
}

class _InterviewDiagnosticScreenState extends State<InterviewDiagnosticScreen> {
  final Map<String, int> _answers = {};
  int _questionIndex = 0;
  bool _started = false;
  bool _completed = false;
  bool _saving = false;
  bool _saveFailed = false;
  DateTime? _completedAt;

  PracticeStore get store => widget.store;

  Future<void> _finish() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _completedAt = DateTime.now().toUtc();
    });
    try {
      await store.updatePreferences(
        store.preferences.copyWith(
          diagnosticCompletedAt: _completedAt,
          diagnosticScores: {
            for (final question in interviewDiagnostic)
              question.pattern: _answers[question.id] == question.bestChoice
                  ? 1
                  : 0,
          },
          diagnosticAnswers: Map.of(_answers),
        ),
      );
      if (mounted) {
        setState(() {
          _completed = true;
          _saveFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _completed = true;
          _saveFailed = true;
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _retrySave() async {
    if (_saving || _completedAt == null) return;
    setState(() => _saving = true);
    try {
      await store.updatePreferences(
        store.preferences.copyWith(
          diagnosticCompletedAt: _completedAt,
          diagnosticScores: {
            for (final question in interviewDiagnostic)
              question.pattern: _answers[question.id] == question.bestChoice
                  ? 1
                  : 0,
          },
          diagnosticAnswers: Map.of(_answers),
        ),
      );
      if (mounted) setState(() => _saveFailed = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Still unable to save. Try again later.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Blind75Entry? _recommendedEntry(DiagnosticQuestion question) {
    final matching = mastery300Entries.where(
      (entry) => entry.pattern.toLowerCase().contains(question.patternNeedle),
    );
    return matching.firstWhereOrNull(
          (entry) => !store.sessions.any(
            (session) =>
                session.lesson.id == entry.lesson.id &&
                session.stage == CoachingStage.complete,
          ),
        ) ??
        matching.firstOrNull;
  }

  List<DiagnosticQuestion> get _focusQuestions {
    final weaker = interviewDiagnostic
        .where((question) => _answers[question.id] != question.bestChoice)
        .toList();
    return (weaker.isEmpty ? interviewDiagnostic : weaker).take(3).toList();
  }

  Widget _page(Widget child) => ReadableSurface(
    scale: store.preferences.textScale,
    child: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: child,
          ),
        ),
      ),
    ),
  );

  Widget _intro() {
    final lastResult = store.preferences.diagnosticCompletedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('A QUICK STARTING POINT', style: noteLabel),
        const SizedBox(height: 18),
        const Text(
          'Find your next pattern to practice.',
          style: TextStyle(fontSize: 32, height: 1.18, letterSpacing: -.8),
        ),
        const SizedBox(height: 14),
        Text(
          'Eight interview-style scenarios help you choose where to focus next. You’ll see a short explanation and get problems from the guided path.',
          style: TextStyle(
            color: context.palette.muted,
            fontSize: 16,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.palette.recess,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ABOUT THIS CHECK', style: noteLabel),
              const SizedBox(height: 10),
              const Text(
                'Around 5 minutes · No code editor · Saved on this device',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'This is a lightweight pattern-recognition check, not a grade or a measure of interview readiness. Your answers only shape a suggested practice order.',
                style: TextStyle(color: context.palette.muted, height: 1.6),
              ),
            ],
          ),
        ),
        if (lastResult != null) ...[
          const SizedBox(height: 16),
          Text(
            'Last completed ${MaterialLocalizations.of(context).formatMediumDate(lastResult.toLocal())}. Retaking updates your saved result.',
            style: TextStyle(color: context.palette.muted, height: 1.5),
          ),
        ],
        const SizedBox(height: 26),
        FilledButton.icon(
          onPressed: () => setState(() => _started = true),
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            lastResult == null ? 'Start the check' : 'Retake the check',
          ),
        ),
      ],
    );
  }

  Widget _choiceCard(DiagnosticQuestion question, int index) {
    final selected = _answers[question.id] == index;
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: question.choices[index].label,
      child: Material(
        color: selected ? palette.accentWash : palette.sheet,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _answers[question.id] = index),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? palette.accent : palette.line,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? palette.accent : palette.muted,
                  size: 21,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    question.choices[index].label,
                    style: const TextStyle(fontSize: 15, height: 1.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _question() {
    final question = interviewDiagnostic[_questionIndex];
    final lastQuestion = _questionIndex == interviewDiagnostic.length - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('INTERVIEW PATTERN CHECK', style: noteLabel),
            ),
            Text(
              '${_questionIndex + 1} / ${interviewDiagnostic.length}',
              style: TextStyle(
                color: context.palette.muted,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (_questionIndex + 1) / interviewDiagnostic.length,
            minHeight: 5,
            backgroundColor: context.palette.recess,
          ),
        ),
        const SizedBox(height: 28),
        Text(question.pattern.toUpperCase(), style: noteLabel),
        const SizedBox(height: 12),
        Text(
          question.prompt,
          style: const TextStyle(
            fontSize: 22,
            height: 1.45,
            letterSpacing: -.25,
          ),
        ),
        const SizedBox(height: 22),
        ...question.choices.indexed.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _choiceCard(question, item.$1),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (_questionIndex > 0)
              TextButton.icon(
                onPressed: () => setState(() => _questionIndex--),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _answers.containsKey(question.id)
                  ? lastQuestion
                        ? _finish
                        : () => setState(() => _questionIndex++)
                  : null,
              icon: Icon(lastQuestion ? Icons.check : Icons.arrow_forward),
              label: Text(
                _saving
                    ? 'Saving…'
                    : lastQuestion
                    ? 'See my practice plan'
                    : 'Continue',
              ),
            ),
          ],
        ),
      ],
    );
  }

  int get _score => interviewDiagnostic
      .where((question) => _answers[question.id] == question.bestChoice)
      .length;

  Widget _recommendation(DiagnosticQuestion question, int index) {
    final entry = _recommendedEntry(question);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.palette.sheet,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FOCUS ${index.toString().padLeft(2, '0')}', style: noteLabel),
          const SizedBox(height: 8),
          Text(
            question.pattern,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            entry == null
                ? 'Review this pattern in the interview path.'
                : '${entry.title} · ${entry.difficulty}',
            style: TextStyle(color: context.palette.muted, height: 1.45),
          ),
          if (entry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop<Lesson>(entry.lesson),
              icon: const Icon(Icons.auto_stories_outlined),
              label: const Text('Start guided practice'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerReview(DiagnosticQuestion question) {
    final chosen = _answers[question.id];
    final matched = chosen == question.bestChoice;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                matched ? Icons.check_circle_outline : Icons.circle_outlined,
                size: 19,
                color: matched ? context.palette.accent : context.palette.muted,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  question.pattern,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'You chose: ${question.choices[chosen!].label}',
            style: TextStyle(color: context.palette.muted, height: 1.5),
          ),
          if (!matched) ...[
            const SizedBox(height: 4),
            Text(
              'A useful next direction: ${question.choices[question.bestChoice].label}',
              style: TextStyle(color: context.palette.muted, height: 1.5),
            ),
          ],
          const SizedBox(height: 5),
          Text(
            question.explanation,
            style: TextStyle(color: context.palette.muted, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _results() {
    final lastResult = store.preferences.diagnosticCompletedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YOUR PRACTICE PLAN', style: noteLabel),
        const SizedBox(height: 14),
        Text(
          _score == interviewDiagnostic.length
              ? 'Good pattern instincts.'
              : 'A clear place to begin.',
          style: const TextStyle(fontSize: 30, height: 1.2, letterSpacing: -.7),
        ),
        const SizedBox(height: 10),
        Text(
          'You chose a useful starting direction in $_score of ${interviewDiagnostic.length} scenarios. This quick check is not a grade or an interview-readiness score.',
          style: TextStyle(
            color: context.palette.muted,
            fontSize: 16,
            height: 1.6,
          ),
        ),
        if (_saveFailed) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.palette.accentWash,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your plan is ready, but the result could not be saved on this device.',
                  ),
                ),
                TextButton(
                  onPressed: _saving ? null : _retrySave,
                  child: Text(_saving ? 'Saving…' : 'Retry'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 26),
        Text(
          _score == interviewDiagnostic.length
              ? 'Stretch your thinking'
              : 'Start with these patterns',
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          _score == interviewDiagnostic.length
              ? 'Try explaining the invariant, edge cases, and complexity for each one.'
              : 'These scenarios point to useful areas for another round of practice.',
          style: TextStyle(color: context.palette.muted, height: 1.5),
        ),
        ..._focusQuestions.indexed.map(
          (item) => _recommendation(item.$2, item.$1 + 1),
        ),
        const SizedBox(height: 28),
        const Text('A FEW NOTES TO KEEP', style: noteLabel),
        const SizedBox(height: 4),
        ...interviewDiagnostic.map(_answerReview),
        const SizedBox(height: 16),
        if (lastResult != null && !_saveFailed)
          Text(
            'Saved ${MaterialLocalizations.of(context).formatMediumDate(lastResult.toLocal())}',
            style: TextStyle(color: context.palette.muted, fontSize: 13),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _answers.clear();
            _questionIndex = 0;
            _completed = false;
            _started = false;
            _saveFailed = false;
          }),
          icon: const Icon(Icons.refresh),
          label: const Text('Retake diagnostic'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Interview diagnostic')),
    body: _page(
      _completed
          ? _results()
          : _started
          ? _question()
          : _intro(),
    ),
  );
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  T? firstWhereOrNull(bool Function(T value) test) {
    for (final value in this) {
      if (test(value)) return value;
    }
    return null;
  }
}
