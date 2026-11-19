import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/app.dart';
import 'package:looploom/data/pilot_lessons.dart';
import 'package:looploom/data/session_repository.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/features/essentials/sql_course.dart';

void main() {
  test('SQL course has complete, coherent lesson data', () {
    expect(sqlLessons.length, 21);
    expect(
      sqlLessons.map((lesson) => lesson.id).toSet().length,
      sqlLessons.length,
    );
    for (final unit in sqlCourseUnits) {
      expect(sqlLessons.where((lesson) => lesson.unit == unit), isNotEmpty);
    }
    for (final lesson in sqlLessons) {
      expect(lesson.concept, isNotEmpty);
      expect(lesson.why, isNotEmpty);
      expect(lesson.when, isNotEmpty);
      expect(lesson.operation, isNotEmpty);
      expect(lesson.sql, isNotEmpty);
      expect(lesson.application, isNotEmpty);
      expect(lesson.appCode, isNotEmpty);
      expect(lesson.alternative, isNotEmpty);
      expect(lesson.pitfall, isNotEmpty);
      expect(lesson.traceInput, isNotEmpty);
      expect(lesson.trace.length, greaterThanOrEqualTo(3));
      expect(lesson.check, isNotEmpty);
      expect(lesson.answer, isNotEmpty);
      for (final step in lesson.trace) {
        expect(step.title, isNotEmpty);
        expect(step.explanation, isNotEmpty);
        expect(step.output, isNotEmpty);
        for (final index in step.active) {
          expect(index, inInclusiveRange(0, lesson.traceInput.length - 1));
        }
      }
    }
  });

  test('lesson progress survives local preference restore', () async {
    final repository = MemorySessionRepository();
    final store = await PracticeStore.load(repository, pilotLessons);
    await store.setEssentialsLessonComplete(sqlLessons.first.id, true);
    await store.close();
    final restored = await PracticeStore.load(repository, pilotLessons);
    expect(
      restored.preferences.completedEssentialsLessonIds,
      contains(sqlLessons.first.id),
    );
    await restored.setEssentialsLessonComplete(sqlLessons.first.id, false);
    expect(restored.preferences.completedEssentialsLessonIds, isEmpty);
    await restored.close();
  });

  testWidgets('phone learner can open, animate, and complete a SQL lesson', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    await tester.pumpWidget(LoopLoomApp(store: store));
    await tester.tap(find.text('Essentials'));
    await tester.pumpAndSettle();
    expect(find.text('Build with data.'), findsOneWidget);
    await tester.ensureVisible(
      find.text('Start with ${sqlLessons.first.title}'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start with ${sqlLessons.first.title}'));
    await tester.pumpAndSettle();
    expect(find.text(sqlLessons.first.concept), findsOneWidget);
    await tester.tap(find.text('Visual'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sql-trace')), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(sqlLessons.first.trace[1].title),
      findsOneWidget,
    );
    await tester.tap(find.text('In software'));
    await tester.pumpAndSettle();
    expect(find.text(sqlLessons.first.application), findsOneWidget);
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reveal answer'));
    await tester.pumpAndSettle();
    expect(find.text(sqlLessons.first.answer), findsOneWidget);
    await tester.ensureVisible(find.text('Mark lesson complete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark lesson complete'));
    await tester.pumpAndSettle();
    expect(
      store.preferences.completedEssentialsLessonIds,
      contains(sqlLessons.first.id),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await store.close();
  });

  testWidgets('Essentials navigation fits a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    await tester.pumpWidget(LoopLoomApp(store: store));
    await tester.tap(find.text('Essentials'));
    await tester.pumpAndSettle();
    expect(find.text('Build with data.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await store.close();
  });
}
