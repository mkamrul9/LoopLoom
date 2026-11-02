import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solveit/features/coaching/session_controller.dart';
import 'package:solveit/ui/settings_screen.dart';
import 'package:solveit/ui/solveit_theme.dart';

void main() {
  testWidgets('profile, practice targets, and readable size can be saved', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    await tester.pumpWidget(
      MaterialApp(
        theme: studyTheme(),
        home: SettingsScreen(store: store),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Name or nickname'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextField).at(0), 'Ari');
    await tester.scrollUntilVisible(
      find.text('Target role (optional)'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextField).at(1), 'Backend engineer');
    await tester.scrollUntilVisible(
      find.text('PRACTICE DAYS EACH WEEK'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('4 days'));
    await tester.scrollUntilVisible(
      find.text('DAILY PRACTICE TARGET'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('45 min'));
    await tester.scrollUntilVisible(
      find.text('Save profile and goals'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save profile and goals'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Large'),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();

    expect(store.preferences.displayName, 'Ari');
    expect(store.preferences.targetRole, 'Backend engineer');
    expect(store.preferences.weeklyGoalDays, 4);
    expect(store.preferences.dailyGoalMinutes, 45);
    expect(store.preferences.textScale, 1.3);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await store.close();
  });
}
