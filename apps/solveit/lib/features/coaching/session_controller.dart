import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/session_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/learner_preferences.dart';
import '../../data/code_specs.dart';
import '../../data/blind75_curriculum.dart';
import 'coach_provider.dart';

enum MessageKind { question, checkpoint, hint, solution, note, feedback, error }

class CoachMessage {
  const CoachMessage(
    this.text, {
    this.isLearner = false,
    this.kind = MessageKind.note,
  });
  final String text;
  final bool isLearner;
  final MessageKind kind;
  Map<String, Object?> toJson() => {
    'text': text,
    'isLearner': isLearner,
    'kind': kind.name,
  };
  factory CoachMessage.fromJson(Map<String, Object?> json) => CoachMessage(
    _string(json, 'text'),
    isLearner: _boolean(json, 'isLearner'),
    kind: _enum(MessageKind.values, json['kind']),
  );
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('Invalid $key');
  return value;
}

bool _boolean(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! bool) throw FormatException('Invalid $key');
  return value;
}

T _enum<T extends Enum>(List<T> values, Object? name) => values.firstWhere(
  (value) => value.name == name,
  orElse: () => throw const FormatException('Unknown enum value'),
);
Map<String, Object?> _map(Object? value) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw const FormatException('Invalid record');
  }
  return Map<String, Object?>.from(value);
}

class SessionController extends ChangeNotifier {
  SessionController(
    this.lesson, {
    required this.attemptNumber,
    String? id,
    DateTime? startedAt,
    CoachProvider? coach,
    this.pace = CoachingPace.intermediate,
    CodeLanguage initialLanguage = CodeLanguage.python,
  }) : id =
           id ??
           '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${Random.secure().nextInt(0x7fffffff).toRadixString(36)}',
       startedAt = startedAt ?? DateTime.now(),
       coach = coach ?? const DisabledCoach(),
       _language = initialLanguage {
    _messages.add(CoachMessage(question, kind: MessageKind.question));
  }
  final Lesson lesson;
  final String id;
  final int attemptNumber;
  final DateTime startedAt;
  final CoachProvider coach;
  final CoachingPace pace;
  CoachingStage _stage = CoachingStage.understand;
  late CodeLanguage _language;
  final Map<CodeLanguage, String> _drafts = {};
  final Map<CoachingStage, String> _reasoning = {};
  final Map<CoachingStage, String> _answers = {};
  final List<CoachMessage> _messages = [];
  bool _checkpointReady = false, _solutionRevealed = false, _focusView = false;
  bool _reviewing = false, _disposed = false;
  int _hintsUsed = 0, _aiReviews = 0, _revision = 0;

  CoachingStage get stage => _stage;
  CodeLanguage get language => _language;
  List<CoachMessage> get messages => List.unmodifiable(_messages);
  bool get checkpointReady => _checkpointReady;
  bool get solutionRevealed => _solutionRevealed;
  bool get focusView => _focusView;
  bool get reviewing => _reviewing;
  int get hintsUsed => _hintsUsed;
  int get aiReviews => _aiReviews;
  bool get assisted => hintsUsed > 0 || solutionRevealed || aiReviews > 0;
  bool get verifiedSolved => false;
  String get starter =>
      codeSpecs[lesson.id]?.starter(_language) ??
      blind75ByLessonId[lesson.id]?.starter(_language) ??
      _language.starter;
  String get draft => _drafts[_language] ?? starter;
  String get reasoningDraft => _reasoning[_stage] ?? '';
  String get answerForReview => _stage == CoachingStage.code
      ? draft
      : reasoningDraft.trim().isNotEmpty
      ? reasoningDraft
      : _answers[_stage] ?? '';
  String get question =>
      pace.prompt(_stage, lesson.questions[_stage.index.clamp(0, 4)]);
  String get selfCheck => lesson.checks[_stage.index.clamp(0, 4)];

  void _changed() {
    _revision++;
    notifyListeners();
  }

  void toggleFocus() {
    _focusView = !_focusView;
    notifyListeners();
  }

  void changeLanguage(CodeLanguage language) {
    _language = language;
    if (_stage == CoachingStage.code) _checkpointReady = false;
    _changed();
  }

