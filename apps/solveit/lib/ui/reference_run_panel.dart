import 'package:flutter/material.dart';
import '../data/code_specs.dart';
import '../domain/lesson.dart';
import '../features/coaching/reference_runner.dart';
import 'looploom_theme.dart';

class ReferenceRunPanel extends StatefulWidget {
  const ReferenceRunPanel({
    super.key,
    required this.lessonId,
    required this.language,
    required this.editor,
    required this.enabled,
    this.runnerAddress = '',
    this.runnerToken = '',
    this.runner,
  });
  final String lessonId;
  final CodeLanguage language;
  final TextEditingController editor;
  final bool enabled;
  final String runnerAddress, runnerToken;
  final ReferenceRunnerClient? runner;
  @override
  State<ReferenceRunPanel> createState() => _ReferenceRunPanelState();
}

class _ReferenceRunPanelState extends State<ReferenceRunPanel> {
  ReferenceRunnerClient? client;
  ReferenceRun? result;
  bool _ownsClient = false;
  bool busy = false;
  String? note;
  late String lastText;
  @override
  void initState() {
    super.initState();
    _configureClient();
    lastText = widget.editor.text;
    widget.editor.addListener(invalidate);
  }

  void _configureClient() {
    if (_ownsClient) client?.close();
    _ownsClient = false;
    client = widget.runner;
    if (client != null) return;
    const buildAddress = String.fromEnvironment('SOLVEIT_RUNNER_URL');
    final address = widget.runnerAddress.isEmpty
        ? buildAddress
        : widget.runnerAddress;
    if (address.isEmpty) return;
    try {
      client = ReferenceRunnerClient(address, token: widget.runnerToken);
      _ownsClient = true;
    } catch (_) {
      client = null;
      note = 'Check the runner address and token in Settings.';
    }
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
    if (oldWidget.runnerAddress != widget.runnerAddress ||
        oldWidget.runnerToken != widget.runnerToken ||
        oldWidget.runner != widget.runner) {
      _configureClient();
      result = null;
    }
  }

  @override
  void dispose() {
    widget.editor.removeListener(invalidate);
    if (_ownsClient) client?.close();
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
    final spec = codeSpecs[widget.lessonId];
    if (spec == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'LoopLoom does not have local reference cases for this problem yet. Your draft is saved here; use the linked challenge page to run its official tests.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: context.palette.muted,
          ),
        ),
      );
    }
    if (client == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Set a self-hosted runner address in Settings to run these cases from your phone. Your draft stays saved here.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: context.palette.muted,
          ),
        ),
      );
    }
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
          style: TextStyle(
            fontSize: 12,
            height: 1.6,
            color: context.palette.muted,
          ),
        ),
        if (widget.language == CodeLanguage.typescript) ...[
          const SizedBox(height: 8),
          Text(
            'TypeScript runs with types removed; types are not checked. Use a synchronous solve function with no imports or exports. Enums, parameter properties and other syntax requiring transformation are unsupported.',
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: context.palette.muted,
            ),
          ),
        ],
        if (widget.language == CodeLanguage.cpp) ...[
          const SizedBox(height: 8),
          Text(
            'C++ compiles as C++17 for these reference cases. Implement solve with the lesson signature. Compilation and execution happen in a local development container.',
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: context.palette.muted,
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
