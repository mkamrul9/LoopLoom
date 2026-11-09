import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/data/daily_practice_plan.dart';
import 'package:looploom/data/pilot_lessons.dart';
import 'package:looploom/domain/learner_preferences.dart';
import 'package:looploom/features/coaching/session_controller.dart';

SessionController completed(int lessonIndex) {
  final session = SessionController(
    pilotLessons[lessonIndex],
    attemptNumber: lessonIndex + 1,
  );
  for (var i = 0; i < 5; i++) {
    session.submit(i == 3 ? 'print(1)' : 'My reasoning');
    session.advanceAfterSelfCheck();
  }
  return session;
}

void main() {
  final now = DateTime(2026, 11, 9);

  test('a short goal suggests one next lesson', () {
    final plan = dailyPracticePlan(
      preferences: const LearnerPreferences(dailyGoalMinutes: 30),
      trackLessons: pilotLessons,
      sessions: const [],
      reviewSchedule: const [],
      now: now,
    );
    expect(plan.map((step) => step.lesson.id), [pilotLessons.first.id]);
    expect(plan.single.kind, DailyPracticeKind.newLesson);
  });

  test('unfinished work and due recall come before new practice', () {
    final active = SessionController(pilotLessons.first, attemptNumber: 1);
    final reviewed = completed(1);
    addTearDown(active.dispose);
    addTearDown(reviewed.dispose);
    final plan = dailyPracticePlan(
      preferences: const LearnerPreferences(dailyGoalMinutes: 90),
      trackLessons: pilotLessons,
      sessions: [active, reviewed],
      reviewSchedule: [
        ReviewAssignment(
          lesson: reviewed.lesson,
          dueAt: now.subtract(const Duration(days: 1)),
          intervalDays: 1,
          completedAttempts: 1,
        ),
      ],
      now: now,
    );
    expect(plan.map((step) => step.kind), [
      DailyPracticeKind.resume,
      DailyPracticeKind.review,
      DailyPracticeKind.newLesson,
    ]);
    expect(plan.map((step) => step.lesson.id).toSet().length, 3);
  });

  test('a longer goal can include a diagnostic weak pattern', () {
    final plan = dailyPracticePlan(
      preferences: const LearnerPreferences(
        dailyGoalMinutes: 45,
        diagnosticScores: {'Two pointers': 0},
      ),
      trackLessons: pilotLessons,
      sessions: const [],
      reviewSchedule: const [],
      now: now,
    );
    expect(plan.map((step) => step.lesson.id), [
      pilotLessons[0].id,
      pilotLessons[1].id,
    ]);
    expect(plan[1].reason, contains('quick check'));
  });

  test('a completed path with no due recall is caught up', () {
    final sessions = [
      for (var i = 0; i < pilotLessons.length; i++) completed(i),
    ];
    addTearDown(() {
      for (final session in sessions) {
        session.dispose();
      }
    });
    expect(
      dailyPracticePlan(
        preferences: const LearnerPreferences(),
        trackLessons: pilotLessons,
        sessions: sessions,
        reviewSchedule: const [],
        now: now,
      ),
      isEmpty,
    );
  });
}
