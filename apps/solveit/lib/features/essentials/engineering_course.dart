part 'backend_lessons.dart';
part 'frontend_lessons.dart';

class EngineeringTraceStep {
  const EngineeringTraceStep(
    this.title,
    this.explanation,
    this.active,
    this.output,
  );
  final String title;
  final String explanation;
  final List<int> active;
  final List<String> output;
}

class EngineeringLesson {
  const EngineeringLesson({
    required this.id,
    required this.unit,
    required this.title,
    required this.summary,
    required this.concept,
    required this.why,
    required this.when,
    required this.how,
    required this.codeLabel,
    required this.code,
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

  final String id, unit, title, summary, concept, why, when, how;
  final String codeLabel, code, result, application, appCode;
  final String alternative, pitfall, check, answer;
  final List<String> traceInput;
  final List<EngineeringTraceStep> trace;
}

const backendUnits = <String>[
  'Request foundations',
  'Data and identity',
  'Reliable services',
  'Ship and operate',
];

const frontendUnits = <String>[
  'Browser foundations',
  'Application flow',
  'Quality and access',
  'Ship and improve',
];
