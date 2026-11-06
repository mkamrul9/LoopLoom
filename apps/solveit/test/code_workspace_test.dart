import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looploom/data/code_specs.dart';
import 'package:looploom/data/blind75_curriculum.dart';
import 'package:looploom/data/lesson_catalog.dart';
import 'package:looploom/domain/lesson.dart';
import 'package:looploom/features/coaching/session_controller.dart';
import 'package:looploom/ui/code_workspace.dart';
import 'package:looploom/ui/looploom_theme.dart';

void main() {
  test(
    'untouched scaffolds cannot acknowledge the code checkpoint in any lesson or language',
    () {
      for (final lesson in allLessons) {
        final spec = codeSpecs[lesson.id];
        if (spec != null) expect(spec.cases.length, 3);
        final session = SessionController(lesson, attemptNumber: 1);
        for (var i = 0; i < 3; i++) {
          session.submit('Reasoning');
          session.advanceAfterSelfCheck();
        }
        for (final lang in CodeLanguage.values) {
          session.changeLanguage(lang);
          expect(
            session.starter,
            isNotEmpty,
            reason: '${lesson.id} ${lang.name}',
          );
          session.submit(session.draft);
          expect(
            session.checkpointReady,
            false,
            reason: '${lesson.id} ${lang.name}',
          );
          session.submit('My implementation');
          expect(session.checkpointReady, true);
          expect(session.verifiedSolved, false);
        }
        session.dispose();
      }
    },
  );
  test('legacy saved drafts are not replaced by new signatures', () {
    final original = SessionController(allLessons.first, attemptNumber: 1);
    original.saveDraft('// My previous unsent implementation');
    final restored = SessionController.restore(
      allLessons.first,
      original.toJson(),
    );
    expect(restored.draft, '// My previous unsent implementation');
    original.dispose();
    restored.dispose();
  });
  testWidgets(
    'Blind 75 code draft shows the official challenge and runner limits',
    (tester) async {
      final entry = blind75Entries.singleWhere(
        (problem) => problem.title == 'Reverse Linked List',
      );
      final session = SessionController(entry.lesson, attemptNumber: 1);
      for (var i = 0; i < 3; i++) {
        session.submit('My approach');
        session.advanceAfterSelfCheck();
      }
      final editor = TextEditingController(text: session.draft);
      await tester.pumpWidget(
        MaterialApp(
          theme: studyTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: CodeWorkspace(
                lessonId: entry.lesson.id,
                store: PracticeStore(),
                language: CodeLanguage.python,
                editor: editor,
                enabled: true,
                onChanged: (_) {},
                onLanguageChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('Open official LeetCode problem'), findsOneWidget);
      expect(
        find.textContaining('Set a self-hosted runner address'),
        findsOneWidget,
      );
      expect(find.text('Run reference cases'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      editor.dispose();
      session.dispose();
    },
  );
  testWidgets(
    'phone editor inserts spaces at selection and opens honest reference cases',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final editor = TextEditingController(text: 'abcdef');
      String? saved;
      await tester.pumpWidget(
        MaterialApp(
          theme: studyTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: CodeWorkspace(
                  lessonId: 'signal-ranges-v1',
                  store: PracticeStore(),
                  language: CodeLanguage.python,
                  editor: editor,
                  enabled: true,
                  onChanged: (v) => saved = v,
                  onLanguageChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      editor.selection = const TextSelection(baseOffset: 2, extentOffset: 4);
      await tester.ensureVisible(find.text('Insert 4 spaces'));
      await tester.tap(find.text('Insert 4 spaces'));
      await tester.pumpAndSettle();
      expect(editor.text, 'ab    ef');
      expect(saved, editor.text);
      expect(editor.selection.baseOffset, 6);
      expect(
        find.text('6'),
        findsNothing,
      ); // Expected results remain folded away.
      await tester.ensureVisible(
        find.text('Reference cases · expected results'),
      );
      await tester.tap(find.text('Reference cases · expected results'));
      await tester.pumpAndSettle();
      expect(find.text('6'), findsOneWidget);
      expect(find.text('changes = [0, 0, 0], target = 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      editor.dispose();
    },
  );
}
