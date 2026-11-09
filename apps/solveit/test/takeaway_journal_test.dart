import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/app.dart';
import 'package:looploom/data/pilot_lessons.dart';
import 'package:looploom/features/coaching/session_controller.dart';

void main() {
  testWidgets('History opens and edits a saved reflection takeaway', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    final session = store.startOrResume(pilotLessons.first);
    for (var i = 0; i < 5; i++) {
      session.submit(
        i == 3
            ? 'print(1)'
            : i == 4
            ? 'Check repeated values before choosing indices.'
            : 'My reasoning',
      );
      session.advanceAfterSelfCheck();
    }
    session.saveTakeaway('Use distinct indices.');

    await tester.pumpWidget(LoopLoomApp(store: store));
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Insights & mistakes'));
    await tester.tap(find.text('Insights & mistakes'));
    await tester.pumpAndSettle();
    expect(find.text('Use distinct indices.'), findsOneWidget);
    await tester.tap(find.text('Use distinct indices.'));
    await tester.pumpAndSettle();
    expect(
      find.text('Check repeated values before choosing indices.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Edit takeaway'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Trace indices first.');
    await tester.tap(find.text('Save takeaway'));
    await tester.pumpAndSettle();
    expect(session.takeaway, 'Trace indices first.');
    await tester.pumpWidget(const SizedBox());
    await store.close();
  });
}