  void saveDraft(String value) {
    _drafts[_language] = value;
    if (_stage == CoachingStage.code) _checkpointReady = false;
    _changed();
  }

  void saveReasoningDraft(String value) {
    if (reasoningDraft == value) return;
    _reasoning[_stage] = value;
    _checkpointReady = false;
    _changed();
  }

  void submit(String value) {
    if (_stage == CoachingStage.complete || value.trim().isEmpty || reviewing) {
      return;
    }
    if (_stage == CoachingStage.code &&
        (value.trim() == starter.trim() ||
            value.trim() == _language.starter.trim())) {
      return;
    }
    if (_stage == CoachingStage.code) _drafts[_language] = value;
    _answers[_stage] = value.trim();
    _reasoning[_stage] = '';
    _messages.add(CoachMessage(value.trim(), isLearner: true));
    _messages.add(
      CoachMessage(
        'Review your thinking against this checkpoint:\n\n$selfCheck',
        kind: MessageKind.checkpoint,
      ),
    );
    _checkpointReady = true;
    _changed();
  }

  void advanceAfterSelfCheck() {
    if (!_checkpointReady || _stage == CoachingStage.complete || reviewing) {
      return;
    }
    _stage = CoachingStage.values[_stage.index + 1];
    _checkpointReady = false;
    _messages.add(
      CoachMessage(
        _stage == CoachingStage.complete
            ? 'Reflection saved. This attempt is self-reviewed. A future code judge will provide test-verified results.'
            : question,
        kind: MessageKind.question,
      ),
    );
    _changed();
  }

  void requestHint() {
    if (_stage == CoachingStage.complete ||
        _hintsUsed >= lesson.hints.length ||
        reviewing) {
      return;
    }
    _messages.add(
      CoachMessage(lesson.hints[_hintsUsed++], kind: MessageKind.hint),
    );
    _changed();
  }

  void revealSolution() {
    if (_solutionRevealed || reviewing) return;
    _solutionRevealed = true;
    _messages.add(
      CoachMessage(
        'Solution explanation\n\n${lesson.explanation}',
        kind: MessageKind.solution,
      ),
    );
    _changed();
  }

