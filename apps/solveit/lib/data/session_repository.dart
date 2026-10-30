import 'package:sembast/sembast.dart';

abstract interface class SessionRepository {
  Future<List<Map<String, Object?>>> load();
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots);
  Future<void> close();
}

class SessionWriteConflict implements Exception {}

class MemorySessionRepository implements SessionRepository {
  final Map<String, Map<String, Object?>> records = {};
  @override
  Future<List<Map<String, Object?>>> load() async => records.values.toList();
  @override
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots) async =>
      records.addAll(snapshots);
  @override
  Future<void> close() async {}
}

class SembastSessionRepository implements SessionRepository {
  SembastSessionRepository(this.database);
  final Database database;
  final _sessions = stringMapStoreFactory.store('sessions');
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
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots) async {
    await database.transaction((transaction) async {
      for (final entry in snapshots.entries) {
        final record = _sessions.record(entry.key);
        final current = await record.get(transaction);
        final currentVersion = current?['_writeVersion'] ?? 0;
        final expected = _versions[entry.key] ?? 0;
        if (currentVersion != expected) throw SessionWriteConflict();
        await record.put(transaction, {
          ...entry.value,
          '_writeVersion': expected + 1,
        });
      }
    });
    for (final id in snapshots.keys) {
      _versions[id] = (_versions[id] ?? 0) + 1;
    }
  }

  @override
  Future<void> close() => database.close();
}
