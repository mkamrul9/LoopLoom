import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:looploom/data/code_specs.dart';
import 'package:looploom/data/interview_sprints.dart';
import 'package:looploom/data/lesson_catalog.dart';
import 'package:looploom/data/session_repository.dart';
import 'package:looploom/data/sprint_references.dart';
import 'package:looploom/domain/learner_preferences.dart';
import 'package:looploom/domain/lesson.dart';
import 'package:looploom/features/coaching/reference_runner.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/ui/code_workspace.dart';
import 'package:looploom/ui/looploom_theme.dart';

void main() {
  test(
    'all sprint problems have case suites, edge cases, and four code variants',
    () {
      final ids = oneWeekInterviewSprint.lessons
          .map((lesson) => lesson.id)
          .toSet();
      expect(ids.length, 25);
      expect(
        lastDayInterviewSprint.lessons.every(
          (lesson) => ids.contains(lesson.id),
        ),
        isTrue,
      );
      for (final id in ids) {
        expect(codeSpecs[id]?.cases.length, 3, reason: id);
        expect(
          sprintReferences[id]?.edgeCases.length,
          greaterThanOrEqualTo(2),
          reason: id,
        );
        expect(sprintReferences[id]?.code.length, 4, reason: id);
      }
    },
  );

  test('unlock charges ten points once and survives local reload', () async {
    final repository = MemorySessionRepository();
    final store = PracticeStore(repository: repository);
    final id = oneWeekInterviewSprint.lessons.first.id;
    expect(store.preferences.pointsBalance, 10000);
    expect(await store.unlockReferenceCode(id), isTrue);
    expect(store.preferences.pointsBalance, 9990);
    expect(await store.unlockReferenceCode(id), isTrue);
    expect(store.preferences.pointsBalance, 9990);
    expect(await store.unlockReferenceCode('unknown'), isFalse);
    final restored = LearnerPreferences.fromJson(
      (await repository.loadPreferences())!,
    );
    expect(restored.pointsBalance, 9990);
    expect(restored.unlockedReferenceIds, contains(id));
    final target = PracticeStore();
    await target.importBackup(
      target.inspectBackup(store.exportBackup(), allLessons),
      allLessons,
    );
    expect(target.preferences.unlockedReferenceIds, contains(id));
    expect(target.preferences.pointsBalance, 9990);
    target.dispose();
    store.dispose();
  });

  test('private LAN runner requires a token and sends it with code', () async {
    const token = '12345678901234567890123456789012';
    expect(
      () => ReferenceRunnerClient('http://192.168.1.20:8766'),
      throwsArgumentError,
    );
    expect(
      () => ReferenceRunnerClient('http://8.8.8.8:8766', token: token),
      throwsArgumentError,
    );
    final client = ReferenceRunnerClient(
      'http://192.168.1.20:8766',
      token: token,
      client: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer $token');
        expect(
          jsonDecode(request.body)['lesson_id'],
          oneWeekInterviewSprint.lessons.first.id,
        );
        final cases = codeSpecs[oneWeekInterviewSprint.lessons.first.id]!.cases;
        return http.Response(
          jsonEncode({
            'suite': 'reference-v1',
            'language': 'python',
            'verified_solve': false,
            'total': cases.length,
            'passed': cases.length,
            'cases': [
              for (final item in cases)
                {'label': item.label, 'status': 'matched'},
            ],
          }),
          200,
        );
      }),
    );
    final result = await client.run(
      oneWeekInterviewSprint.lessons.first.id,
      'def solve(a,b): return []',
      language: 'python',
    );
    expect(result.passed, 3);
    client.close();
  });

  testWidgets('reference code stays hidden until the ten-point confirmation', (tester) async {
    final store = PracticeStore();
    final lessonId = oneWeekInterviewSprint.lessons.first.id;
    final editor = TextEditingController(text: 'def solve(a,b): return []');
    await tester.pumpWidget(MaterialApp(
      theme: studyTheme(),
      home: Scaffold(body: SingleChildScrollView(child: ListenableBuilder(
        listenable: store,
        builder: (_, _) => CodeWorkspace(
          lessonId: lessonId,
          store: store,
          language: CodeLanguage.python,
          editor: editor,
          enabled: true,
          onChanged: (_) {},
          onLanguageChanged: (_) {},
        ),
      ))),
    ));
    expect(find.textContaining('Reference code · unlocked'), findsNothing);
    await tester.ensureVisible(find.text('Reveal code · 10 points'));
    await tester.tap(find.text('Reveal code · 10 points'));
    await tester.pumpAndSettle();
    expect(store.preferences.pointsBalance, 10000);
    await tester.tap(find.text('Unlock · 10 points'));
    await tester.pumpAndSettle();
    expect(store.preferences.pointsBalance, 9990);
    expect(find.text('Reference code · unlocked'), findsOneWidget);
    await tester.ensureVisible(find.text('Reference code · unlocked'));
    await tester.tap(find.text('Reference code · unlocked'));
    await tester.pumpAndSettle();
    expect(find.textContaining('def solve'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    editor.dispose();
    store.dispose();
  });
}
