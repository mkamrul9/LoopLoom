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
    this.aiCoachConsent = false,
    this.selectedTrack = 3,
    this.targetInterviewDate,
    this.diagnosticCompletedAt,
    this.diagnosticScores = const {},
    this.diagnosticAnswers = const {},
    this.savedLessonIds = const {},
    this.pointsBalance = 10000,
    this.unlockedReferenceIds = const {},
    this.runnerAddress = '',
    this.runnerToken = '',
  });

  static const textScaleOptions = <double>[1.0, 1.15, 1.3, 1.5];

  final CoachingPace pace;
  final CodeLanguage preferredLanguage;
  final AppearancePreference appearance;
  final double textScale;
  final String displayName, targetRole;
  final int weeklyGoalDays, dailyGoalMinutes;
  final bool aiCoachConsent;
  final int selectedTrack;
  final DateTime? targetInterviewDate;
  final DateTime? diagnosticCompletedAt;
  final Map<String, int> diagnosticScores, diagnosticAnswers;
  final Set<String> savedLessonIds;

  /// Local study credits; no payment or server ledger is attached.
  final int pointsBalance;
  final Set<String> unlockedReferenceIds;
  final String runnerAddress, runnerToken;

  Map<String, Object?> toJson() => {
    'pace': pace.name,
    'preferredLanguage': preferredLanguage.name,
    'appearance': appearance.name,
    'textScale': textScale,
    'displayName': displayName,
    'targetRole': targetRole,
    'weeklyGoalDays': weeklyGoalDays,
    'dailyGoalMinutes': dailyGoalMinutes,
    'aiCoachConsent': aiCoachConsent,
    'selectedTrack': selectedTrack,
    'targetInterviewDate': targetInterviewDate?.toIso8601String(),
    'diagnosticCompletedAt': diagnosticCompletedAt?.toIso8601String(),
    'diagnosticScores': diagnosticScores,
    'diagnosticAnswers': diagnosticAnswers,
    'savedLessonIds': savedLessonIds.toList()..sort(),
    'pointsBalance': pointsBalance,
    'unlockedReferenceIds': unlockedReferenceIds.toList()..sort(),
    'runnerAddress': runnerAddress,
    'runnerToken': runnerToken,
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
    final rawTrack = json['selectedTrack'];
    Map<String, int> parseDiagnosticMap(Object? raw, {required int maxValue}) {
      final parsed = <String, int>{};
      if (raw is Map) {
        for (final entry in raw.entries.take(20)) {
          if (entry.key is String &&
              (entry.key as String).isNotEmpty &&
              (entry.key as String).length <= 80 &&
              entry.value is int &&
              (entry.value as int) >= 0 &&
              (entry.value as int) <= maxValue) {
            parsed[entry.key as String] = entry.value as int;
          }
        }
      }
      return parsed;
    }

    final rawSaved = json['savedLessonIds'];
    final rawPoints = json['pointsBalance'];
    final rawUnlocked = json['unlockedReferenceIds'];
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
      aiCoachConsent: json['aiCoachConsent'] == true,
      selectedTrack: rawTrack is int && rawTrack >= 0 && rawTrack <= 6
          ? rawTrack
          : 3,
      targetInterviewDate: parsedDate,
      diagnosticCompletedAt: json['diagnosticCompletedAt'] is String
          ? DateTime.tryParse(json['diagnosticCompletedAt'] as String)
          : null,
      diagnosticScores: parseDiagnosticMap(
        json['diagnosticScores'],
        maxValue: 1,
      ),
      diagnosticAnswers: parseDiagnosticMap(
        json['diagnosticAnswers'],
        maxValue: 3,
      ),
      savedLessonIds: rawSaved is List
          ? rawSaved
                .whereType<String>()
                .where((id) => id.isNotEmpty && id.length <= 200)
                .take(500)
                .toSet()
          : const {},
      pointsBalance:
          rawPoints is int && rawPoints >= 0 && rawPoints <= 1000000000
          ? rawPoints
          : 10000,
      unlockedReferenceIds: rawUnlocked is List
          ? rawUnlocked
                .whereType<String>()
                .where((id) => id.isNotEmpty && id.length <= 200)
                .take(500)
                .toSet()
          : const {},
      runnerAddress:
          json['runnerAddress'] is String &&
              (json['runnerAddress'] as String).length <= 200
          ? json['runnerAddress'] as String
          : '',
      runnerToken:
          json['runnerToken'] is String &&
              (json['runnerToken'] as String).length <= 200
          ? json['runnerToken'] as String
          : '',
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
    bool? aiCoachConsent,
    int? selectedTrack,
    DateTime? targetInterviewDate,
    bool clearTargetInterviewDate = false,
    DateTime? diagnosticCompletedAt,
    bool clearDiagnosticResult = false,
    Map<String, int>? diagnosticScores,
    Map<String, int>? diagnosticAnswers,
    Set<String>? savedLessonIds,
    int? pointsBalance,
    Set<String>? unlockedReferenceIds,
    String? runnerAddress,
    String? runnerToken,
  }) => LearnerPreferences(
    pace: pace ?? this.pace,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    appearance: appearance ?? this.appearance,
    textScale: textScale ?? this.textScale,
    displayName: displayName ?? this.displayName,
    targetRole: targetRole ?? this.targetRole,
    weeklyGoalDays: weeklyGoalDays ?? this.weeklyGoalDays,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    aiCoachConsent: aiCoachConsent ?? this.aiCoachConsent,
    selectedTrack: selectedTrack ?? this.selectedTrack,
    targetInterviewDate: clearTargetInterviewDate
        ? null
        : targetInterviewDate ?? this.targetInterviewDate,
    diagnosticCompletedAt: clearDiagnosticResult
        ? null
        : diagnosticCompletedAt ?? this.diagnosticCompletedAt,
    diagnosticScores: clearDiagnosticResult
        ? const {}
        : diagnosticScores ?? this.diagnosticScores,
    diagnosticAnswers: clearDiagnosticResult
        ? const {}
        : diagnosticAnswers ?? this.diagnosticAnswers,
    savedLessonIds: savedLessonIds ?? this.savedLessonIds,
    pointsBalance: pointsBalance ?? this.pointsBalance,
    unlockedReferenceIds: unlockedReferenceIds ?? this.unlockedReferenceIds,
    runnerAddress: runnerAddress ?? this.runnerAddress,
    runnerToken: runnerToken ?? this.runnerToken,
  );
}
