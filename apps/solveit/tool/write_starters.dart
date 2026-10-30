// Emits trusted authored scaffolds for developer syntax checks, never learner drafts.
import 'dart:convert';
import 'dart:io';
import 'package:solveit/data/code_specs.dart';
import 'package:solveit/domain/lesson.dart';

void main() {
  final output = Directory('../../.local/starter-validation')
    ..createSync(recursive: true);
  const extensions = {
    CodeLanguage.cpp: 'cpp',
    CodeLanguage.python: 'py',
    CodeLanguage.javascript: 'js',
    CodeLanguage.typescript: 'ts',
  };
  for (final entry in codeSpecs.entries) {
    for (final language in CodeLanguage.values) {
      File(
        '${output.path}/${entry.key}.${extensions[language]}',
      ).writeAsStringSync(entry.value.starter(language));
    }
  }
  File('${output.path}/manifest.json').writeAsStringSync(
    jsonEncode({
      'kind': 'trusted_authored_scaffolds_not_learner_code',
      'count': codeSpecs.length * CodeLanguage.values.length,
    }),
  );
  stdout.writeln('Wrote 24 trusted starter files to ${output.absolute.path}');
}
