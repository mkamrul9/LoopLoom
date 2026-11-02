import '../domain/lesson.dart';
import 'blind75_curriculum.dart';
import 'interview_lessons.dart';
import 'mastery300_curriculum.dart';
import 'pilot_lessons.dart';

final starter30Lessons = List<Lesson>.unmodifiable([
  ...pilotLessons,
  ...interviewLessons,
]);

final blind75Lessons = List<Lesson>.unmodifiable(
  blind75Entries.map((entry) => entry.lesson),
);

final mastery300Lessons = List<Lesson>.unmodifiable(
  mastery300Entries.map((entry) => entry.lesson),
);

/// Problems available to open and restore. Blind 75 entries reuse matching
/// Starter 30 lessons where their contracts align, preserving saved progress.
final allLessons = List<Lesson>.unmodifiable(
  {
    for (final lesson in starter30Lessons) lesson.id: lesson,
    for (final entry in mastery300Entries) entry.lesson.id: entry.lesson,
  }.values,
);
