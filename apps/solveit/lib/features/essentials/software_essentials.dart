import 'package:flutter/material.dart';

import '../../features/coaching/session_controller.dart';
import '../../ui/looploom_theme.dart';
import '../../ui/readable_surface.dart';
import 'essentials_catalog.dart';

typedef OpenEssentialsLesson = void Function(String courseId, String lessonId);

class SoftwareEssentials extends StatelessWidget {
  const SoftwareEssentials({
    super.key,
    required this.store,
    required this.onOpenCourse,
    required this.onOpenLesson,
  });

  final PracticeStore store;
  final ValueChanged<EssentialsCourse> onOpenCourse;
  final OpenEssentialsLesson onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final completed = store.preferences.completedEssentialsLessonIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SOFTWARE ESSENTIALS', style: noteLabel),
        const SizedBox(height: 12),
        const Text(
          'Build real software.',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Learn how data, APIs, and browser interfaces fit together. Choose a course and work at your own pace.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: context.palette.muted,
          ),
        ),
        const SizedBox(height: 22),
        for (final course in essentialsCourses) ...[
          _courseCard(context, course, completed),
          const SizedBox(height: 14),
        ],
        Text(
          'Each lesson has a concept, code, a controllable illustrated trace, a real application use, and a short check. Traces do not execute code.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: context.palette.muted,
          ),
        ),
      ],
    );
  }

  Widget _courseCard(
    BuildContext context,
    EssentialsCourse course,
    Set<String> completed,
  ) {
    final count = course.completedCount(completed);
    final next = course.nextLesson(completed);
    final icon = switch (course.id) {
      'sql' => Icons.storage_outlined,
      'backend' => Icons.dns_outlined,
      _ => Icons.web_outlined,
    };
    return Container(
      key: Key('essentials-course-${course.id}'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.palette.sheet,
        border: Border.all(color: context.palette.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.palette.accent, size: 27),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            course.summary,
            style: const TextStyle(fontSize: 16, height: 1.45),
          ),
          const SizedBox(height: 6),
          Text(
            course.detail,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: context.palette.muted,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: count / course.lessons.length),
          const SizedBox(height: 7),
          Text(
            '$count of ${course.lessons.length} complete',
            style: TextStyle(fontSize: 14, color: context.palette.muted),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 9,
            runSpacing: 8,
            children: [
              if (next != null)
                FilledButton.icon(
                  key: Key('start-course-${course.id}'),
                  onPressed: () => onOpenLesson(course.id, next.id),
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: Text(count == 0 ? 'Start course' : 'Continue'),
                ),
              OutlinedButton(
                key: Key('view-course-${course.id}'),
                onPressed: () => onOpenCourse(course),
                child: const Text('View lessons'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EssentialsCourseScreen extends StatelessWidget {
  const EssentialsCourseScreen({
    super.key,
    required this.course,
    required this.store,
    required this.onOpenLesson,
  });

  final EssentialsCourse course;
  final PracticeStore store;
  final OpenEssentialsLesson onOpenLesson;

  @override
  Widget build(BuildContext context) => ReadableSurface(
    scale: store.preferences.textScale,
    child: Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final completed = store.preferences.completedEssentialsLessonIds;
          final count = course.completedCount(completed);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  Text(
                    course.summary,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    course.detail,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: context.palette.muted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(value: count / course.lessons.length),
                  const SizedBox(height: 8),
                  Text(
                    '$count of ${course.lessons.length} complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.palette.muted,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Follow the lessons in order, or open any topic you need. Your completion is saved on this device.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: context.palette.muted,
                    ),
                  ),
                  for (final unit in course.units) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 9),
                      child: Text(unit.toUpperCase(), style: noteLabel),
                    ),
                    for (final lesson in course.lessons.where(
                      (item) => item.unit == unit,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            key: Key('essentials-lesson-${lesson.id}'),
                            onTap: () => onOpenLesson(course.id, lesson.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    completed.contains(lesson.id)
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: completed.contains(lesson.id)
                                        ? context.palette.accent
                                        : context.palette.muted,
                                    size: 23,
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lesson.title,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          lesson.summary,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: context.palette.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
