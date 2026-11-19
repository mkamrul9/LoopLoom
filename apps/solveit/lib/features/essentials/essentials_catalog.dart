import 'engineering_course.dart';
import 'sql_course.dart';

class EssentialsEntry {
  const EssentialsEntry(this.id, this.unit, this.title, this.summary);
  final String id, unit, title, summary;
}

class EssentialsCourse {
  const EssentialsCourse({
    required this.id,
    required this.title,
    required this.summary,
    required this.detail,
    required this.units,
    required this.lessons,
  });
  final String id, title, summary, detail;
  final List<String> units;
  final List<EssentialsEntry> lessons;

  int completedCount(Set<String> completed) =>
      lessons.where((lesson) => completed.contains(lesson.id)).length;

  EssentialsEntry? nextLesson(Set<String> completed) =>
      lessons.where((lesson) => !completed.contains(lesson.id)).firstOrNull;
}

final essentialsCourses = <EssentialsCourse>[
  EssentialsCourse(
    id: 'sql',
    title: 'Databases & SQL',
    summary: 'Model, query, and change data reliably.',
    detail: '21 SQLite lessons · shop data model · visual traces',
    units: sqlCourseUnits,
    lessons: [
      for (final lesson in sqlLessons)
        EssentialsEntry(lesson.id, lesson.unit, lesson.title, lesson.summary),
    ],
  ),
  EssentialsCourse(
    id: 'backend',
    title: 'Backend Engineering',
    summary: 'Build APIs and services people can trust.',
    detail: '16 TypeScript lessons · shop API · request walkthroughs',
    units: backendUnits,
    lessons: [
      for (final lesson in backendLessons)
        EssentialsEntry(lesson.id, lesson.unit, lesson.title, lesson.summary),
    ],
  ),
  EssentialsCourse(
    id: 'frontend',
    title: 'Frontend Engineering',
    summary: 'Build accessible, responsive browser experiences.',
    detail: '16 HTML, CSS, JavaScript & TypeScript lessons · shop UI',
    units: frontendUnits,
    lessons: [
      for (final lesson in frontendLessons)
        EssentialsEntry(lesson.id, lesson.unit, lesson.title, lesson.summary),
    ],
  ),
];
