import 'package:flutter/material.dart';
import '../data/code_specs.dart';
import '../domain/lesson.dart';
import '../features/coaching/reference_runner.dart';
import 'solveit_theme.dart';

class ReferenceRunPanel extends StatefulWidget {
  const ReferenceRunPanel({
    super.key,
    required this.lessonId,
    required this.language,
    required this.editor,
    required this.enabled,
    this.runner,
  });
  final String lessonId;
  final CodeLanguage language;
  final TextEditingController editor;
  final bool enabled;
  final ReferenceRunnerClient? runner;
  @override
  State<ReferenceRunPanel> createState() => _ReferenceRunPanelState();
}

class _ReferenceRunPanelState extends State<ReferenceRunPanel> {
  ReferenceRunnerClient? client;
  ReferenceRun? result;
  bool busy = false;
  String? note;
  late String lastText;
  @override
  void initState() {
    super.initState();
    const address = String.fromEnvironment('SOLVEIT_RUNNER_URL');
    client =
        widget.runner ??
        (address.isEmpty ? null : ReferenceRunnerClient(address));
    lastText = widget.editor.text;
    widget.editor.addListener(invalidate);
  }

  void invalidate() {
    if (lastText == widget.editor.text) return;
    lastText = widget.editor.text;
    if (result != null || note != null) {
      setState(() {
        result = null;
        note = null;
      });
    }
  }

  @override
  void didUpdateWidget(covariant ReferenceRunPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editor != widget.editor) {
      oldWidget.editor.removeListener(invalidate);
      widget.editor.addListener(invalidate);
      lastText = widget.editor.text;
      result = null;
      note = null;
    }
    if (oldWidget.language != widget.language ||
        oldWidget.lessonId != widget.lessonId) {
      result = null;
      note = null;
    }
  }

  @override
  void dispose() {
    widget.editor.removeListener(invalidate);
    client?.close();
    super.dispose();
  }

  Future<void> run() async {
    if (busy ||
        !widget.enabled ||
        client == null ||
        !{
          CodeLanguage.cpp,
          CodeLanguage.javascript,
          CodeLanguage.typescript,
          CodeLanguage.python,
        }.contains(widget.language)) {
      return;
    }
    final source = widget.editor.text,
        lesson = widget.lessonId,
        language = widget.language;
    setState(() {
      busy = true;
      result = null;
      note = null;
    });
    try {
      final response = await client!.run(
        lesson,
        source,
        language: language.name,
      );
      if (!mounted) return;
      setState(() {
        if (source == widget.editor.text &&
            lesson == widget.lessonId &&
            language == widget.language) {
          result = response;
        } else {
          note =
              'The draft changed during execution. Run the current draft again.';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => note =
              'Reference execution is unavailable or the reply could not be read. Your draft is preserved.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (client == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Execution is not available in this build. You can save your code for self-review.',
          style: TextStyle(fontSize: 12, height: 1.6, color: StudyColors.muted),
        ),
      );
    }
    final spec = codeSpecs[widget.lessonId]!;
    final supported = {
      CodeLanguage.cpp,
      CodeLanguage.javascript,
      CodeLanguage.typescript,
      CodeLanguage.python,
    }.contains(widget.language);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          supported
              ? 'Local development execution · reference cases only. This does not establish a verified solve.'
              : 'Reference execution currently supports C++, JavaScript, TypeScript and Python. You can keep drafting in any language.',
          style: const TextStyle(
            fontSize: 12,
            height: 1.6,
            color: StudyColors.muted,
          ),
        ),
        if (widget.language == CodeLanguage.typescript) ...[
          const SizedBox(height: 8),
          const Text(
            'TypeScript runs with types removed; types are not checked. Use a synchronous solve function with no imports or exports. Enums, parameter properties and other syntax requiring transformation are unsupported.',
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: StudyColors.muted,
            ),
          ),
        ],
        if (widget.language == CodeLanguage.cpp) ...[
          const SizedBox(height: 8),
          const Text(
            'C++ compiles as C++17 for these reference cases. Implement solve with the lesson signature. Compilation and execution happen in a local development container.',
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: StudyColors.muted,
            ),
          ),
        ],
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: widget.editor,
          builder: (_, _) => OutlinedButton(
            onPressed:
                !busy &&
                    widget.enabled &&
                    supported &&
                    widget.editor.text.trim().isNotEmpty &&
                    widget.editor.text.trim() !=
                        spec.starter(widget.language).trim()
                ? run
                : null,
            child: Text(
              busy ? 'Running reference cases…' : 'Run reference cases',
            ),
          ),
        ),
        if (result case final outcome?) ...[
          const SizedBox(height: 12),
          Text(
            '${outcome.passed}/${outcome.statuses.length} reference cases matched',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          ...outcome.statuses.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${spec.cases[entry.$1].label}: ${entry.$2.replaceAll('_', ' ')}',
                style: const TextStyle(fontSize: 12, height: 1.5),
              ),
            ),
          ),
        ],
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                note!,
                style: const TextStyle(fontSize: 12, height: 1.6),
              ),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