  Future<void> reviewWithCoach() async {
    final answer = answerForReview.trim();
    if (reviewing ||
        _stage == CoachingStage.complete ||
        answer.isEmpty ||
        (_stage == CoachingStage.code && answer == _language.starter.trim())) {
      return;
    }
    final revision = _revision;
    _reviewing = true;
    notifyListeners();
    try {
      final review = await coach.review({
        'lesson_id': lesson.id,
        'stage': stage.name,
        'language': language.name,
        'answer': answer,
        'previous_answers': _messages
            .where((message) => message.isLearner)
            .map((message) => message.text)
            .toList()
            .reversed
            .take(4)
            .map(
              (answer) =>
                  answer.length > 2000 ? answer.substring(0, 2000) : answer,
            )
            .toList(),
      });
      if (_disposed || revision != _revision) return;
      _messages.add(CoachMessage(answer, isLearner: true));
      _messages.add(
        CoachMessage(
          '${review.feedback}\n\n${review.question}',
          kind: MessageKind.feedback,
        ),
      );
      _aiReviews++;
      _revision++;
      // Model feedback never approves a checkpoint or establishes a solve.
    } on CoachUnavailable catch (error) {
      if (!_disposed && revision == _revision) {
        _messages.add(CoachMessage(error.message, kind: MessageKind.error));
      }
    } catch (_) {
      if (!_disposed && revision == _revision) {
        _messages.add(
          const CoachMessage(
            'The local coach could not reply. Your draft is available for guided practice.',
            kind: MessageKind.error,
          ),
        );
      }
    } finally {
      _reviewing = false;
      if (!_disposed) notifyListeners();
    }
  }

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'id': id,
    'lessonId': lesson.id,
    'attemptNumber': attemptNumber,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'stage': stage.name,
    'language': language.name,
    'pace': pace.name,
    'drafts': _drafts.map((key, value) => MapEntry(key.name, value)),
    'reasoning': _reasoning.map((key, value) => MapEntry(key.name, value)),
    'answers': _answers.map((key, value) => MapEntry(key.name, value)),
    'checkpointReady': checkpointReady,
    'solutionRevealed': solutionRevealed,
    'focusView': focusView,
    'hintsUsed': hintsUsed,
    'aiReviews': aiReviews,
    'messages': _messages.map((message) => message.toJson()).toList(),
  };

  factory SessionController.restore(
    Lesson lesson,
    Map<String, Object?> json, {
    CoachProvider? coach,
  }) {
    if (json['schemaVersion'] != 1 ||
        json['lessonId'] != lesson.id ||
        json['attemptNumber'] is! int ||
        (json['attemptNumber'] as int) < 1 ||
        json['hintsUsed'] is! int ||
        (json['hintsUsed'] as int) < 0 ||
        (json['hintsUsed'] as int) > lesson.hints.length ||
        json['aiReviews'] is! int ||
        (json['aiReviews'] as int) < 0 ||
        json['messages'] is! List ||
        (json['messages'] as List).isEmpty) {
      throw const FormatException('Invalid session');
    }
    final session = SessionController(
      lesson,
      attemptNumber: json['attemptNumber'] as int,
      id: _string(json, 'id'),
      startedAt: DateTime.parse(_string(json, 'startedAt')).toLocal(),
      coach: coach,
      pace: LearnerPreferences.fromJson({'pace': json['pace']}).pace,
      initialLanguage: _enum(CodeLanguage.values, json['language']),
    );
    session._stage = _enum(CoachingStage.values, json['stage']);
    session._language = _enum(CodeLanguage.values, json['language']);
    session._checkpointReady = _boolean(json, 'checkpointReady');
    session._solutionRevealed = _boolean(json, 'solutionRevealed');
    session._focusView = _boolean(json, 'focusView');
    session._hintsUsed = json['hintsUsed'] as int;
    session._aiReviews = json['aiReviews'] as int;
    for (final entry in _map(json['drafts']).entries) {
      session._drafts[_enum(CodeLanguage.values, entry.key)] = _string({
        'value': entry.value,
      }, 'value');
    }
    for (final entry in _map(json['reasoning']).entries) {
      session._reasoning[_enum(CoachingStage.values, entry.key)] = _string({
        'value': entry.value,
      }, 'value');
    }
    for (final entry in _map(json['answers']).entries) {
      session._answers[_enum(CoachingStage.values, entry.key)] = _string({
        'value': entry.value,
      }, 'value');
    }
    session._messages
      ..clear()
      ..addAll(
        (json['messages'] as List).map(
          (message) => CoachMessage.fromJson(_map(message)),
        ),
      );
    if (session.stage == CoachingStage.complete && session.checkpointReady) {
      throw const FormatException('Invalid completed checkpoint');
    }
    return session;
  }
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class WorkbookBackupPlan {
  WorkbookBackupPlan._(this._records, this.existing);
  final List<Map<String, Object?>> _records;
  final int existing;
  int get total => _records.length;
  int get additions => total - existing;
}

class BackupImportResult {
  const BackupImportResult(this.added, this.skipped);
  final int added, skipped;
}

class PracticeStore extends ChangeNotifier {
  PracticeStore({SessionRepository? repository, CoachProvider? coach})
    : repository = repository ?? MemorySessionRepository(),
      coach = coach ?? const DisabledCoach();
  final SessionRepository repository;
  final CoachProvider coach;
  LearnerPreferences preferences = const LearnerPreferences();
  bool preferencesSaving = false;
  bool preferencesSaveFailed = false;
  Future<void>? _preferencesWrite;
  final List<SessionController> _sessions = [];
  final Map<String, Map<String, Object?>> _pending = {};
  final Map<String, Map<String, Object?>> _unavailableRecords = {};
  Timer? _timer;
  Future<void>? _saving, _closing;
  bool _disposed = false;
  bool saveFailed = false;
  bool saveConflict = false;
  int unavailableAttempts = 0, _nextAttempt = 1;
  List<SessionController> get sessions => List.unmodifiable(_sessions.reversed);
  bool get saving =>
      _saving != null || _pending.isNotEmpty || preferencesSaving;
  SessionController? get latestIncomplete =>
      sessions.where((s) => s.stage != CoachingStage.complete).firstOrNull;
  int get selfReviewed => _sessions
      .where((s) => s.stage == CoachingStage.complete)
      .map((s) => s.lesson.id)
      .toSet()
      .length;

