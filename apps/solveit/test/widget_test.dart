import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solveit/app.dart';
import 'package:solveit/data/pilot_lessons.dart';
import 'package:solveit/data/interview_lessons.dart';
import 'package:solveit/features/coaching/practice_screen.dart';
import 'package:solveit/features/coaching/session_controller.dart';
import 'package:solveit/domain/learner_preferences.dart';
import 'package:solveit/domain/lesson.dart';

void main() {
  testWidgets(
    'an older saved question does not override current checkpoint guidance',
    (tester) async {
      final store = PracticeStore();
      final original = store.startOrResume(interviewLessons.first);
      for (var i = 0; i < 3; i++) {
        original.submit('Reasoning');
        original.advanceAfterSelfCheck();
      }
      final snapshot = original.toJson();
      final messages = snapshot['messages'] as List;
      (messages.last as Map)['text'] = 'Obsolete code execution instruction';
      final restored = SessionController.restore(
        interviewLessons.first,
        snapshot,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: PracticeScreen(session: restored, store: store),
        ),
      );
      expect(find.text('Obsolete code execution instruction'), findsNothing);
      expect(find.text(interviewLessons.first.questions[3]), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      restored.dispose();
      await store.close();
    },
  );
  testWidgets('roadmap progress counts only its own track', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    for (final lesson in [pilotLessons.first, interviewLessons.first]) {
      final session = store.startOrResume(lesson);
      for (var i = 0; i < 5; i++) {
        session.submit(i == 3 ? 'my implementation' : 'my reasoning');
        session.advanceAfterSelfCheck();
      }
    }
    await tester.pumpWidget(SolveItApp(store: store));
    await tester.tap(find.text('Roadmaps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Intermediate · 27'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 of 27 self-reviewed'), findsOneWidget);
    expect(find.text('Intermediate foundations'), findsOneWidget);
    await tester.tap(find.text('Warm-ups · 3'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 of 3 self-reviewed'), findsOneWidget);
    expect(find.text('Interview warm-ups'), findsOneWidget);
  });
  testWidgets('phone backup review restores only after the restore action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = PracticeStore();
    source
        .startOrResume(pilotLessons.first)
        .saveReasoningDraft('Recover this draft');
    final backup = source.exportBackup();
    final target = PracticeStore();
    await tester.pumpWidget(SolveItApp(store: target));
    await tester.tap(find.byTooltip('Workbook options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Workbook backup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), backup);
    await tester.ensureVisible(find.text('Review backup'));
    await tester.tap(find.text('Review backup'));
    await tester.pumpAndSettle();
    expect(target.sessions, isEmpty);
    await tester.ensureVisible(find.text('Restore missing attempts'));
    await tester.tap(find.text('Restore missing attempts'));
    await tester.pumpAndSettle();
    expect(target.sessions.single.reasoningDraft, 'Recover this draft');
    expect(find.textContaining('1 attempts restored.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await source.close();
  });
  testWidgets('phone layout opens an honest guided session', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(SolveItApp(store: PracticeStore()));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Start guided practice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start guided practice'));
    await tester.pumpAndSettle();
    expect(find.text('The problem'), findsOneWidget);
    expect(find.textContaining('No AI grading'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text remains usable in home and guided practice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore()
      ..preferences = const LearnerPreferences(textScale: 1.3);
    await tester.pumpWidget(SolveItApp(store: store));
    final homeException = tester.takeException();
    if (homeException is FlutterError) {
      debugPrint(homeException.toStringDeep());
    }
    expect(homeException, isNull);
    await tester.ensureVisible(find.text('Start guided practice'));
    await tester.tap(find.text('Start guided practice'));
    await tester.pumpAndSettle();
    expect(find.text('The problem'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await store.close();
  });

  testWidgets('wide layout shows roadmaps and real empty history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(SolveItApp(store: PracticeStore()));
    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.text('Roadmaps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Intermediate · 27'));
    await tester.pumpAndSettle();
    expect(find.text('Intermediate foundations'), findsOneWidget);
    await tester.tap(find.text('Warm-ups · 3'));
    await tester.pumpAndSettle();
    expect(find.text('Interview warm-ups'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Your first attempt starts here.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('starter roadmap includes all thirty available lessons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(SolveItApp(store: PracticeStore()));
    await tester.tap(find.text('Roadmaps'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Starter 30 · 30'));
    await tester.pumpAndSettle();
    expect(find.text('Starter 30'), findsOneWidget);
    expect(find.textContaining('0 of 30 self-reviewed'), findsOneWidget);
    expect(find.text('The supply pair'), findsOneWidget);
    expect(find.text('Mastery / 300'), findsOneWidget);
  });

  testWidgets('phone settings update coaching pace and default language', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    await tester.pumpWidget(SolveItApp(store: store));
    await tester.tap(find.byTooltip('Workbook options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile & settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Beginner'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Beginner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('TypeScript'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TypeScript'));
    await tester.pumpAndSettle();
    expect(store.preferences.pace, CoachingPace.beginner);
    expect(store.preferences.preferredLanguage, CodeLanguage.typescript);
    expect(tester.takeException(), isNull);
    await store.close();
  });

  testWidgets('Blind 75 roadmap opens its phase and pattern groups', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(SolveItApp(store: PracticeStore()));
    await tester.tap(find.text('Roadmaps'));
    await tester.pumpAndSettle();
    expect(find.textContaining('0 of 75 self-reviewed'), findsOneWidget);
    expect(find.text('Phase 1 · Sequences and search'), findsOneWidget);
    await tester.ensureVisible(find.text('Array scans & hashing'));
    await tester.tap(find.text('Array scans & hashing'));
    await tester.pumpAndSettle();
    expect(find.text('Contains Duplicate'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Container With Most Water');
    await tester.pumpAndSettle();
    expect(find.textContaining('1 of 75 problems'), findsOneWidget);
    expect(find.text('Container With Most Water'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('focus view hides context without losing the reasoning draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(SolveItApp(store: PracticeStore()));
    await tester.ensureVisible(find.text('Start guided practice'));
    await tester.tap(find.text('Start guided practice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Focus'));
    await tester.pumpAndSettle();
    expect(find.text('Problem & examples'), findsOneWidget);
    expect(find.text('The problem'), findsNothing);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(
      find.byType(TextField),
      'I will compare the alternatives.',
    );
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    expect(find.text('The problem'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'I will compare the alternatives.',
    );
    expect(tester.takeException(), isNull);
  });
}
