import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CoachUnavailable implements Exception {
  const CoachUnavailable(this.message);
  final String message;
}

class CoachReview {
  const CoachReview({
    required this.outcome,
    required this.feedback,
    required this.question,
  });
  final String outcome, feedback, question;
  factory CoachReview.fromJson(Map<String, dynamic> json) {
    const outcomes = {
      'correct',
      'valid_but_slower',
      'incomplete',
      'incorrect',
      'needs_clarification',
    };
    if (!outcomes.contains(json['outcome']) ||
        json['suggested_action'] != 'stay' ||
        json['feedback'] is! String ||
        json['next_question'] is! String ||
        (json['feedback'] as String).trim().isEmpty ||
        (json['next_question'] as String).trim().isEmpty ||
        (json['feedback'] as String).length > 1500 ||
        (json['next_question'] as String).length > 500) {
      throw const CoachUnavailable(
        'The local coach returned an unreadable reply. Your work is still saved.',
      );
    }
    return CoachReview(
      outcome: json['outcome'],
      feedback: json['feedback'],
      question: json['next_question'],
    );
  }
}

abstract interface class CoachProvider {
  bool get enabled;
  Future<CoachReview> review(Map<String, Object?> request);
  void close();
}

class DisabledCoach implements CoachProvider {
  const DisabledCoach();
  @override
  bool get enabled => false;
  @override
  Future<CoachReview> review(Map<String, Object?> request) =>
      throw const CoachUnavailable(
        'Local coaching is not configured. Guided practice is available.',
      );
  @override
  void close() {}
}

/// Development connection: exact loopback/emulator hosts only; no paid provider.
class LocalCoachProvider implements CoachProvider {
  LocalCoachProvider(String address, {http.Client? client})
    : endpoint = _validate(address),
      _client = client ?? http.Client();
  final Uri endpoint;
  final http.Client _client;
  static Uri _validate(String address) {
    final uri = Uri.parse(address);
    if (uri.scheme != 'http' ||
        !{'127.0.0.1', 'localhost', '10.0.2.2'}.contains(uri.host) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !{'', '/'}.contains(uri.path) ||
        uri.port < 1) {
      throw ArgumentError('The coach must use a local development address.');
    }
    return uri.resolve('/coach');
  }

  @override
  bool get enabled => true;
  @override
  Future<CoachReview> review(Map<String, Object?> request) async {
    final answer = request['answer'];
    if (answer is! String || answer.trim().isEmpty || answer.length > 12000) {
      throw const CoachUnavailable(
        'Use an explanation or code draft of at most 12000 characters for local feedback.',
      );
    }
    try {
      return await _request(request).timeout(const Duration(seconds: 60));
    } on CoachUnavailable {
      rethrow;
    } on TimeoutException {
      throw const CoachUnavailable(
        'The local coach took too long. Continue guided practice or try again.',
      );
    } catch (_) {
      throw const CoachUnavailable(
        'The local coach is unavailable. Start the local coach service, or continue guided practice.',
      );
    }
  }

  Future<CoachReview> _request(Map<String, Object?> body) async {
    final request = http.Request('POST', endpoint)
      ..followRedirects = false
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);
    final response = await _client.send(request);
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      if (bytes.length + chunk.length > 32768) {
        throw const CoachUnavailable(
          'The local coach reply was too large. Please try again.',
        );
      }
      bytes.addAll(chunk);
    }
    if (response.statusCode != 200) {
      if (response.statusCode == 429) {
        throw const CoachUnavailable(
          'The local coach is busy. Please try again shortly.',
        );
      }
      if (response.statusCode == 400) {
        throw const CoachUnavailable(
          'The local coach could not read this request. Try a shorter explanation.',
        );
      }
      throw const CoachUnavailable(
        'The local coach is not ready. Check that Ollama and a local model are running, then try again.',
      );
    }
    return CoachReview.fromJson(
      jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
    );
  }

  @override
  void close() => _client.close();
}

CoachProvider configuredCoach() {
  const address = String.fromEnvironment('SOLVEIT_COACH_URL');
  return address.isEmpty ? const DisabledCoach() : LocalCoachProvider(address);
}
