import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/data/pilot_lessons.dart';
import 'package:looploom/app.dart';
import 'package:looploom/features/coaching/practice_screen.dart';
import 'package:looploom/features/coaching/coach_provider.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/ui/looploom_theme.dart';

class _ReplyCoach implements CoachProvider {
  _ReplyCoach({this.fail = false});
  final bool fail;
  @override
  bool get enabled => true;
  @override
  Future<CoachReview> review(Map<String, Object?> request) async {
    if (fail) {
      throw const CoachUnavailable('AI is unavailable. Try offline review.');
    }
    return const CoachReview(
      outcome: 'needs_clarification',
      feedback: 'Your input-output statement is likely sound for this step.',
      question: 'Which boundary case would you check?',
    );
  }

  @override
  void close() {}
}

void main() {
  testWidgets('AI review opens feedback and unlocks the next step', (
    tester,
  ) async {
    final store = PracticeStore(coach: _ReplyCoach());
    final session = store.startOrResume(pilotLessons.first);
    session.submit('I identify the exact input and output.');
    await tester.pumpWidget(
      MaterialApp(
        theme: studyTheme(),
        home: PracticeScreen(session: session, store: store),
      ),
    );
    expect(find.text('Review with AI'), findsOneWidget);
    expect(find.text('I checked my work · continue'), findsNothing);
    await tester.ensureVisible(find.text('Review with AI'));
    await tester.tap(find.text('Review with AI'));
    await tester.pumpAndSettle();
    expect(find.text('AI coach suggestion'), findsOneWidget);
    expect(find.textContaining('likely sound'), findsWidgets);
    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();
    expect(find.text('I checked my work · continue'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await store.close();
  });

  testWidgets('AI failure is visible and offline review stays available', (
    tester,
  ) async {
    final store = PracticeStore(coach: _ReplyCoach(fail: true));
    final session = store.startOrResume(pilotLessons.first);
    session.submit('I identify the exact input and output.');
    await tester.pumpWidget(
      MaterialApp(
        theme: studyTheme(),
        home: PracticeScreen(session: session, store: store),
      ),
    );
    await tester.ensureVisible(find.text('Review with AI'));
    await tester.tap(find.text('Review with AI'));
    await tester.pumpAndSettle();
    expect(find.text('AI coach unavailable'), findsOneWidget);
    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();
    expect(find.text('Review offline'), findsOneWidget);
    expect(find.text('I checked my work · continue'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await store.close();
  });

  testWidgets('one primary step action appears at each stage', (tester) async {
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
    expect(find.text('Save my thinking'), findsOneWidget);
    expect(find.text('Review offline'), findsNothing);
    expect(find.text('I checked my work · continue'), findsNothing);
    await tester.enterText(
      find.byType(TextField).first,
      'The input is a list and I need to return the requested result.',
    );
    await tester.pumpAndSettle();
    expect(session.reasoningDraft, isNotEmpty);
    await tester.scrollUntilVisible(
      find.text('Save my thinking'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save my thinking'));
    await tester.pumpAndSettle();
    expect(find.text('Save my thinking'), findsNothing);
    expect(find.text('Review offline'), findsOneWidget);
    expect(find.text('I checked my work · continue'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Review offline'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Review offline'));
    await tester.pumpAndSettle();
    expect(find.text('Review your thinking'), findsOneWidget);
    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();
    expect(find.text('I checked my work · continue'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('I checked my work · continue'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('I checked my work · continue'));
    await tester.pumpAndSettle();
    expect(session.stage.index, 1);
    await tester.pumpWidget(const SizedBox());
    await store.close();
  });

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
      session.submit('I will describe the input and output first.');
      await tester.pumpWidget(
        MaterialApp(
          theme: studyTheme(),
          home: PracticeScreen(session: session, store: store),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('More options'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('More options'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Explore offline prompts'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Explore offline prompts'));
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
  testWidgets('explanation opens over practice and can be reopened', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = PracticeStore();
    final session = store.startOrResume(pilotLessons.first);
    session.submit('I will describe the input and output first.');
    await tester.pumpWidget(
      MaterialApp(
        theme: studyTheme(),
        home: PracticeScreen(session: session, store: store),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('More options'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('More options'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Reveal explanation'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reveal explanation'));
    await tester.pumpAndSettle();
    expect(find.text('Reveal the explanation?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Reveal explanation'));
    await tester.pumpAndSettle();
    expect(find.text('Solution explanation'), findsOneWidget);
    expect(find.text('I understand'), findsOneWidget);
    await tester.tap(find.text('I understand'));
    await tester.pumpAndSettle();
    expect(session.solutionRevealed, isTrue);
    await tester.scrollUntilVisible(
      find.text('View explanation'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('View explanation'));
    await tester.pumpAndSettle();
    expect(find.text('Solution explanation'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await store.close();
  });
}
