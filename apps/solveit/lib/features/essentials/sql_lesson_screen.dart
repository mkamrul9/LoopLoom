import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/coaching/session_controller.dart';
import '../../ui/looploom_theme.dart';
import '../../ui/readable_surface.dart';
import 'sql_course.dart';
import 'essentials_trace_view.dart';

class SqlLessonScreen extends StatefulWidget {
  const SqlLessonScreen({super.key, required this.lesson, required this.store});
  final SqlLesson lesson;
  final PracticeStore store;

  @override
  State<SqlLessonScreen> createState() => _SqlLessonScreenState();
}

class _SqlLessonScreenState extends State<SqlLessonScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _step = 0;
  Timer? _timer;
  bool _answerShown = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
      if (_tabs.index != 2) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  void _move(int value) {
    _timer?.cancel();
    setState(() => _step = value.clamp(0, widget.lesson.trace.length - 1));
  }

  void _play() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
      setState(() {});
      return;
    }
    if (_step == widget.lesson.trace.length - 1) _step = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 1700), (timer) {
      if (!mounted) return;
      if (_step == widget.lesson.trace.length - 1) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _step++);
      }
    });
    setState(() {});
  }

  Future<void> _markComplete(bool complete) async {
    try {
      await widget.store.setEssentialsLessonComplete(
        widget.lesson.id,
        complete,
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save progress locally. Try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => ReadableSurface(
    scale: widget.store.preferences.textScale,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title, overflow: TextOverflow.ellipsis),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Learn'),
            Tab(text: 'SQL'),
            Tab(text: 'Visual'),
            Tab(text: 'In software'),
            Tab(text: 'Check'),
          ],
        ),
      ),
      bottomNavigationBar: _tabs.index == 2
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(heightFactor: 1, child: _traceControls()),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabs,
        children: [
          _panel([
            _label('CONCEPT'),
            _heading(widget.lesson.summary),
            _body(widget.lesson.concept),
            _section('Why it matters', widget.lesson.why),
            _section('When to use it', widget.lesson.when),
            _section('How it works', widget.lesson.operation),
            _section('Watch for', widget.lesson.pitfall),
          ]),
          _panel([
            _label('SQLITE EXAMPLE'),
            _heading('See the operation'),
            _code(context, widget.lesson.sql),
            _section('Expected result', widget.lesson.result),
            _body(
              'The SQL is an example you can copy into a SQLite tool after creating the sample tables and binding values for its placeholders.',
            ),
          ]),
          _panel([
            _label('ILLUSTRATED TRACE'),
            _heading('Watch the data move'),
            _body(
              'This walkthrough illustrates the sample; it does not execute SQL.',
            ),
            const SizedBox(height: 18),
            LinearProgressIndicator(
              value: (_step + 1) / widget.lesson.trace.length,
            ),
            const SizedBox(height: 12),
            Text(
              '${_step + 1} / ${widget.lesson.trace.length} · ${widget.lesson.trace[_step].title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            _body(widget.lesson.trace[_step].explanation),
            const SizedBox(height: 18),
            EssentialsTraceView(
              input: widget.lesson.traceInput,
              active: widget.lesson.trace[_step].active,
              output: widget.lesson.trace[_step].output,
              stepIndex: _step,
              stepCount: widget.lesson.trace.length,
            ),
          ]),
          _panel([
            _label('IN A REAL APPLICATION'),
            _heading('Where you would use it'),
            _body(widget.lesson.application),
            const SizedBox(height: 18),
            _heading('Application code'),
            _code(context, widget.lesson.appCode),
            _section('Another approach', widget.lesson.alternative),
            _section('Common mistake', widget.lesson.pitfall),
            _body(
              'The application snippets use a driver-neutral database adapter; adapt its method names to your backend library.',
            ),
          ]),
          _panel([
            _label('CHECK YOUR UNDERSTANDING'),
            _heading(widget.lesson.check),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _answerShown = !_answerShown),
              icon: Icon(
                _answerShown
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              label: Text(_answerShown ? 'Hide answer' : 'Reveal answer'),
            ),
            AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              child: _answerShown
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _answerCard(context),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 25),
            ListenableBuilder(
              listenable: widget.store,
              builder: (context, _) {
                final done = widget
                    .store
                    .preferences
                    .completedEssentialsLessonIds
                    .contains(widget.lesson.id);
                return FilledButton.icon(
                  onPressed: () => _markComplete(!done),
                  icon: Icon(done ? Icons.check_circle : Icons.check),
                  label: Text(
                    done ? 'Completed · tap to undo' : 'Mark lesson complete',
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    ),
  );

  Widget _panel(List<Widget> children) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        children: children,
      ),
    ),
  );

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(value, style: noteLabel),
  );

  Widget _heading(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      value,
      style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
    ),
  );

  Widget _body(String value) =>
      Text(value, style: const TextStyle(fontSize: 16, height: 1.6));

  Widget _section(String title, String body) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        _body(body),
      ],
    ),
  );

  Widget _code(BuildContext context, String code) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Code copied')));
            }
          },
          icon: const Icon(Icons.copy_outlined, size: 18),
          label: const Text('Copy code'),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.palette.recess,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.palette.line),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _answerCard(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: context.palette.accentWash,
      borderRadius: BorderRadius.circular(12),
    ),
    child: _body(widget.lesson.answer),
  );

  Widget _traceControls() => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: Wrap(
      spacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _step == 0 ? null : () => _move(_step - 1),
          icon: const Icon(Icons.arrow_back, size: 17),
          label: const Text('Back'),
        ),
        FilledButton.tonalIcon(
          onPressed: _play,
          icon: Icon(
            _timer?.isActive == true ? Icons.pause : Icons.play_arrow,
            size: 18,
          ),
          label: Text(
            _timer?.isActive == true
                ? 'Pause'
                : _step == widget.lesson.trace.length - 1
                ? 'Replay'
                : 'Play',
          ),
        ),
        OutlinedButton.icon(
          onPressed: _step == widget.lesson.trace.length - 1
              ? null
              : () => _move(_step + 1),
          icon: const Icon(Icons.arrow_forward, size: 17),
          label: const Text('Next'),
        ),
      ],
    ),
  );
}
