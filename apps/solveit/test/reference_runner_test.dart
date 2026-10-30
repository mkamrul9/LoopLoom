import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solveit/data/code_specs.dart';
import 'package:solveit/domain/lesson.dart';
import 'package:solveit/features/coaching/reference_runner.dart';
import 'package:solveit/ui/reference_run_panel.dart';

Map<String, Object?> goodReply() => {
  'suite': 'reference-v1',
  'language': 'javascript',
  'passed': 3,
  'total': 3,
  'verified_solve': false,
  'cases': codeSpecs['signal-ranges-v1']!.cases
      .map((c) => {'label': c.label, 'status': 'matched'})
      .toList(),
};

void main() {
  test('server reference fixtures match the visible input contracts', () {
    final suite =
        jsonDecode(
              File(
                '../../services/reference_runner/cases.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(suite.keys.toSet(), codeSpecs.keys.toSet());
    for (final entry in codeSpecs.entries) {
      final rows = suite[entry.key] as List;
      expect(rows.length, entry.value.cases.length);
      for (var i = 0; i < rows.length; i++) {
        expect(rows[i]['label'], entry.value.cases[i].label);
        final args = rows[i]['args'] as List;
        final input = entry.value.names.indexed
            .map((name) => '${name.$2}=${jsonEncode(args[name.$1])}')
            .join(',');
        expect(entry.value.cases[i].input.replaceAll(' ', ''), input);
        expect(
          entry.value.cases[i].expected.replaceAll(' ', ''),
          contains(jsonEncode(rows[i]['expected'])),
        );
      }
    }
  });
  test(
    'local client bounds replies and rejects fake verified solves and inconsistent counts',
    () async {
      for (final changed in [
        {'verified_solve': true},
        {'passed': 4},
        {'total': 2},
        {'suite': 'invented'},
      ]) {
        final client = ReferenceRunnerClient(
          'http://127.0.0.1:8766',
          client: MockClient((r) async {
            expect(r.followRedirects, false);
            return http.Response(jsonEncode({...goodReply(), ...changed}), 200);
          }),
        );
        await expectLater(
          client.run('signal-ranges-v1', 'function solve(){}'),
          throwsFormatException,
        );
        client.close();
      }
      final client = ReferenceRunnerClient(
        'http://127.0.0.1:8766',
        client: MockClient((_) async => http.Response('x' * 32769, 200)),
      );
      await expectLater(
        client.run('signal-ranges-v1', 'draft'),
        throwsFormatException,
      );
      client.close();
      for (final url in [
        'https://127.0.0.1',
        'http://example.com',
        'http://localhost/path',
        'http://user@localhost',
      ]) {
        expect(() => ReferenceRunnerClient(url), throwsArgumentError);
      }
    },
  );
  testWidgets('edited draft discards an in-flight result', (tester) async {
    final pending = Completer<http.Response>();
    final client = ReferenceRunnerClient(
      'http://localhost:8766',
      client: MockClient((_) => pending.future),
    );
    final editor = TextEditingController(text: 'function solve(){return 3;}');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReferenceRunPanel(
            lessonId: 'signal-ranges-v1',
            language: CodeLanguage.javascript,
            editor: editor,
            enabled: true,
            runner: client,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Run reference cases'));
    await tester.pump();
    editor.text = 'function solve(){return 99;}';
    pending.complete(http.Response(jsonEncode(goodReply()), 200));
    await tester.pumpAndSettle();
    expect(find.textContaining('draft changed'), findsOneWidget);
    expect(find.text('3/3 reference cases matched'), findsNothing);
    expect(editor.text, contains('99'));
    await tester.pumpWidget(const SizedBox());
    editor.dispose();
  });
  testWidgets(
    'result survives cursor movement but disappears after a source edit',
    (tester) async {
      final client = ReferenceRunnerClient(
        'http://localhost:8766',
        client: MockClient(
          (_) async => http.Response(jsonEncode(goodReply()), 200),
        ),
      );
      final editor = TextEditingController(text: 'function solve(){return 3;}');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReferenceRunPanel(
              lessonId: 'signal-ranges-v1',
              language: CodeLanguage.javascript,
              editor: editor,
              enabled: true,
              runner: client,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Run reference cases'));
      await tester.pumpAndSettle();
      expect(find.text('3/3 reference cases matched'), findsOneWidget);
      editor.selection = const TextSelection.collapsed(offset: 0);
      await tester.pump();
      expect(find.text('3/3 reference cases matched'), findsOneWidget);
      editor.text = 'changed';
      await tester.pump();
      expect(find.text('3/3 reference cases matched'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      editor.dispose();
    },
  );
}
