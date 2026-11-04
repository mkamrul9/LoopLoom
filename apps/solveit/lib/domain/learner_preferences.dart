import 'lesson.dart';

enum CoachingPace {
  beginner('Beginner', 'Smaller steps and a concrete first move.'),
  intermediate('Intermediate', 'The standard interview-practice prompt.'),
  advanced('Advanced', 'Fewer prompts, with proof and tradeoff challenges.');

  const CoachingPace(this.label, this.description);
  final String label;
  final String description;

  String prompt(CoachingStage stage, String question) {
    final addition = switch ((this, stage)) {
      (CoachingPace.beginner, CoachingStage.understand) =>
        'Start with three short notes: the input, the output, and one edge case.',
      (CoachingPace.beginner, CoachingStage.approach) =>
        'First describe the simplest correct method. Then say what information you would keep.',
      (CoachingPace.beginner, CoachingStage.trace) =>
        'Use one example. Say what your state contains before and after each important step.',
      (CoachingPace.beginner, CoachingStage.code) =>
        'Implement one small step at a time. Use the visible example to check your own trace.',
      (CoachingPace.beginner, CoachingStage.reflect) =>
        'In your own words, name the key idea and give its time and extra-space cost.',
      (CoachingPace.advanced, CoachingStage.understand) =>
        'Which constraint most limits the solution space, and what boundary case could break a naive interpretation?',
      (CoachingPace.advanced, CoachingStage.approach) =>
        'State an invariant and justify why each update preserves it. Compare against a correct but slower baseline.',
      (CoachingPace.advanced, CoachingStage.trace) =>
        'Defend the complexity bound over the whole input, including worst-case state size.',
      (CoachingPace.advanced, CoachingStage.code) =>
        'Probe the boundary cases and explain why the implementation follows from your invariant.',
      (CoachingPace.advanced, CoachingStage.reflect) =>
        'Name a plausible follow-up constraint that changes the tradeoff, and how you would adapt.',
      _ => '',
    };
    return addition.isEmpty ? question : '$question\n\n$addition';
  }
}

enum AppearancePreference {
  system('System'),
  light('Light'),
  dark('Dark');

  const AppearancePreference(this.label);
  final String label;
}

class LearnerPreferences {
  const LearnerPreferences({
    this.pace = CoachingPace.intermediate,
    this.preferredLanguage = CodeLanguage.python,
    this.appearance = AppearancePreference.system,
    this.textScale = 1.15,
    this.displayName = '',
    this.targetRole = '',
    this.weeklyGoalDays = 5,
    this.dailyGoalMinutes = 30,
    this.targetInterviewDate,
    this.savedLessonIds = const {},
  });

  static const textScaleOptions = <double>[1.0, 1.15, 1.3];

  final CoachingPace pace;
  final CodeLanguage preferredLanguage;
  final AppearancePreference appearance;
  final double textScale;
  final String displayName, targetRole;
  final int weeklyGoalDays, dailyGoalMinutes;
  final DateTime? targetInterviewDate;
  final Set<String> savedLessonIds;

  Map<String, Object?> toJson() => {
    'pace': pace.name,
    'preferredLanguage': preferredLanguage.name,
    'appearance': appearance.name,
    'textScale': textScale,
    'displayName': displayName,
    'targetRole': targetRole,
    'weeklyGoalDays': weeklyGoalDays,
    'dailyGoalMinutes': dailyGoalMinutes,
    'targetInterviewDate': targetInterviewDate?.toIso8601String(),
    'savedLessonIds': savedLessonIds.toList()..sort(),
  };

  factory LearnerPreferences.fromJson(Map<String, Object?> json) {
    T parse<T extends Enum>(List<T> values, Object? value, T fallback) =>
        values.where((entry) => entry.name == value).firstOrNull ?? fallback;
    final storedScale = json['textScale'];
    final textScale =
        storedScale is num &&
            textScaleOptions.any((option) => (option - storedScale).abs() < .01)
        ? storedScale.toDouble()
        : 1.15;
    final rawDate = json['targetInterviewDate'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;
    final rawDays = json['weeklyGoalDays'];
    final rawMinutes = json['dailyGoalMinutes'];
    final rawSaved = json['savedLessonIds'];
    return LearnerPreferences(
      pace: parse(CoachingPace.values, json['pace'], CoachingPace.intermediate),
      preferredLanguage: parse(
        CodeLanguage.values,
        json['preferredLanguage'],
        CodeLanguage.python,
      ),
      appearance: parse(
        AppearancePreference.values,
        json['appearance'],
        AppearancePreference.system,
      ),
      textScale: textScale,
      displayName: json['displayName'] is String
          ? (json['displayName'] as String).trim()
          : '',
      targetRole: json['targetRole'] is String
          ? (json['targetRole'] as String).trim()
          : '',
      weeklyGoalDays: rawDays is int && rawDays >= 1 && rawDays <= 7
          ? rawDays
          : 5,
      dailyGoalMinutes:
          rawMinutes is int && rawMinutes >= 10 && rawMinutes <= 240
          ? rawMinutes
          : 30,
      targetInterviewDate: parsedDate,
      savedLessonIds: rawSaved is List
          ? rawSaved.whereType<String>().where((id) => id.isNotEmpty && id.length <= 200).take(500).toSet()
          : const {},
    );
  }

  LearnerPreferences copyWith({
    CoachingPace? pace,
    CodeLanguage? preferredLanguage,
    AppearancePreference? appearance,
    double? textScale,
    String? displayName,
    String? targetRole,
    int? weeklyGoalDays,
    int? dailyGoalMinutes,
    DateTime? targetInterviewDate,
    bool clearTargetInterviewDate = false,
    Set<String>? savedLessonIds,
  }) => LearnerPreferences(
    pace: pace ?? this.pace,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    appearance: appearance ?? this.appearance,
    textScale: textScale ?? this.textScale,
    displayName: displayName ?? this.displayName,
    targetRole: targetRole ?? this.targetRole,
    weeklyGoalDays: weeklyGoalDays ?? this.weeklyGoalDays,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    targetInterviewDate: clearTargetInterviewDate
        ? null
        : targetInterviewDate ?? this.targetInterviewDate,
    savedLessonIds: savedLessonIds ?? this.savedLessonIds,
  );
}
