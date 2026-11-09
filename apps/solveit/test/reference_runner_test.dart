import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:looploom/data/code_specs.dart';
import 'package:looploom/domain/lesson.dart';
import 'package:looploom/features/coaching/reference_runner.dart';
import 'package:looploom/ui/reference_run_panel.dart';

Map<String, Object?> goodReply({String language = 'javascript'}) => {
  'suite': 'reference-v1',
  'language': language,
  'passed': 3,
  'total': 3,
  'verified_solve': false,
  'cases': codeSpecs['signal-ranges-v1']!.cases
      .map((c) => {'label': c.label, 'status': 'matched'})
      .toList(),
};

void main() {
  test(
    'runner health check uses authenticated GET and reports readiness',
    () async {
      const token = '12345678901234567890123456789012';
      final client = ReferenceRunnerClient(
        'http://192.168.1.20:8766',
        token: token,
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/health');
          expect(request.headers['authorization'], 'Bearer $token');
          return http.Response(
            jsonEncode({
              'ready': true,
              'languages': ['python', 'cpp'],
              'development_only': true,
            }),
            200,
          );
        }),
      );
      final health = await client.checkHealth();
      expect(health.ready, isTrue);
      expect(health.languages, ['python', 'cpp']);
      client.close();
    },
  );

  test(
    'runner health distinguishes offline engines and rejected tokens',
    () async {
      final unavailable = ReferenceRunnerClient(
        'http://localhost:8766',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'ready': false,
              'languages': [],
              'development_only': true,
            }),
            200,
          ),
        ),
      );
      expect((await unavailable.checkHealth()).ready, isFalse);
      unavailable.close();
      final denied = ReferenceRunnerClient(
        'http://localhost:8766',
        client: MockClient((_) async => http.Response('{}', 403)),
      );
      await expectLater(
        denied.checkHealth(),
        throwsA(
          isA<RunnerHealthException>().having(
            (error) => error.message,
            'message',
            contains('rejected'),
          ),
        ),
      );
      denied.close();
    },
  );

  test('runner health rejects unrelated or oversized replies', () async {
    for (final body in [
      '{"ready":true,"languages":["python"],"development_only":false}',
      '{"ready":true,"languages":["unknown"],"development_only":true}',
      'x' * 4097,
    ]) {
      final client = ReferenceRunnerClient(
        'http://localhost:8766',
        client: MockClient((_) async => http.Response(body, 200)),
      );
      await expectLater(
        client.checkHealth(),
        throwsA(isA<RunnerHealthException>()),
      );
      client.close();
    }
  });

  test(
    'C++ submissions carry their language and recognize compile errors',
    () async {
      final client = ReferenceRunnerClient(
        'http://localhost:8766',
        client: MockClient((request) async {
          expect(jsonDecode(request.body)['language'], 'cpp');
          return http.Response(
            jsonEncode({
              ...goodReply(language: 'cpp'),
              'passed': 0,
              'cases': codeSpecs['signal-ranges-v1']!.cases
                  .map((c) => {'label': c.label, 'status': 'compile_error'})
                  .toList(),
            }),
            200,
          );
        }),
      );
      final result = await client.run(
        'signal-ranges-v1',
        'int solve(vector<int> a, int t) { return 0; }',
        language: 'cpp',
      );
      expect(result.passed, 0);
      expect(result.statuses, everyElement('compile_error'));
      client.close();
    },
  );
  testWidgets('C++ execution notice is visible in the development panel', (
    tester,
  ) async {
    final client = ReferenceRunnerClient(
      'http://localhost:8766',
      client: MockClient((request) async {
        expect(jsonDecode(request.body)['language'], 'cpp');
        return http.Response(jsonEncode(goodReply(language: 'cpp')), 200);
      }),
    );
    final editor = TextEditingController(
      text: 'int solve(vector<int> a, int t) { return 3; }',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReferenceRunPanel(
            lessonId: 'signal-ranges-v1',
            language: CodeLanguage.cpp,
            editor: editor,
            enabled: true,
            runner: client,
          ),
        ),
      ),
    );
    expect(find.textContaining('compiles as C++17'), findsOneWidget);
    await tester.tap(find.text('Run reference cases'));
    await tester.pumpAndSettle();
    expect(find.text('3/3 reference cases matched'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    editor.dispose();
  });
  testWidgets('TypeScript shows its limits and handles unsupported syntax', (
    tester,
  ) async {
    final client = ReferenceRunnerClient(
      'http://localhost:8766',
      client: MockClient((request) async {
        expect(jsonDecode(request.body)['language'], 'typescript');
        return http.Response(
          jsonEncode({
            ...goodReply(),
            'language': 'typescript',
            'passed': 0,
            'cases': codeSpecs['signal-ranges-v1']!.cases
                .map((c) => {'label': c.label, 'status': 'unsupported_syntax'})
                .toList(),
          }),
          200,
        );
      }),
    );
    final editor = TextEditingController(
      text: 'enum X { A }; function solve(){return X.A;}',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReferenceRunPanel(
            lessonId: 'signal-ranges-v1',
            language: CodeLanguage.typescript,
            editor: editor,
            enabled: true,
            runner: client,
          ),
        ),
      ),
    );
    expect(find.textContaining('types are not checked'), findsOneWidget);
    await tester.tap(find.text('Run reference cases'));
    await tester.pumpAndSettle();
    expect(find.text('0/3 reference cases matched'), findsOneWidget);
    expect(find.textContaining('unsupported syntax'), findsNWidgets(3));
    editor.text = 'function solve(a: readonly number[]): number {return 0;}';
    await tester.pump();
    expect(find.text('0/3 reference cases matched'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    editor.dispose();
  });
  test('TypeScript rejects a JavaScript reply', () async {
    final client = ReferenceRunnerClient(
      'http://localhost:8766',
      client: MockClient(
        (_) async => http.Response(jsonEncode(goodReply()), 200),
      ),
    );
    await expectLater(
      client.run(
        'signal-ranges-v1',
        'function solve(): number {return 0;}',
        language: 'typescript',
      ),
      throwsFormatException,
    );
    client.close();
  });
  test(
    'Python submissions carry their language and reject another runtime reply',
    () async {
      for (final responseLanguage in ['python', 'javascript']) {
        final client = ReferenceRunnerClient(
          'http://localhost:8766',
          client: MockClient((request) async {
            expect(jsonDecode(request.body)['language'], 'python');
            return http.Response(
              jsonEncode({...goodReply(), 'language': responseLanguage}),
              200,
            );
          }),
        );
        if (responseLanguage == 'python') {
          expect(
            (await client.run(
              'signal-ranges-v1',
              'def solve(a,t):return 0',
              language: 'python',
            )).passed,
            3,
          );
        } else {
          await expectLater(
            client.run(
              'signal-ranges-v1',
              'def solve(a,t):return 0',
              language: 'python',
            ),
            throwsFormatException,
          );
        }
        client.close();
      }
      final client = ReferenceRunnerClient(
        'http://localhost:8766',
        client: MockClient(
          (_) async => throw StateError('unsupported language reached HTTP'),
        ),
      );
      await expectLater(
        client.run('signal-ranges-v1', 'draft', language: 'java'),
        throwsFormatException,
      );
      client.close();
    },
  );
  testWidgets(
    'changing from Python to JavaScript discards an in-flight Python result',
    (tester) async {
      final pending = Completer<http.Response>();
      final client = ReferenceRunnerClient(
        'http://localhost:8766',
        client: MockClient((request) {
          expect(jsonDecode(request.body)['language'], 'python');
          return pending.future;
        }),
      );
      final editor = TextEditingController(text: 'def solve(a,t):return 0');
      Widget view(CodeLanguage language) => MaterialApp(
        home: Scaffold(
          body: ReferenceRunPanel(
            lessonId: 'signal-ranges-v1',
            language: language,
            editor: editor,
            enabled: true,
            runner: client,
          ),
        ),
      );
      await tester.pumpWidget(view(CodeLanguage.python));
      await tester.tap(find.text('Run reference cases'));
      await tester.pump();
      await tester.pumpWidget(view(CodeLanguage.javascript));
      pending.complete(
        http.Response(jsonEncode({...goodReply(), 'language': 'python'}), 200),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('draft changed'), findsOneWidget);
      expect(find.text('3/3 reference cases matched'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      editor.dispose();
    },
  );
  test('server reference fixtures match the visible input contracts', () {
    String compactOutsideStrings(String value) {
      final result = StringBuffer();
      var quoted = false;
      var escaped = false;
      for (final char in value.split('')) {
        if (char == '"' && !escaped) quoted = !quoted;
        if (quoted || char != ' ') result.write(char);
        escaped = char == '\\' && !escaped;
      }
      return result.toString();
    }

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
        expect(compactOutsideStrings(entry.value.cases[i].input), input);
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
