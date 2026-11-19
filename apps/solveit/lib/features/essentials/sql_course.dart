part 'sql_course_lessons.dart';

/// A standalone, SQLite-flavoured course. The visual traces are authored
/// explanations of the sample data, not a SQL execution engine.
class SqlTraceStep {
  const SqlTraceStep(this.title, this.explanation, this.active, this.output);
  final String title, explanation;
  final List<int> active;
  final List<String> output;
}

class SqlLesson {
  const SqlLesson({
    required this.id,
    required this.unit,
    required this.title,
    required this.summary,
    required this.concept,
    required this.why,
    required this.when,
    required this.operation,
    required this.sql,
    required this.result,
    required this.application,
    required this.appCode,
    required this.alternative,
    required this.pitfall,
    required this.traceInput,
    required this.trace,
    required this.check,
    required this.answer,
  });

  final String id, unit, title, summary, concept, why, when, operation;
  final String sql, result, application, appCode, alternative, pitfall;
  final List<String> traceInput;
  final List<SqlTraceStep> trace;
  final String check, answer;
}

const sqlCourseUnits = <String>[
  'Foundations',
  'Reading data',
  'Relationships',
  'Reliable changes',
  'Performance & design',
  'Application practice',
];
