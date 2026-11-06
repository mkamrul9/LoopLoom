import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/code_specs.dart';
import '../data/blind75_curriculum.dart';
import '../data/mastery300_curriculum.dart';
import '../data/sprint_references.dart';
import '../domain/lesson.dart';
import '../features/coaching/session_controller.dart';
import 'looploom_theme.dart';
import 'reference_run_panel.dart';

class CodeWorkspace extends StatelessWidget {
  const CodeWorkspace({
    super.key,
    required this.lessonId,
    required this.store,
    required this.language,
    required this.editor,
    required this.onChanged,
    required this.onLanguageChanged,
    required this.enabled,
    this.editorAction,
  });
  final String lessonId;
  final PracticeStore store;
  final CodeLanguage language;
  final TextEditingController editor;
  final ValueChanged<String> onChanged;
  final ValueChanged<CodeLanguage> onLanguageChanged;
  final bool enabled;
  final Widget? editorAction;

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

  Future<void> unlock(BuildContext context) async {
    final balance = store.preferences.pointsBalance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reveal reference code?'),
        content: Text(
          'This unlocks C++, Python, JavaScript and TypeScript for this problem for 10 study points. Current balance: $balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep practicing'),
          ),
          FilledButton(
            onPressed: balance < 10
                ? null
                : () => Navigator.pop(dialogContext, true),
            child: const Text('Unlock · 10 points'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final unlocked = await store.unlockReferenceCode(lessonId);
    if (context.mounted && !unlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the unlock. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final spec = codeSpecs[lessonId];
    final reference = sprintReferences[lessonId];
    final unlocked = store.preferences.unlockedReferenceIds.contains(lessonId);
    final blindEntry =
        mastery300ByLessonId[lessonId] ?? blind75ByLessonId[lessonId];
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
        Text(
          'Implement solve and return the result. Console input/output is not required. The starter is a signature, not a solution.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: context.palette.muted,
          ),
        ),
        if (blindEntry != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.palette.sheet,
              border: Border.all(color: context.palette.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blindEntry.hasReferenceCases
                      ? '${blind75ByLessonId.containsKey(lessonId) ? 'Blind 75' : 'Mastery 300'} · ${blindEntry.difficulty}'
                      : 'LoopLoom practice draft · ${blindEntry.difficulty}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This is an independently written study prompt. The official page has LeetCode’s canonical statement and judge. A configured private runner receives your draft only when you tap Run. LoopLoom does not submit to LeetCode or sync results; adapt the signature when you submit there.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: context.palette.muted,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final opened = await launchUrl(
                      blindEntry.challengeUri,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open the challenge page.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open official LeetCode problem'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: editor,
          enabled: enabled,
          minLines: compact ? 8 : 9,
          maxLines: compact ? 16 : 24,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.multiline,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 16,
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
                style: TextStyle(fontSize: 13, color: context.palette.muted),
              ),
            ),
          ],
        ),
        if (editorAction != null) ...[const SizedBox(height: 8), editorAction!],
        if (reference != null) ...[
          const SizedBox(height: 14),
          if (!unlocked) ...[
            Text(
              'Reference code is hidden until you choose to reveal it. ${store.preferences.pointsBalance} study points available.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: context.palette.muted,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => unlock(context),
              icon: const Icon(Icons.lock_open_outlined),
              label: const Text('Reveal code · 10 points'),
            ),
          ] else
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                'Reference code · unlocked',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Showing ${language.label}. Switch language above to see the others.',
                style: const TextStyle(fontSize: 14),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.palette.recess,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      reference.code[language] ?? '',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
        if (spec != null) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text(
              'Reference cases · expected results',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: const Text(
              'Compare these expected results with your reasoning.',
              style: TextStyle(fontSize: 14),
            ),
            children: spec.cases
                .map(
                  (item) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.palette.recess,
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
        ReferenceRunPanel(
          lessonId: lessonId,
          language: language,
          editor: editor,
          enabled: enabled,
          runnerAddress: store.preferences.runnerAddress,
          runnerToken: store.preferences.runnerToken,
        ),
      ],
    );
  }
}
