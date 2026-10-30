import 'package:flutter/material.dart';
import '../data/code_specs.dart';
import '../domain/lesson.dart';
import 'solveit_theme.dart';

class CodeWorkspace extends StatelessWidget {
  const CodeWorkspace({
    super.key,
    required this.lessonId,
    required this.language,
    required this.editor,
    required this.onChanged,
    required this.onLanguageChanged,
    required this.enabled,
  });
  final String lessonId;
  final CodeLanguage language;
  final TextEditingController editor;
  final ValueChanged<String> onChanged;
  final ValueChanged<CodeLanguage> onLanguageChanged;
  final bool enabled;

  void insertSpaces() {
    final selection = editor.selection;
    final start = selection.isValid ? selection.start : editor.text.length;
    final end = selection.isValid ? selection.end : editor.text.length;
    final text = editor.text.replaceRange(start, end, '    ');
    editor.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + 4),
    );
    onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    final spec = codeSpecs[lessonId];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<CodeLanguage>(
          initialValue: language,
          decoration: const InputDecoration(labelText: 'Code language'),
          items: CodeLanguage.values
              .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
              .toList(),
          onChanged: enabled
              ? (value) {
                  if (value != null) onLanguageChanged(value);
                }
              : null,
        ),
        const SizedBox(height: 14),
        const Text(
          'Implement solve and return the result. Console input/output is not required. The starter is a signature, not a solution.',
          style: TextStyle(fontSize: 12, height: 1.6, color: StudyColors.muted),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: editor,
          enabled: enabled,
          minLines: 9,
          maxLines: 24,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.multiline,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.7,
          ),
          decoration: const InputDecoration(
            labelText: 'Your code draft',
            alignLabelWithHint: true,
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              onPressed: enabled ? insertSpaces : null,
              child: const Text('Insert 4 spaces'),
            ),
            ListenableBuilder(
              listenable: editor,
              builder: (_, _) => Text(
                '${editor.text.split('\n').length} lines · ${editor.text.runes.length} characters',
                style: const TextStyle(fontSize: 11, color: StudyColors.muted),
              ),
            ),
          ],
        ),
        if (spec != null) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              'Reference cases · not run',
              style: TextStyle(fontSize: 14),
            ),
            subtitle: const Text(
              'Compare these expected results with your reasoning.',
              style: TextStyle(fontSize: 12),
            ),
            children: spec.cases
                .map(
                  (item) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StudyColors.recess,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          item.input,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('EXPECTED', style: noteLabel),
                        const SizedBox(height: 4),
                        SelectableText(
                          item.expected,
                          style: const TextStyle(fontSize: 13, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
