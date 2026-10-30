import 'package:flutter_test/flutter_test.dart';
import 'package:solveit/data/pilot_lessons.dart';
import 'package:solveit/domain/lesson.dart';
import 'package:solveit/features/coaching/session_controller.dart';

void main() {
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
