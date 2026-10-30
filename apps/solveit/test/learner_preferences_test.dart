import 'package:flutter_test/flutter_test.dart';
import 'package:solveit/data/pilot_lessons.dart';
import 'package:solveit/data/session_repository.dart';
import 'package:solveit/domain/learner_preferences.dart';
import 'package:solveit/domain/lesson.dart';
import 'package:solveit/features/coaching/session_controller.dart';

class FailingPreferenceRepository extends MemorySessionRepository {
  bool failPreferences = true;

  @override
  Future<void> savePreferences(Map<String, Object?> value) async {
    if (failPreferences) throw StateError('Settings storage unavailable');
    await super.savePreferences(value);
  }
}

void main() {
  test(
    'support modes add stage-specific scaffolding without replacing lesson questions',
    () {
      const question = 'Explain the invariant.';
      expect(
        CoachingPace.intermediate.prompt(CoachingStage.approach, question),
        question,
      );
      expect(
        CoachingPace.beginner
            .prompt(CoachingStage.approach, question)
            .startsWith(question),
        isTrue,
      );
      expect(
        CoachingPace.beginner
            .prompt(CoachingStage.approach, question)
            .contains('simplest correct method'),
        isTrue,
      );
      expect(
        CoachingPace.advanced
            .prompt(CoachingStage.approach, question)
            .contains('invariant'),
        isTrue,
      );
    },
  );

  test('pace and preferred language persist and seed attempts', () async {
    final repository = MemorySessionRepository();
    final store = await PracticeStore.load(repository, pilotLessons);
    await store.updatePreferences(
      const LearnerPreferences(
        pace: CoachingPace.beginner,
        preferredLanguage: CodeLanguage.typescript,
      ),
    );
    final session = store.startOrResume(pilotLessons.first);
    expect(session.pace, CoachingPace.beginner);
    expect(session.language, CodeLanguage.typescript);
    expect(session.question, contains('Start with three short notes'));
    await store.close();

    final restored = await PracticeStore.load(repository, pilotLessons);
    expect(restored.preferences.pace, CoachingPace.beginner);
    expect(restored.preferences.preferredLanguage, CodeLanguage.typescript);
    expect(restored.sessions.single.pace, CoachingPace.beginner);
    expect(restored.sessions.single.language, CodeLanguage.typescript);
    await restored.close();
  });

  test(
    'settings retry does not overwrite the separate session save status',
    () async {
      final repository = FailingPreferenceRepository();
      final store = await PracticeStore.load(repository, pilotLessons);
      await expectLater(
        store.updatePreferences(
          const LearnerPreferences(pace: CoachingPace.advanced),
        ),
        throwsStateError,
      );
      expect(store.preferencesSaveFailed, isTrue);
      expect(store.saveFailed, isFalse);
      repository.failPreferences = false;
      await store.retrySave();
      expect(store.preferencesSaveFailed, isFalse);
      expect(repository.preferences?['pace'], CoachingPace.advanced.name);
      await store.close();
    },
  );
}
