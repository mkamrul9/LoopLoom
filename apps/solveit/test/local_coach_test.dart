import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solveit/data/pilot_lessons.dart';
import 'package:solveit/domain/lesson.dart';
import 'package:solveit/features/coaching/coach_provider.dart';
import 'package:solveit/features/coaching/session_controller.dart';

class WaitingCoach implements CoachProvider {
  final reply = Completer<CoachReview>();
  int calls = 0;
  @override
  bool get enabled => true;
  @override
  Future<CoachReview> review(Map<String, Object?> request) {
    calls++;
    return reply.future;
  }

  @override
  void close() {}
}

void main() {
  final valid = {
    'outcome': 'correct',
    'feedback': 'The distinct-index condition is clear.',
    'next_question': 'How would you handle duplicates?',
    'suggested_action': 'stay',
  };

  test('client supports bounded structured local feedback', () async {
    final provider = LocalCoachProvider(
      'http://127.0.0.1:8765',
      client: MockClient((request) async {
        expect(request.url.path, '/coach');
        expect(jsonDecode(request.body)['answer'], 'My explanation');
        return http.Response(jsonEncode(valid), 200);
      }),
    );
    addTearDown(provider.close);
    final review = await provider.review({'answer': 'My explanation'});
    expect(review.outcome, 'correct');
    expect(review.question, contains('duplicates'));
  });

  test(
    'remote URLs and unreadable or advancing replies are rejected',
    () async {
      for (final address in [
        'https://example.com',
        'http://localhost.evil.test:8765',
        'http://localhost:8765/remote',
        'http://user@localhost:8765',
      ]) {
        expect(() => LocalCoachProvider(address), throwsArgumentError);
      }
      for (final reply in [
        jsonEncode({...valid, 'suggested_action': 'advance'}),
        'not JSON',
        jsonEncode({...valid, 'feedback': ''}),
      ]) {
        final provider = LocalCoachProvider(
          'http://localhost:8765',
          client: MockClient((_) async => http.Response(reply, 200)),
        );
        await expectLater(
          provider.review({'answer': 'My explanation'}),
          throwsA(isA<CoachUnavailable>()),
        );
        provider.close();
      }
    },
  );

  test(
    'AI feedback counts assistance but never approves a checkpoint or solve',
    () async {
      final coach = WaitingCoach();
      final session = SessionController(
        pilotLessons.first,
        attemptNumber: 1,
        coach: coach,
      );
      addTearDown(session.dispose);
      session.saveReasoningDraft('My explanation');
      final pending = session.reviewWithCoach();
      await session.reviewWithCoach();
      expect(coach.calls, 1);
      session.toggleFocus();
      coach.reply.complete(CoachReview.fromJson(valid));
      await pending;
      expect(session.aiReviews, 1);
      expect(session.assisted, isTrue);
      expect(session.stage, CoachingStage.understand);
      expect(session.checkpointReady, isFalse);
      expect(session.verifiedSolved, isFalse);
      expect(session.reasoningDraft, 'My explanation');
    },
  );

  test('a reply for an edited draft is discarded', () async {
    final coach = WaitingCoach();
    final session = SessionController(
      pilotLessons.first,
      attemptNumber: 1,
      coach: coach,
    );
    addTearDown(session.dispose);
    session.saveReasoningDraft('Original');
    final pending = session.reviewWithCoach();
    session.saveReasoningDraft('New approach');
    coach.reply.complete(CoachReview.fromJson(valid));
    await pending;
    expect(session.aiReviews, 0);
    expect(session.reasoningDraft, 'New approach');
    expect(session.reviewing, isFalse);
  });

  test(
    'service errors leave the draft and guided checkpoints usable',
    () async {
      final provider = LocalCoachProvider(
        'http://localhost:8765',
        client: MockClient((_) async => http.Response('{}', 503)),
      );
      final session = SessionController(
        pilotLessons.first,
        attemptNumber: 1,
        coach: provider,
      );
      addTearDown(session.dispose);
      addTearDown(provider.close);
      session.saveReasoningDraft('I compare all distinct pairs.');
      await session.reviewWithCoach();
      expect(session.messages.last.kind, MessageKind.error);
      expect(session.reasoningDraft, 'I compare all distinct pairs.');
      session.submit(session.reasoningDraft);
      expect(session.checkpointReady, isTrue);
    },
  );
}
