import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solveit/app.dart';
import 'package:solveit/data/pilot_lessons.dart';
import 'package:solveit/data/interview_lessons.dart';
import 'package:solveit/features/coaching/session_controller.dart';

void main() {
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
    expect(find.textContaining('1 of 3 self-reviewed'), findsOneWidget);
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
    await tester.tap(find.byTooltip('Workbook backup'));
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
    expect(find.text('Intermediate foundations'), findsOneWidget);
    await tester.tap(find.text('Warm-ups · 3'));
    await tester.pumpAndSettle();
    expect(find.text('Interview warm-ups'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Your first attempt starts here.'), findsOneWidget);
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
