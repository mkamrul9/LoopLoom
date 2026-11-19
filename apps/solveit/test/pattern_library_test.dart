import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/app.dart';
import 'package:looploom/data/mastery300_curriculum.dart';
import 'package:looploom/domain/lesson.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/features/patterns/pattern_library.dart';

void main() {
  test('every pattern lesson has a valid example and practice problem', () {
    final slugs = mastery300Entries.map((entry) => entry.slug).toSet();
    expect(patternLessons.length, 6);
    expect(patternLessons.map((lesson) => lesson.title).toSet().length, 6);
    for (final lesson in patternLessons) {
      expect(slugs, contains(lesson.problemSlug));
      expect(lesson.code.keys.toSet(), CodeLanguage.values.toSet());
      expect(lesson.frames, isNotEmpty);
      for (final frame in lesson.frames) {
        expect(frame.active, isNotEmpty);
        for (final index in frame.active) {
          expect(index, inInclusiveRange(0, lesson.tokens.length - 1));
        }
      }
    }
  });

  testWidgets('phone learner can follow a dry run and open practice', (tester) async {
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
    await tester.tap(find.text('Dry run'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Start at 2'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Move to 7'), findsOneWidget);
    await tester.tap(find.text('Code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TypeScript'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Map<number, number>'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Practice: The supply pair'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Practice: The supply pair'));
    await tester.pumpAndSettle();
    expect(find.text('The supply pair'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await store.close();
  });
}
