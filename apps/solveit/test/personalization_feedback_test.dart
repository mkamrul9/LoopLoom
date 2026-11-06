import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:looploom/data/path_recommendation.dart';
import 'package:looploom/domain/learner_preferences.dart';
import 'package:looploom/ui/feedback_screen.dart';
import 'package:looploom/ui/onboarding_screen.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/ui/looploom_theme.dart';

void main() {
  test('profile setup remains optional and never changes the chosen track', () {
    const initial = LearnerPreferences(selectedTrack: 4);
    expect(recommendPath(initial), isNull);
    final profile = initial.copyWith(
      experienceLevel: ExperienceLevel.beginner,
      onboardingSeen: true,
    );
    expect(recommendPath(profile)?.trackIndex, 2);
    expect(profile.selectedTrack, 4);
    final restored = LearnerPreferences.fromJson(profile.toJson());
    expect(restored.experienceLevel, ExperienceLevel.beginner);
    expect(restored.onboardingSeen, isTrue);
    expect(restored.selectedTrack, 4);
    expect(
      restored.copyWith(clearExperienceLevel: true).experienceLevel,
      isNull,
    );
  });

  test('short check refines the path without asserting coding readiness', () {
    final low = const LearnerPreferences().copyWith(
      diagnosticCompletedAt: DateTime.utc(2026, 11, 6),
      diagnosticScores: {'arrays': 0, 'graphs': 0},
    );
    expect(recommendPath(low)?.trackIndex, 2);
    expect(recommendPath(low)?.reason, contains('not a measure'));
    final high = low.copyWith(
      diagnosticScores: {for (var i = 0; i < 8; i++) 'pattern-$i': 1},
    );
    expect(recommendPath(high)?.trackIndex, 3);
  });

  test('near interview date suggests a sprint when foundations are ready', () {
    final profile = const LearnerPreferences(
      experienceLevel: ExperienceLevel.intermediate,
    ).copyWith(targetInterviewDate: DateTime(2026, 11, 7));
    expect(recommendPath(profile, now: DateTime(2026, 11, 6))?.trackIndex, 6);
    expect(recommendPath(profile, now: DateTime(2026, 11, 20))?.trackIndex, 5);
  });

  test('feedback creates a draft for the confirmed address', () {
    final uri = feedbackMailto(FeedbackCategory.bug, 'Problem 12 freezes');
    expect(uri.scheme, 'mailto');
    expect(uri.path, 'cdkamrul9@gmail.com');
    expect(uri.queryParameters['subject'], 'LoopLoom bug report');
    expect(uri.queryParameters['body'], 'Problem 12 freezes');
  });

  testWidgets(
    'optional setup saves an experience and preserves roadmap choice',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = PracticeStore();
      await store.updatePreferences(
        store.preferences.copyWith(selectedTrack: 4),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: studyTheme(),
          home: OnboardingScreen(store: store),
        ),
      );
      await tester.tap(find.text('Practicing interviews'));
      await tester.scrollUntilVisible(
        find.text('Save and explore'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Save and explore'));
      await tester.pumpAndSettle();
      expect(store.preferences.experienceLevel, ExperienceLevel.intermediate);
      expect(store.preferences.onboardingSeen, isTrue);
      expect(store.preferences.selectedTrack, 4);
      store.dispose();
    },
  );
}
