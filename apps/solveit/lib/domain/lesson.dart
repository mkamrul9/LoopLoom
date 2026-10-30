enum CodeLanguage {
  cpp('C++', '// Implement your approach here.\n'),
  python('Python', '# Implement your approach here.\n'),
  javascript('JavaScript', '// Implement your approach here.\n'),
  typescript('TypeScript', '// Implement your approach here.\n');

  const CodeLanguage(this.label, this.starter);
  final String label;
  final String starter;
}

enum CoachingStage {
  understand('Understand'),
  approach('Approach'),
  trace('Trace'),
  code('Code'),
  reflect('Reflect'),
  complete('Self-reviewed');

  const CoachingStage(this.label);
  final String label;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.pattern,
    required this.summary,
    required this.statement,
    required this.example,
    required this.constraints,
    required this.questions,
    required this.checks,
    required this.hints,
    required this.explanation,
  });
  final String id, title, pattern, summary, statement, example, constraints;
  final List<String> questions, checks, hints;
  final String explanation;
}
