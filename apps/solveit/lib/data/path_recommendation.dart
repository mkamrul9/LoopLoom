import '../domain/learner_preferences.dart';

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

class PathRecommendation {
  const PathRecommendation(this.trackIndex, this.title, this.reason);

  final int trackIndex;
  final String title;
  final String reason;
}

PathRecommendation? recommendPath(
  LearnerPreferences preferences, {
  DateTime? now,
}) {
  final hasCheck =
      preferences.diagnosticCompletedAt != null &&
      preferences.diagnosticScores.isNotEmpty;
  final level = preferences.experienceLevel;
  if (!hasCheck && level == null) return null;

  final score = preferences.diagnosticScores.values
      .where((value) => value == 1)
      .length;
  final lowConfidence = hasCheck && score <= 2;
  int track;
  if (hasCheck) {
    track = lowConfidence
        ? 2
        : score <= 5
        ? 5
        : 3;
  } else {
    track = switch (level!) {
      ExperienceLevel.beginner => 2,
      ExperienceLevel.intermediate => 5,
      ExperienceLevel.experienced => 3,
    };
  }

  final today = _day(now ?? DateTime.now());
  final target = preferences.targetInterviewDate;
  if (target != null && !lowConfidence && level != ExperienceLevel.beginner) {
    final days = _day(target).difference(today).inDays;
    if (days >= 0 && days <= 1 && (!hasCheck || score >= 5)) {
      track = 6;
    } else if (days >= 0 && days <= 7) {
      track = 5;
    }
  }

  final title = switch (track) {
    2 => 'Starter 30',
    3 => 'Blind 75',
    5 => 'One-week interview prep',
    _ => 'Last-day interview prep',
  };
  final reason = switch (track) {
    2 => 'Build a reliable base across common patterns before a longer path.',
    3 => 'Work through broad interview patterns at a steady pace.',
    5 => 'Focus on a compact set of common interview patterns this week.',
    _ => 'Refresh the highest-yield patterns before your interview.',
  };
  return PathRecommendation(
    track,
    title,
    '$reason ${hasCheck ? 'Based on your short pattern check' : 'Based on your self-reported experience'}; this is a study suggestion, not a measure of interview readiness.',
  );
}
