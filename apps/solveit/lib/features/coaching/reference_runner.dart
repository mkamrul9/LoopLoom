import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/code_specs.dart';

class ReferenceRun {
  const ReferenceRun(this.passed, this.statuses);
  final int passed;
  final List<String> statuses;
}

class ReferenceRunnerClient {
  ReferenceRunnerClient(
    String address, {
    String token = '',
    http.Client? client,
  }) : client = client ?? http.Client() {
    final uri = Uri.parse(address);
    final loopback = {'127.0.0.1', 'localhost', '10.0.2.2'}.contains(uri.host);
    final octets = uri.host.split('.').map(int.tryParse).toList();
    final privateLan =
        octets.length == 4 &&
        octets.every((part) => part != null && part >= 0 && part <= 255) &&
        (octets[0] == 10 ||
            (octets[0] == 172 && octets[1]! >= 16 && octets[1]! <= 31) ||
            (octets[0] == 192 && octets[1] == 168));
    if (uri.scheme != 'http' ||
        !(loopback || privateLan) ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !{'', '/'}.contains(uri.path) ||
        uri.port < 1 ||
        (privateLan && token.length < 32)) {
      throw ArgumentError(
        'Use a private runner address and a 32-character LAN token',
      );
    }
    endpoint = uri.resolve('/run');
    this.token = token;
  }
  final http.Client client;
  late final String token;
  late final Uri endpoint;
  Future<ReferenceRun> run(
    String lesson,
    String source, {
    String language = 'javascript',
  }) async {
    if (!{'cpp', 'javascript', 'typescript', 'python'}.contains(language) ||
        !codeSpecs.containsKey(lesson) ||
        utf8.encode(source).length > 32000 ||
        source.trim().isEmpty) {
      throw const FormatException('Use a draft of at most 32000 bytes.');
    }
    return _request(
      lesson,
      source,
      language,
    ).timeout(const Duration(seconds: 35));
  }

  Future<ReferenceRun> _request(
    String lesson,
    String source,
    String language,
  ) async {
    final request = http.Request('POST', endpoint)
      ..followRedirects = false
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'lesson_id': lesson,
        'language': language,
        'source': source,
      });
    if (token.isNotEmpty) request.headers['Authorization'] = 'Bearer $token';
    final response = await client.send(request);
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      if (bytes.length + chunk.length > 32768) {
        throw const FormatException('Oversized runner reply');
      }
      bytes.addAll(chunk);
    }
    if (response.statusCode != 200) {
      throw const FormatException('Runner unavailable');
    }
    final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final cases = data['cases'];
    final expected = codeSpecs[lesson]!.cases;
    const allowed = {
      'matched',
      'compile_error',
      'wrong_answer',
      'syntax_error',
      'unsupported_syntax',
      'runtime_error',
      'time_limit',
      'output_limit',
      'memory_limit',
      'input_modified',
    };
    if (data['suite'] != 'reference-v1' ||
        data['language'] != language ||
        data['verified_solve'] != false ||
        data['total'] != expected.length ||
        cases is! List ||
        cases.length != expected.length ||
        data['passed'] is! int) {
      throw const FormatException('Invalid runner reply');
    }
    final statuses = <String>[];
    for (var i = 0; i < cases.length; i++) {
      final row = cases[i];
      if (row is! Map ||
          row['label'] != expected[i].label ||
          !allowed.contains(row['status'])) {
        throw const FormatException('Invalid case result');
      }
      statuses.add(row['status'] as String);
    }
    if (data['passed'] != statuses.where((s) => s == 'matched').length) {
      throw const FormatException('Invalid match count');
    }
    return ReferenceRun(data['passed'] as int, statuses);
  }

  void close() => client.close();
}