  static Future<PracticeStore> load(
    SessionRepository repository,
    List<Lesson> lessons, {
    CoachProvider? coach,
  }) async {
    final store = PracticeStore(repository: repository, coach: coach);
    final savedPreferences = await repository.loadPreferences();
    if (savedPreferences != null) {
      store.preferences = LearnerPreferences.fromJson(savedPreferences);
    }
    for (final json in await repository.load()) {
      if (json['attemptNumber'] case final int number) {
        store._nextAttempt = max(store._nextAttempt, number + 1);
      }
      try {
        final lesson = lessons
            .where((lesson) => lesson.id == json['lessonId'])
            .firstOrNull;
        if (lesson == null) {
          throw const FormatException('Unknown lesson version');
        }
        final session = SessionController.restore(
          lesson,
          json,
          coach: store.coach,
        );
        store._attach(session);
      } on FormatException {
        store.unavailableAttempts++;
        if (json['id'] case final String id) {
          store._unavailableRecords[id] = Map.of(json)..remove('_writeVersion');
        }
      }
    }
    store._sessions.sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return store;
  }

  void _attach(SessionController session) {
    _sessions.add(session);
    session.addListener(() => _scheduleSave(session));
  }

  Set<String> get _recordIds => {
    ..._sessions.map((session) => session.id),
    ..._unavailableRecords.keys,
  };

  /// Captures this window's workbook, including pending edits, without rebasing
  /// the repository's stale-write protection by reading it again.
  String exportBackup() => const JsonEncoder.withIndent('  ').convert({
    'format': 'solveit-workbook',
    'version': 1,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'sessions': [
      ..._sessions.map((session) => session.toJson()),
      ..._unavailableRecords.values,
    ],
  });

  WorkbookBackupPlan inspectBackup(String text, List<Lesson> lessons) {
    if (text.length > 2000000 || utf8.encode(text).length > 2000000) {
      throw const FormatException('Backup must be smaller than 2 MB.');
    }
    // Bound nesting before decoding untrusted JSON.
    var depth = 0;
    var quoted = false;
    var escaped = false;
    for (final char in text.codeUnits) {
      if (quoted) {
        if (escaped) {
          escaped = false;
        } else if (char == 92) {
          escaped = true;
        } else if (char == 34) {
          quoted = false;
        }
      } else if (char == 34) {
        quoted = true;
      } else if (char == 123 || char == 91) {
        if (++depth > 64) {
          throw const FormatException('Backup is too deeply nested.');
        }
      } else if (char == 125 || char == 93) {
        depth--;
      }
    }
    final data = _map(jsonDecode(text));
    if (data['format'] != 'solveit-workbook' ||
        data['version'] != 1 ||
        data['sessions'] is! List) {
      throw const FormatException('Use a SolveIt workbook backup (version 1).');
    }
    final rows = data['sessions'] as List;
    if (rows.length > 500) {
      throw const FormatException('A backup can contain at most 500 attempts.');
    }
    final ids = <String>{};
    final records = <Map<String, Object?>>[];
    for (final row in rows) {
      final record = _map(row)..remove('_writeVersion');
      final id = _string(record, 'id');
      if (id.isEmpty ||
          id.length > 200 ||
          !ids.add(id) ||
          record['schemaVersion'] is! int ||
          record['lessonId'] is! String) {
        throw const FormatException(
          'Backup contains an invalid or repeated attempt ID.',
        );
      }
      final lesson = lessons
          .where((item) => item.id == record['lessonId'])
          .firstOrNull;
      if (lesson != null && record['schemaVersion'] == 1) {
        final checked = SessionController.restore(lesson, record);
        records.add(checked.toJson());
        checked.dispose();
      } else {
        records.add(record); // Keep future/unknown content without opening it.
      }
    }
    return WorkbookBackupPlan._(records, ids.intersection(_recordIds).length);
  }

