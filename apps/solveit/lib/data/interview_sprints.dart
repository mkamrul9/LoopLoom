import '../domain/lesson.dart';
import 'blind75_curriculum.dart';
import 'mastery300_curriculum.dart';

/// Short interview-prep tracks reuse the same lessons and saved attempts as
/// Blind 75 and Mastery 300. Slugs are stable references to those entries.
class InterviewSprintDay {
  const InterviewSprintDay(this.title, this.focus, this.slugs);

  final String title;
  final String focus;
  final List<String> slugs;
}

class InterviewSprint {
  const InterviewSprint(this.title, this.description, this.days);

  final String title;
  final String description;
  final List<InterviewSprintDay> days;

  List<Blind75Entry> get entries => [
    for (final day in days)
      for (final slug in day.slugs) _entryBySlug[slug]!,
  ];

  List<Lesson> get lessons => [for (final entry in entries) entry.lesson];
}

final _entryBySlug = {for (final entry in mastery300Entries) entry.slug: entry};

/// Twenty Easy and five Medium problems. The order starts with the high-priority
/// Grind 75 core, then adds Medium problems for five distinct interview patterns.
const oneWeekInterviewSprint = InterviewSprint(
  'One-week interview prep',
  '25 focused problems · 20 Easy + 5 Medium. Plan for three or four new problems a day, then revisit weak spots on day 7.',
  [
    InterviewSprintDay(
      'Day 1 · Hashing',
      'Recognize lookup and counting patterns.',
      ['two-sum', 'valid-anagram', 'contains-duplicate', 'ransom-note'],
    ),
    InterviewSprintDay(
      'Day 2 · Strings and arrays',
      'Explain the invariant before coding.',
      [
        'best-time-to-buy-and-sell-stock',
        'valid-palindrome',
        'valid-parentheses',
        'product-of-array-except-self',
      ],
    ),
    InterviewSprintDay(
      'Day 3 · Linked lists and windows',
      'Trace pointers and window state.',
      [
        'merge-two-sorted-lists',
        'reverse-linked-list',
        'linked-list-cycle',
        'longest-substring-without-repeating-characters',
      ],
    ),
    InterviewSprintDay(
      'Day 4 · Search and trees',
      'Name the boundary or traversal rule.',
      [
        'binary-search',
        'first-bad-version',
        'invert-binary-tree',
        'maximum-depth-of-binary-tree',
      ],
    ),
    InterviewSprintDay(
      'Day 5 · Recursive and running state',
      'Check base cases and state updates.',
      [
        'balanced-binary-tree',
        'lowest-common-ancestor-of-a-binary-search-tree',
        'diameter-of-binary-tree',
        'maximum-subarray',
      ],
    ),
    InterviewSprintDay(
      'Day 6 · Traversal and state',
      'Compare iterative and recursive state.',
      [
        'majority-element',
        'climbing-stairs',
        'single-number',
        'number-of-islands',
      ],
    ),
    InterviewSprintDay(
      'Day 7 · Review and intervals',
      'Revisit misses, then solve one new pattern.',
      ['merge-intervals'],
    ),
  ],
);

/// A light recall set drawn entirely from the one-week track, so progress is shared.
const lastDayInterviewSprint = InterviewSprint(
  'Last-day interview prep',
  '7 high-yield recall problems · 5 Easy + 2 Medium. Explain each approach aloud, trace an edge case, and revisit only what feels shaky.',
  [
    InterviewSprintDay(
      'Core recall',
      'Quickly state the key invariant and complexity.',
      [
        'two-sum',
        'valid-parentheses',
        'binary-search',
        'reverse-linked-list',
        'invert-binary-tree',
      ],
    ),
    InterviewSprintDay(
      'Pattern transfer',
      'Trace one window and one graph traversal.',
      ['longest-substring-without-repeating-characters', 'number-of-islands'],
    ),
  ],
);
