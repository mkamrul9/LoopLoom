import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/data/pilot_lessons.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/ui/backup_screen.dart';
import 'package:looploom/ui/looploom_theme.dart';

void main() {
  testWidgets('restore review offers an explicit study settings choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = PracticeStore();
    await source.updatePreferences(
      source.preferences.copyWith(displayName: 'Ari'),
    );
    source.startOrResume(pilotLessons.first);
    final backup = source.exportBackup();
    final target = PracticeStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: studyTheme(),
        home: BackupScreen(store: target),
      ),
    );

    final input = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Backup JSON',
    );
    await tester.scrollUntilVisible(
      input,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(input, backup);
    tester.testTextInput.hide();
    await tester.scrollUntilVisible(
      find.text('Review backup'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Review backup'));
    await tester.pumpAndSettle();
    expect(find.text('Restore profile & study settings'), findsOneWidget);
    expect(target.preferences.displayName, isEmpty);
    await tester.scrollUntilVisible(
      find.text('Restore profile & study settings'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Restore profile & study settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Restore workbook and settings'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Restore workbook and settings'));
    await tester.pumpAndSettle();
    expect(target.preferences.displayName, 'Ari');
    expect(target.sessions, hasLength(1));

    await tester.pumpWidget(const SizedBox());
    await target.close();
    await source.close();
  });
}