  Future<BackupImportResult> importBackup(
    WorkbookBackupPlan plan,
    List<Lesson> lessons,
  ) async {
    await flush();
    if (saveFailed || _disposed) {
      throw StateError('Save your current workbook before restoring a backup.');
    }
    final existing = _recordIds;
    final additions = {
      for (final row in plan._records)
        if (!existing.contains(row['id'])) row['id'] as String: row,
    };
    if (additions.isEmpty) return BackupImportResult(0, plan.total);
    // Repository implementations commit the whole import before the UI changes.
    await repository.saveAll(additions);
    for (final row in additions.values) {
      final lesson = lessons
          .where((item) => item.id == row['lessonId'])
          .firstOrNull;
      if (lesson != null && row['schemaVersion'] == 1) {
        _attach(SessionController.restore(lesson, row, coach: coach));
      } else {
        _unavailableRecords[row['id'] as String] = row;
        unavailableAttempts++;
      }
      if (row['attemptNumber'] case final int number) {
        _nextAttempt = max(_nextAttempt, number + 1);
      }
    }
    _sessions.sort((a, b) => a.startedAt.compareTo(b.startedAt));
    notifyListeners();
    return BackupImportResult(additions.length, plan.total - additions.length);
  }

  void _scheduleSave(SessionController session) {
    if (_disposed) return;
    _pending[session.id] = session.toJson();
    saveFailed = false;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 250), () => unawaited(flush()));
    notifyListeners();
  }

  SessionController startOrResume(Lesson lesson) {
    for (final session in sessions) {
      if (session.lesson.id == lesson.id &&
          session.stage != CoachingStage.complete) {
        return session;
      }
    }
    final session = SessionController(
      lesson,
      attemptNumber: _nextAttempt++,
      coach: coach,
      pace: preferences.pace,
      initialLanguage: preferences.preferredLanguage,
    );
    _attach(session);
    _scheduleSave(session);
    return session;
  }

  Future<void> updatePreferences(LearnerPreferences value) async {
    preferences = value;
    preferencesSaving = true;
    preferencesSaveFailed = false;
    notifyListeners();
    final previous = _preferencesWrite;
    final write = () async {
      if (previous != null) {
        try {
          await previous;
        } catch (_) {
          // A newer explicit save is allowed to recover from a failed write.
        }
      }
      await repository.savePreferences(value.toJson());
    }();
    _preferencesWrite = write;
    try {
      await write;
    } catch (_) {
      if (!identical(_preferencesWrite, write)) return;
      preferencesSaveFailed = true;
      rethrow;
    } finally {
      if (identical(_preferencesWrite, write)) {
        preferencesSaving = false;
        notifyListeners();
      }
    }
  }

  Future<void> retrySave() async {
    if (preferencesSaveFailed) await updatePreferences(preferences);
    if (saveFailed) await flush();
  }

  Future<void> flush() {
    _timer?.cancel();
    if (_saving != null) return _saving!;
    if (_pending.isEmpty) return Future.value();
    saveFailed = false;
    _saving = _writePending();
    if (!_disposed) notifyListeners();
    return _saving!;
  }

  Future<void> _writePending() async {
    try {
      while (_pending.isNotEmpty) {
        final batch = Map<String, Map<String, Object?>>.from(_pending);
        _pending.clear();
        try {
          await Future.sync(() => repository.saveAll(batch));
        } catch (error) {
          for (final entry in batch.entries) {
            _pending.putIfAbsent(entry.key, () => entry.value);
          }
          saveFailed = true;
          saveConflict = error is SessionWriteConflict;
          break;
        }
      }
      if (!saveFailed) saveConflict = false;
    } finally {
      _saving = null;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> close() => _closing ??= _close();
  Future<void> _close() async {
    _disposed = true;
    _timer?.cancel();
    await flush();
    try {
      await _preferencesWrite;
    } catch (_) {
      // A failed preference write must not prevent workbook shutdown.
    }
    await repository.close();
    coach.close();
  }

  @override
  void dispose() {
    unawaited(close());
    for (final session in _sessions) {
      session.dispose();
    }
    super.dispose();
  }
}
