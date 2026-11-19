import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/app.dart';
import 'package:looploom/data/mastery300_curriculum.dart';
import 'package:looploom/domain/lesson.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/features/patterns/pattern_library.dart';

void main() {
  test('the standalone learning curriculum covers its own families', () {
    expect(patternLessons.length, patternLearningFamilies.length);
    expect(
      patternLessons.map((lesson) => lesson.category).toSet(),
      patternLearningFamilies.toSet(),
    );
    expect(
      patternLessons.map((lesson) => lesson.title).toSet().length,
      patternLessons.length,
    );
    expect(
      patternTemplates.keys.toSet(),
      patternLessons.map((lesson) => lesson.title).toSet(),
    );
    for (final lesson in patternLessons) {
      expect(lesson.recognize, isNotEmpty);
      expect(lesson.code.keys.toSet(), CodeLanguage.values.toSet());
      expect(
        patternTemplates[lesson.title]!.keys.toSet(),
        CodeLanguage.values.toSet(),
      );
      expect(lesson.frames, isNotEmpty);
      for (final frame in lesson.frames) {
        expect(frame.state, isNotEmpty);
        expect(frame.active, isNotEmpty);
        for (final index in frame.active) {
          expect(index, inInclusiveRange(0, lesson.tokens.length - 1));
        }
      }
    }
  });

  test('optional practice links resolve in the shared problem catalog', () {
    final slugs = mastery300Entries.map((entry) => entry.slug).toSet();
    for (final lesson in patternLessons) {
      expect(slugs, contains(lesson.problemSlug));
    }
  });

  testWidgets('every pattern animates a changing state on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final lesson in patternLessons) {
      await tester.pumpWidget(
        MaterialApp(
          home: PatternLessonScreen(
            key: ValueKey(lesson.category),
            lesson: lesson,
          ),
        ),
      );
      await tester.tap(find.text('Dry run'));
      await tester.pumpAndSettle();
      expect(find.text('Try a related problem'), findsNothing);
      expect(find.byKey(const Key('pattern-diagram')), findsOneWidget);
      expect(find.text(lesson.frames.first.state), findsOneWidget);
      await tester.ensureVisible(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(
        find.text(lesson.frames[1].state),
        findsOneWidget,
        reason: lesson.category,
      );
      expect(tester.takeException(), isNull, reason: lesson.category);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('phone learner can follow a dry run and open practice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    await tester.pumpWidget(LoopLoomApp(store: store));
    await tester.tap(find.text('Patterns'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hash map lookup'));
    await tester.pumpAndSettle();
    expect(find.text('How to recognize it'), findsOneWidget);
    await tester.tap(find.text('Dry run'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Start at 2'), findsOneWidget);
    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Move to 7'), findsOneWidget);
    await tester.tap(find.text('Code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TypeScript'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Map<number, number>'), findsOneWidget);
    expect(find.text('Reusable template'), findsOneWidget);
    expect(find.text('Copy code'), findsOneWidget);
    await tester.tap(find.text('Worked code'));
    await tester.pumpAndSettle();
    expect(find.textContaining('function twoSum'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Try a related problem'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Try a related problem'));
    await tester.pumpAndSettle();
    expect(find.text('The supply pair'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await store.close();
  });

  testWidgets('dry run play advances, pauses, and can replay', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lesson = patternLessons.first;
    await tester.pumpWidget(
      MaterialApp(home: PatternLessonScreen(lesson: lesson)),
    );
    await tester.tap(find.text('Dry run'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 1550));
    expect(find.text(lesson.frames[1].state), findsOneWidget);
    await tester.tap(find.text('Pause'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(lesson.frames[1].state), findsOneWidget);
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 3200));
    expect(find.text(lesson.frames.last.state), findsOneWidget);
    expect(find.text('Replay'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('pattern search finds a later family and can be cleared', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: const PatternLibrary()),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('pattern-search')), 'bit');
    await tester.pumpAndSettle();
    expect(find.text('XOR cancellation'), findsOneWidget);
    expect(find.text('Hash map lookup'), findsNothing);
    await tester.tap(find.byTooltip('Clear pattern search'));
    await tester.pumpAndSettle();
    expect(find.text('Hash map lookup'), findsOneWidget);
  });
}
