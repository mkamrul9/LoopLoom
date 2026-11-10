import 'package:sembast/sembast.dart';

abstract interface class SessionRepository {
  Future<List<Map<String, Object?>>> load();
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots);
  Future<void> restoreDeleted(Map<String, Map<String, Object?>> snapshots);
  Future<void> deleteSession(String id);
  Future<Map<String, Object?>?> loadPreferences();
  Future<void> savePreferences(Map<String, Object?> preferences);
  Future<void> clearAll();
  Future<void> close();
}

class SessionWriteConflict implements Exception {}

class MemorySessionRepository implements SessionRepository {
  final Map<String, Map<String, Object?>> records = {};
  final Set<String> _deleted = {};
  final Set<String> _restoring = {};
  Map<String, Object?>? preferences;
  @override
  Future<List<Map<String, Object?>>> load() async => records.values.toList();
  @override
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots) async {
    if (snapshots.keys.any(
      (id) => _deleted.contains(id) && !_restoring.contains(id),
    )) {
      throw SessionWriteConflict();
    }
    records.addAll(snapshots);
    _deleted.removeAll(snapshots.keys);
  }

  @override
  Future<void> restoreDeleted(
    Map<String, Map<String, Object?>> snapshots,
  ) async {
    _restoring.addAll(snapshots.keys);
    try {
      await saveAll(snapshots);
    } finally {
      _restoring.removeAll(snapshots.keys);
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    if (!records.containsKey(id)) throw SessionWriteConflict();
    records.remove(id);
    _deleted.add(id);
  }

  @override
  Future<Map<String, Object?>?> loadPreferences() async =>
      preferences == null ? null : Map<String, Object?>.of(preferences!);
  @override
  Future<void> savePreferences(Map<String, Object?> value) async =>
      preferences = Map<String, Object?>.of(value);
  @override
  Future<void> clearAll() async {
    records.clear();
    _deleted.clear();
    _restoring.clear();
    preferences = null;
  }

  @override
  Future<void> close() async {}
}

class SembastSessionRepository implements SessionRepository {
  SembastSessionRepository(this.database);
  final Database database;
  final _sessions = stringMapStoreFactory.store('sessions');
  final _settings = stringMapStoreFactory.store('settings');
  final _deletions = stringMapStoreFactory.store('deleted_sessions');
  final Map<String, int> _versions = {};
  @override
  Future<List<Map<String, Object?>>> load() async {
    final records = await _sessions.find(database);
    for (final record in records) {
      _versions[record.key] = record.value['_writeVersion'] is int
          ? record.value['_writeVersion'] as int
          : 0;
    }
    return records.map((record) => record.value).toList();
  }

  @override
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots) =>
      _saveAll(snapshots);

  @override
  Future<void> restoreDeleted(Map<String, Map<String, Object?>> snapshots) =>
      _saveAll(snapshots, allowDeleted: true);

  Future<void> _saveAll(
    Map<String, Map<String, Object?>> snapshots, {
    bool allowDeleted = false,
  }) async {
    final nextVersions = <String, int>{};
    await database.transaction((transaction) async {
      for (final entry in snapshots.entries) {
        final tombstone = await _deletions.record(entry.key).get(transaction);
        if (tombstone != null && !allowDeleted) throw SessionWriteConflict();
        final record = _sessions.record(entry.key);
        final current = await record.get(transaction);
        final cachedVersion = _versions[entry.key];
        final currentVersion = current?['_writeVersion'] is int
            ? current!['_writeVersion'] as int
            : 0;
        if (current != null &&
            (cachedVersion == null || currentVersion != cachedVersion)) {
          throw SessionWriteConflict();
        }
        if (current == null && cachedVersion != null && cachedVersion >= 0) {
          throw SessionWriteConflict();
        }
        final version = tombstone?['version'] is int
            ? tombstone!['version'] as int
            : current == null
            ? 0
            : currentVersion;
        nextVersions[entry.key] = version + 1;
        if (tombstone != null) {
          await _deletions.record(entry.key).delete(transaction);
        }
        await record.put(transaction, {
          ...entry.value,
          '_writeVersion': version + 1,
        });
      }
    });
    _versions.addAll(nextVersions);
  }

  @override
  Future<void> deleteSession(String id) async {
    final expected = _versions[id];
    if (expected == null || expected < 0) throw SessionWriteConflict();
    await database.transaction((transaction) async {
      final record = _sessions.record(id);
      final current = await record.get(transaction);
      final currentVersion = current?['_writeVersion'] is int
          ? current!['_writeVersion'] as int
          : 0;
      if (current == null || currentVersion != expected) {
        throw SessionWriteConflict();
      }
      await record.delete(transaction);
      await _deletions.record(id).put(transaction, {'version': currentVersion});
    });
    _versions[id] = -1;
  }

  @override
  Future<Map<String, Object?>?> loadPreferences() =>
      _settings.record('learner').get(database);

  @override
  Future<void> savePreferences(Map<String, Object?> preferences) async {
    await _settings.record('learner').put(database, preferences);
  }

  @override
  Future<void> clearAll() async {
    await database.transaction((transaction) async {
      await _sessions.delete(transaction);
      await _settings.delete(transaction);
      await _deletions.delete(transaction);
    });
    _versions.clear();
  }

  @override
  Future<void> close() => database.close();
}
