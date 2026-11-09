import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/data/pilot_lessons.dart';
import 'package:looploom/data/session_repository.dart';
import 'package:looploom/domain/lesson.dart';
import 'package:looploom/features/coaching/session_controller.dart';

void main() {
  test('completed reflections and optional takeaways survive restore', () {
    final session = SessionController(pilotLessons.first, attemptNumber: 1);
    addTearDown(session.dispose);
    session.saveTakeaway('Too early');
    expect(session.takeaway, isEmpty);
    for (var i = 0; i < 5; i++) {
      session.submit(
        i == 3
            ? 'print(1)'
            : i == 4
            ? 'Check repeated values before assuming indices differ.'
            : 'My reasoning',
      );
      session.advanceAfterSelfCheck();
    }
    expect(session.reflection, contains('repeated values'));
    session.saveTakeaway('Use two distinct indices.');
    final restored = SessionController.restore(
      pilotLessons.first,
      session.toJson(),
    );
    addTearDown(restored.dispose);
    expect(restored.takeaway, 'Use two distinct indices.');
    expect(restored.reflection, session.reflection);
    restored.saveTakeaway('');
    expect(restored.takeaway, isEmpty);
  });

  test('recall rating changes the next review and survives reload', () async {
    final repository = MemorySessionRepository();
    final store = PracticeStore(repository: repository);
    final lesson = pilotLessons.first;
    final first = store.startOrResume(lesson);
    first.rateRecall(RecallConfidence.confident);
    expect(first.recallConfidence, isNull);
    for (var i = 0; i < 5; i++) {
      first.submit(i == 3 ? 'print(1)' : 'My reasoning');
      first.advanceAfterSelfCheck();
    }
    expect(store.reviewSchedule.single.intervalDays, 1);
    first.rateRecall(RecallConfidence.confident);
    expect(store.reviewSchedule.single.intervalDays, 3);
    first.rateRecall(RecallConfidence.needsWork);
    expect(store.reviewSchedule.single.intervalDays, 1);
    await store.flush();
    final restored = await PracticeStore.load(repository, pilotLessons);
    expect(
      restored.sessions.single.recallConfidence,
      RecallConfidence.needsWork,
    );
    expect(restored.reviewSchedule.single.intervalDays, 1);
    restored.dispose();
    store.dispose();
  });

  test('saved work and explicit self-review are required to advance', () {
    final session = SessionController(pilotLessons.first, attemptNumber: 1);
    addTearDown(session.dispose);
    session.advanceAfterSelfCheck();
    expect(session.stage, CoachingStage.understand);
    session.submit('   ');
    expect(session.checkpointReady, isFalse);
    session.submit('A wrong answer is only saved, never AI-approved.');
    expect(session.stage, CoachingStage.understand);
    session.advanceAfterSelfCheck();
    expect(session.stage, CoachingStage.approach);
    expect(session.checkpointReady, isFalse);
  });

  test('completing self-checks never establishes a verified solve', () {
    final session = SessionController(pilotLessons.first, attemptNumber: 1);
    addTearDown(session.dispose);
    for (var i = 0; i < 5; i++) {
      session.submit(i == 3 ? 'def solve():\n    return []' : 'My reasoning');
      session.advanceAfterSelfCheck();
    }
    expect(session.stage, CoachingStage.complete);
    expect(session.verifiedSolved, isFalse);
    final count = session.messages.length;
    session.submit('extra');
    session.advanceAfterSelfCheck();
    expect(session.messages.length, count);
  });

  test(
    'hint exhaustion and repeated reveal preserve assistance accounting',
    () {
      final session = SessionController(pilotLessons.first, attemptNumber: 1);
      addTearDown(session.dispose);
      expect(session.assisted, isFalse);
      for (var i = 0; i < 10; i++) {
        session.requestHint();
      }
      expect(session.hintsUsed, 3);
      expect(session.assisted, isTrue);
      session.revealSolution();
      final count = session.messages.length;
      session.revealSolution();
      expect(session.messages.length, count);
      expect(session.solutionRevealed, isTrue);
    },
  );

  test(
    'language drafts stay separate and changes invalidate code acknowledgement',
    () {
      final session = SessionController(pilotLessons.first, attemptNumber: 1);
      addTearDown(session.dispose);
      for (var i = 0; i < 3; i++) {
        session.submit('Reasoning');
        session.advanceAfterSelfCheck();
      }
      session.submit(session.language.starter);
      expect(session.checkpointReady, isFalse);
      session.submit('print(1)');
      expect(session.checkpointReady, isTrue);
      session.changeLanguage(CodeLanguage.cpp);
      expect(session.checkpointReady, isFalse);
      session.saveDraft('int main() {}');
      session.changeLanguage(CodeLanguage.python);
      expect(session.draft, 'print(1)');
      session.saveDraft('print(2)');
      expect(session.checkpointReady, isFalse);
      session.changeLanguage(CodeLanguage.cpp);
      expect(session.draft, 'int main() {}');
    },
  );

  test('incomplete sessions resume while completed attempts are retained', () {
    final store = PracticeStore();
    addTearDown(store.dispose);
    final first = store.startOrResume(pilotLessons.first);
    expect(store.startOrResume(pilotLessons.first), same(first));
    for (var i = 0; i < 5; i++) {
      first.submit('Some saved work');
      first.advanceAfterSelfCheck();
    }
    expect(store.selfReviewed, 1);
    expect(store.startOrResume(pilotLessons.first), isNot(same(first)));
    expect(store.sessions.length, 2);
  });
}
