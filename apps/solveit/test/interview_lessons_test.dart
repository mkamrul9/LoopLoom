import 'package:flutter_test/flutter_test.dart';
import 'package:solveit/data/interview_lessons.dart';
import 'package:solveit/data/lesson_catalog.dart';
import 'package:solveit/data/blind75_curriculum.dart';
import 'package:solveit/domain/lesson.dart';
import 'package:solveit/features/coaching/session_controller.dart';

// Trusted authoring references only. The app does not execute learner code.
int ranges(List<int> a, int target) {
  final seen = <int, int>{0: 1};
  var sum = 0, count = 0;
  for (final x in a) {
    sum += x;
    count += seen[sum - target] ?? 0;
    seen[sum] = (seen[sum] ?? 0) + 1;
  }
  return count;
}

List<int> warmer(List<int> a) {
  final result = List.filled(a.length, 0), stack = <int>[];
  for (var i = 0; i < a.length; i++) {
    while (stack.isNotEmpty && a[i] > a[stack.last]) {
      final j = stack.removeLast();
      result[j] = i - j;
    }
    stack.add(i);
  }
  return result;
}

List<List<int>> merge(List<List<int>> a) {
  final sorted = a.map((v) => List<int>.of(v)).toList()
    ..sort((a, b) => a[0].compareTo(b[0]));
  final out = <List<int>>[];
  for (final v in sorted) {
    if (out.isEmpty || v[0] >= out.last[1]) {
      out.add(v);
    } else if (v[1] > out.last[1]) {
      out.last[1] = v[1];
    }
  }
  return out;
}

void main() {
  test(
    'all published lessons have a unique versioned identity and five checkpoints',
    () {
      expect(starter30Lessons.map((l) => l.id).toSet().length, 30);
      for (final l in starter30Lessons) {
        expect(l.questions.length, 5);
        expect(l.checks.length, 5);
        expect(
          l.questions.every((question) => question.trim().isNotEmpty),
          isTrue,
        );
        expect(l.checks.every((check) => check.trim().isNotEmpty), isTrue);
        expect(l.hints.length, 3);
        expect(l.explanation, isNotEmpty);
        expect(l.statement, isNotEmpty);
        expect(l.example, isNotEmpty);
        expect(l.constraints, isNotEmpty);
      }
    },
  );
  test('Blind 75 has 75 ordered, grouped and fully guided problem entries', () {
    expect(blind75Entries, hasLength(75));
    expect(
      blind75Entries.map((entry) => entry.number),
      List.generate(75, (i) => i + 1),
    );
    expect(blind75Entries.map((entry) => entry.slug).toSet(), hasLength(75));
    expect(
      blind75Entries.map((entry) => entry.lesson.id).toSet(),
      hasLength(75),
    );
    expect(blind75Entries.map((entry) => entry.phase).toSet(), hasLength(4));
    expect(blind75Entries.map((entry) => entry.pattern).toSet(), hasLength(16));
    expect(
      blind75Entries.where((entry) => entry.hasReferenceCases),
      hasLength(15),
    );
    expect(starter30Lessons, hasLength(30));
    expect(allLessons, hasLength(90));
    for (final entry in blind75Entries) {
      final lesson = entry.lesson;
      expect(entry.challengeUri.host, 'leetcode.com');
      expect(lesson.questions, hasLength(5), reason: entry.title);
      expect(lesson.checks, hasLength(5), reason: entry.title);
      expect(lesson.hints, hasLength(3), reason: entry.title);
      expect(lesson.statement, isNotEmpty, reason: entry.title);
      expect(lesson.example, isNotEmpty, reason: entry.title);
      expect(lesson.explanation, isNotEmpty, reason: entry.title);
      for (final language in CodeLanguage.values) {
        final session = SessionController(
          lesson,
          attemptNumber: 1,
          initialLanguage: language,
        );
        expect(
          session.starter,
          isNotEmpty,
          reason: '${entry.title} / ${language.name}',
        );
        session.dispose();
      }
    }
  });
  test(
    'prefix and stack references agree with exhaustive small-input baselines',
    () {
      void verify(List<int> a) {
        for (var target = -3; target <= 3; target++) {
          var expected = 0;
          for (var i = 0; i < a.length; i++) {
            var sum = 0;
            for (var j = i; j < a.length; j++) {
              sum += a[j];
              if (sum == target) expected++;
            }
          }
          expect(ranges(a, target), expected, reason: '$a, target $target');
        }
        final expected = List.filled(a.length, 0);
        for (var i = 0; i < a.length; i++) {
          for (var j = i + 1; j < a.length; j++) {
            if (a[j] > a[i]) {
              expected[i] = j - i;
              break;
            }
          }
        }
        expect(warmer(a), expected, reason: '$a');
        if (a.length < 5) {
          for (final x in [-1, 0, 1]) {
            verify([...a, x]);
          }
        }
      }

      verify([]);
      expect(ranges([2, -2, 2], 2), 3);
      expect(ranges([0, 0, 0], 0), 6);
      expect(warmer([20, 20, 19, 23, 21]), [3, 2, 1, 0, 0]);
    },
  );
  test(
    'interval examples preserve nesting, adjacency, duplicates, and input',
    () {
      final a = [
        [5, 8],
        [1, 4],
        [2, 3],
        [7, 9],
        [9, 10],
      ];
      final before = a.map((v) => List<int>.of(v)).toList();
      expect(merge(a), [
        [1, 4],
        [5, 9],
        [9, 10],
      ]);
      expect(a, before);
      expect(
        merge([
          [1, 6],
          [2, 4],
          [6, 8],
          [7, 9],
        ]),
        [
          [1, 6],
          [6, 9],
        ],
      );
      expect(
        merge([
          [1, 3],
          [1, 3],
          [1, 2],
        ]),
        [
          [1, 3],
        ],
      );
      expect(
        merge([
          [3, 4],
          [1, 2],
          [2, 3],
        ]),
        [
          [1, 2],
          [2, 3],
          [3, 4],
        ],
      );
      expect(merge([]), isEmpty);
    },
  );
  test(
    'new lessons keep four-language drafts and survive backup without early reveals',
    () async {
      final source = PracticeStore();
      for (final lesson in interviewLessons) {
        final s = source.startOrResume(lesson);
        expect(s.messages.any((m) => m.kind == MessageKind.solution), false);
        for (final lang in CodeLanguage.values) {
          s.changeLanguage(lang);
          s.saveDraft('draft ${lang.name}');
        }
        s.saveReasoningDraft('My invariant for ${lesson.id}');
      }
      final restored = PracticeStore();
      await restored.importBackup(
        restored.inspectBackup(source.exportBackup(), allLessons),
        allLessons,
      );
      expect(restored.sessions.length, 27);
      for (final s in restored.sessions) {
        for (final lang in CodeLanguage.values) {
          s.changeLanguage(lang);
          expect(s.draft, 'draft ${lang.name}');
        }
        expect(s.reasoningDraft, contains(s.lesson.id));
        expect(s.verifiedSolved, false);
      }
      await source.close();
      await restored.close();
    },
  );
}
