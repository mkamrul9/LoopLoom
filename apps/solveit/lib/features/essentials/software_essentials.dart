import 'package:flutter/material.dart';

import '../../features/coaching/session_controller.dart';
import '../../ui/looploom_theme.dart';
import 'sql_course.dart';

class SoftwareEssentials extends StatelessWidget {
  const SoftwareEssentials({
    super.key,
    required this.store,
    required this.onOpenLesson,
  });

  final PracticeStore store;
  final ValueChanged<SqlLesson> onOpenLesson;

  @override
  Widget build(BuildContext context) {
    final completed = store.preferences.completedEssentialsLessonIds;
    final completedCount = sqlLessons
        .where((lesson) => completed.contains(lesson.id))
        .length;
    final next = sqlLessons
        .where((lesson) => !completed.contains(lesson.id))
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SOFTWARE ESSENTIALS', style: noteLabel),
        const SizedBox(height: 12),
        const Text(
          'Build with data.',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'A practical database course, from your first table to a reliable checkout flow.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: context.palette.muted,
          ),
        ),
        const SizedBox(height: 22),
        Container(
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
              Text(
                'DATABASES & SQL',
                style: noteLabel.copyWith(color: context.palette.accent),
              ),
              const SizedBox(height: 9),
              Text(
                '${sqlLessons.length} lessons · ${sqlCourseUnits.length} units',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SQLite examples · visual traces · software use cases · local progress',
                style: TextStyle(fontSize: 15, color: context.palette.muted),
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: completedCount / sqlLessons.length,
              ),
              const SizedBox(height: 8),
              Text(
                '$completedCount of ${sqlLessons.length} complete',
                style: TextStyle(fontSize: 14, color: context.palette.muted),
              ),
              if (next != null) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => onOpenLesson(next),
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: Text(
                    completed.isEmpty
                        ? 'Start with ${next.title}'
                        : 'Continue: ${next.title}',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'The lesson traces illustrate known sample results. The SQL snippets use SQLite syntax and can be copied into your own database tool.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: context.palette.muted,
          ),
        ),
        const SizedBox(height: 18),
        for (final unit in sqlCourseUnits) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 9),
            child: Text(unit.toUpperCase(), style: noteLabel),
          ),
          for (final lesson in sqlLessons.where(
            (lesson) => lesson.unit == unit,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onOpenLesson(lesson),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
