import '../domain/learner_preferences.dart';
import '../domain/lesson.dart';
import '../features/coaching/session_controller.dart';
import 'interview_diagnostic.dart';

enum DailyPracticeKind { resume, review, newLesson }

class DailyPracticeStep {
  const DailyPracticeStep(this.lesson, this.kind, this.reason);

  final Lesson lesson;
  final DailyPracticeKind kind;
  final String reason;
}

/// A short, local suggestion. It does not measure minutes or grade mastery.
List<DailyPracticeStep> dailyPracticePlan({
  required LearnerPreferences preferences,
  required List<Lesson> trackLessons,
  required List<SessionController> sessions,
  required List<ReviewAssignment> reviewSchedule,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final limit = preferences.dailyGoalMinutes >= 90
      ? 3
      : preferences.dailyGoalMinutes >= 45
      ? 2
      : 1;
  final steps = <DailyPracticeStep>[];
  final selected = <String>{};
  void add(Lesson lesson, DailyPracticeKind kind, String reason) {
    if (steps.length < limit && selected.add(lesson.id)) {
      steps.add(DailyPracticeStep(lesson, kind, reason));
    }
  }

  final unfinished = sessions
      .where((session) => session.stage != CoachingStage.complete)
      .firstOrNull;
  if (unfinished != null) {
    add(
      unfinished.lesson,
      DailyPracticeKind.resume,
      'Continue your saved work',
    );
  }
  for (final review in reviewSchedule) {
    if (review.isDueAt(today)) {
      add(review.lesson, DailyPracticeKind.review, 'Due for recall');
    }
  }

  final completed = {
    for (final session in sessions)
      if (session.stage == CoachingStage.complete) session.lesson.id,
  };
  final newLessons = trackLessons
      .where((lesson) => !completed.contains(lesson.id))
      .toList();
  if (newLessons.isNotEmpty) {
    add(newLessons.first, DailyPracticeKind.newLesson, 'Next in your path');
  }

  final weakNeedles = interviewDiagnostic
      .where((question) => preferences.diagnosticScores[question.pattern] == 0)
      .map((question) => question.patternNeedle)
      .toSet();
  for (final lesson in newLessons) {
    if (!selected.contains(lesson.id) &&
        weakNeedles.any(lesson.pattern.toLowerCase().contains)) {
      add(
        lesson,
        DailyPracticeKind.newLesson,
        'Practice a pattern from your quick check',
      );
      break;
    }
  }
  for (final lesson in newLessons) {
    add(lesson, DailyPracticeKind.newLesson, 'Next in your path');
  }
  return List.unmodifiable(steps);
}
