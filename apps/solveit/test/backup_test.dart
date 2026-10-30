import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:solveit/data/pilot_lessons.dart';
import 'package:solveit/data/session_repository.dart';
import 'package:solveit/domain/lesson.dart';
import 'package:solveit/features/coaching/session_controller.dart';

class RejectingRepository extends MemorySessionRepository {
  @override
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots) async =>
      throw StateError('Full disk');
}

void main() {
  test('an import collision rolls back the entire database batch', () async {
    final source = PracticeStore();
    source.startOrResume(pilotLessons[0]);
    source.startOrResume(pilotLessons[1]);
    final db = await databaseFactoryMemory.openDatabase('backup-atomic');
    final repository = SembastSessionRepository(db);
    final target = await PracticeStore.load(repository, pilotLessons);
    final plan = target.inspectBackup(source.exportBackup(), pilotLessons);
    final competing = SembastSessionRepository(db);
    final collision = source.sessions.first;
    await competing.saveAll({collision.id: collision.toJson()});
    await expectLater(
      target.importBackup(plan, pilotLessons),
      throwsA(isA<SessionWriteConflict>()),
    );
    expect(target.sessions, isEmpty);
    expect((await repository.load()).length, 1);
    await target.close();
    await source.close();
  });
  test(
    'backup recovers unsent reasoning, language drafts and assistance on a fresh device',
    () async {
      final source = PracticeStore();
      final session = source.startOrResume(pilotLessons.first);
      session.saveReasoningDraft('Distinct positions, including duplicates.');
      session.changeLanguage(CodeLanguage.typescript);
      session.saveDraft('const draft = 42;');
      session.requestHint();
      final target = PracticeStore();
      final plan = target.inspectBackup(source.exportBackup(), pilotLessons);
      expect(plan.additions, 1);
      await target.importBackup(plan, pilotLessons);
      final restored = target.sessions.single;
      expect(restored.reasoningDraft, session.reasoningDraft);
      expect(restored.draft, session.draft);
      expect(restored.hintsUsed, 1);
      expect(restored.verifiedSolved, false);
      final repo = target.repository;
      await target.close();
      final reopened = await PracticeStore.load(repo, pilotLessons);
      expect(reopened.sessions.single.reasoningDraft, session.reasoningDraft);
      await reopened.close();
      await source.close();
    },
  );

  test(
    'repeat import keeps the local version and adds no duplicates',
    () async {
      final store = PracticeStore();
      final session = store.startOrResume(pilotLessons.first);
      session.saveReasoningDraft('Older');
      final backup = store.exportBackup();
      session.saveReasoningDraft('Newer local draft');
      final plan = store.inspectBackup(backup, pilotLessons);
      expect(plan.existing, 1);
      final result = await store.importBackup(plan, pilotLessons);
      expect(result.added, 0);
      expect(result.skipped, 1);
      expect(store.sessions.single.reasoningDraft, 'Newer local draft');
      await store.close();
    },
  );

  test(
    'malformed and duplicate records are rejected before changing storage',
    () async {
      final source = PracticeStore();
      source.startOrResume(pilotLessons.first);
      final data = jsonDecode(source.exportBackup()) as Map<String, dynamic>;
      final row = (data['sessions'] as List).single;
      final target = PracticeStore();
      for (final text in [
        'not json',
        jsonEncode({...data, 'version': 99}),
        jsonEncode({
          ...data,
          'sessions': [row, row],
        }),
        jsonEncode({
          ...data,
          'sessions': [
            row,
            {...row, 'id': 'broken', 'stage': 'invented'},
          ],
        }),
        ' ' * 2000001,
        '[' * 65,
      ]) {
        expect(
          () => target.inspectBackup(text, pilotLessons),
          throwsFormatException,
        );
        expect(target.sessions, isEmpty);
        expect((await target.repository.load()), isEmpty);
      }
      await source.close();
      await target.close();
    },
  );

  test('failed import leaves existing workbook intact', () async {
    final source = PracticeStore();
    source.startOrResume(pilotLessons.first);
    final target = PracticeStore(repository: RejectingRepository());
    final plan = target.inspectBackup(source.exportBackup(), pilotLessons);
    await expectLater(
      target.importBackup(plan, pilotLessons),
      throwsStateError,
    );
    expect(target.sessions, isEmpty);
    await source.close();
    await target.close();
  });

  test('unknown lesson records survive import and re-export', () async {
    final store = PracticeStore();
    final text = jsonEncode({
      'format': 'solveit-workbook',
      'version': 1,
      'sessions': [
        {
          'id': 'future',
          'lessonId': 'future-lesson',
          'schemaVersion': 2,
          'notes': 'Keep me',
        },
      ],
    });
    await store.importBackup(
      store.inspectBackup(text, pilotLessons),
      pilotLessons,
    );
    expect(store.unavailableAttempts, 1);
    expect(store.sessions, isEmpty);
    expect(jsonDecode(store.exportBackup())['sessions'][0]['notes'], 'Keep me');
    await store.close();
  });

  test('export does not rebase a stale window and permit an overwrite', () async {
    final db = await databaseFactoryMemory.openDatabase('backup-stale');
    final first = await PracticeStore.load(
      SembastSessionRepository(db),
      pilotLessons,
    );
    final original = first.startOrResume(pilotLessons.first);
    await first.flush();
    final second = await PracticeStore.load(
      SembastSessionRepository(db),
      pilotLessons,
    );
    original.saveReasoningDraft('Newest');
    await first.flush();
    second.exportBackup();
    second.sessions.single.saveReasoningDraft('Stale');
    await second.flush();
    expect(second.saveConflict, true);
    // Both repositories share this test database; close only after both stores flush.
    await second.close();
    await first.close();
  });
}
