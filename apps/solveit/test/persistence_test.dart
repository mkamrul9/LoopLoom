import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:solveit/data/pilot_lessons.dart';
import 'package:solveit/data/session_repository.dart';
import 'package:solveit/domain/lesson.dart';
import 'package:solveit/features/coaching/session_controller.dart';

class FailingRepository extends MemorySessionRepository {
  bool failing = true;
  @override
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots) {
    if (failing) throw StateError('Disk unavailable');
    return super.saveAll(snapshots);
  }
}

class DelayedRepository extends MemorySessionRepository {
  final firstWrite = Completer<void>();
  int writes = 0;
  @override
  Future<void> saveAll(Map<String, Map<String, Object?>> snapshots) async {
    if (writes++ == 0) await firstWrite.future;
    await super.saveAll(snapshots);
  }
}

void main() {
  test(
    'a stale writer cannot overwrite work saved by another window',
    () async {
      final database = await databaseFactoryMemory.openDatabase(
        'conflict-test',
      );
      final first = SembastSessionRepository(database);
      final second = SembastSessionRepository(database);
      await first.saveAll({
        'attempt': {'id': 'attempt', 'answer': 'Original'},
      });
      await second.load();
      await first.saveAll({
        'attempt': {'id': 'attempt', 'answer': 'Newer work'},
      });
      await expectLater(
        second.saveAll({
          'attempt': {'id': 'attempt', 'answer': 'Stale work'},
        }),
        throwsA(isA<SessionWriteConflict>()),
      );
      expect((await first.load()).single['answer'], 'Newer work');
      await database.close();
    },
  );
  test(
    'actual file database restores attempts, drafts, hints and checkpoints after reopening',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'solveit-storage-test-',
      );
      addTearDown(() async {
        if (!directory.absolute.path.startsWith(
          Directory.systemTemp.absolute.path,
        )) {
          throw StateError('Unexpected test directory');
        }
        await directory.delete(recursive: true);
      });
      final path = '${directory.path}/workbook.db';
      final first = await PracticeStore.load(
        SembastSessionRepository(await databaseFactoryIo.openDatabase(path)),
        pilotLessons,
      );
      final session = first.startOrResume(pilotLessons.first);
      session.saveReasoningDraft(
        'An unsent explanation, including why duplicates matter.',
      );
      session.toggleFocus();
      session.saveDraft('print("python draft")');
      session.changeLanguage(CodeLanguage.cpp);
      session.saveDraft('int solve() { return 0; }');
      session.requestHint();
      session.revealSolution();
      final expected = session.toJson();
      await first.close();
      first.dispose();

      final second = await PracticeStore.load(
        SembastSessionRepository(await databaseFactoryIo.openDatabase(path)),
        pilotLessons,
      );
      final resumed = second.startOrResume(pilotLessons.first);
      expect(resumed.toJson(), expected);
      expect(resumed.reasoningDraft, contains('unsent explanation'));
      expect(resumed.focusView, isTrue);
      expect(resumed.assisted, isTrue);
      expect(resumed.verifiedSolved, isFalse);
      resumed.changeLanguage(CodeLanguage.python);
      expect(resumed.draft, 'print("python draft")');
      resumed.submit('My restatement');
      await second.flush();
      await second.close();
      second.dispose();

      final third = await PracticeStore.load(
        SembastSessionRepository(await databaseFactoryIo.openDatabase(path)),
        pilotLessons,
      );
      expect(third.sessions.single.checkpointReady, isTrue);
      third.sessions.single.advanceAfterSelfCheck();
      expect(third.sessions.single.stage, CoachingStage.approach);
      expect(third.sessions.single.reasoningDraft, isEmpty);
      await third.close();
      third.dispose();
    },
  );

  test(
    'save failures retain the latest draft and a retry persists it',
    () async {
      final repository = FailingRepository();
      final store = PracticeStore(repository: repository);
      final session = store.startOrResume(pilotLessons.first);
      session.saveReasoningDraft('First draft');
      await store.flush();
      expect(store.saveFailed, isTrue);
      session.saveReasoningDraft('The newer draft survives');
      repository.failing = false;
      await store.flush();
      expect(store.saveFailed, isFalse);
      expect(store.saving, isFalse);
      final restored = await PracticeStore.load(repository, pilotLessons);
      expect(
        restored.sessions.single.reasoningDraft,
        'The newer draft survives',
      );
      await restored.close();
      restored.dispose();
      await store.close();
      store.dispose();
    },
  );

  test(
    'edits during a pending write are committed after the older snapshot',
    () async {
      final repository = DelayedRepository();
      final store = PracticeStore(repository: repository);
      final session = store.startOrResume(pilotLessons.first);
      session.saveReasoningDraft('Older draft');
      final saving = store.flush();
      session.saveReasoningDraft('Newest draft');
      repository.firstWrite.complete();
      await saving;
      expect(repository.writes, 2);
      final restored = await PracticeStore.load(repository, pilotLessons);
      expect(restored.sessions.single.reasoningDraft, 'Newest draft');
      await restored.close();
      restored.dispose();
      await store.close();
      store.dispose();
    },
  );

  test(
    'unsupported records are kept and completed attempts remain in history',
    () async {
      final repository = MemorySessionRepository();
      repository.records['future-record'] = {
        'schemaVersion': 999,
        'lessonId': 'future',
        'attemptNumber': 20,
      };
      final store = await PracticeStore.load(repository, pilotLessons);
      expect(store.unavailableAttempts, 1);
      final session = store.startOrResume(pilotLessons.first);
      expect(session.attemptNumber, 21);
      for (var i = 0; i < 5; i++) {
        session.submit('My work');
        session.advanceAfterSelfCheck();
      }
      await store.flush();
      final restored = await PracticeStore.load(repository, pilotLessons);
      expect(restored.selfReviewed, 1);
      expect(restored.sessions.single.stage, CoachingStage.complete);
      expect(restored.startOrResume(pilotLessons.first).id, isNot(session.id));
      expect(repository.records.containsKey('future-record'), isTrue);
      await restored.close();
      restored.dispose();
      await store.close();
      store.dispose();
    },
  );
}
