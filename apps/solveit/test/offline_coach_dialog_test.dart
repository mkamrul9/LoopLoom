import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/data/pilot_lessons.dart';
import 'package:looploom/app.dart';
import 'package:looploom/features/coaching/practice_screen.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/ui/looploom_theme.dart';

void main() {
  testWidgets(
    'phone Home shows its primary practice action without scrolling',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(LoopLoomApp(store: PracticeStore()));
      await tester.pumpAndSettle();
      final action = find.text('Start guided practice');
      expect(action, findsOneWidget);
      expect(tester.getBottomLeft(action).dy, lessThan(760));
    },
  );

  testWidgets(
    'offline guidance opens visibly and can be dismissed on a phone',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = PracticeStore();
      final session = store.startOrResume(pilotLessons.first);
      await tester.pumpWidget(
        MaterialApp(
          theme: studyTheme(),
          home: PracticeScreen(session: session, store: store),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Ask the offline coach'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Ask the offline coach'));
      await tester.pumpAndSettle();
      expect(find.text('What would help right now?'), findsOneWidget);
      await tester.tap(find.text('Clarify the task'));
      await tester.pumpAndSettle();
      expect(find.text('I understand'), findsOneWidget);
      expect(find.textContaining('Task check'), findsWidgets);
      await tester.tap(find.text('I understand'));
      await tester.pumpAndSettle();
      expect(find.text('I understand'), findsNothing);
      expect(session.offlineGuidance, 1);

      await tester.pumpWidget(const SizedBox());
      await store.close();
    },
  );
}
