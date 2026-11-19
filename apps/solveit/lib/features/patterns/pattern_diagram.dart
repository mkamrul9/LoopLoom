part of 'pattern_library.dart';

class PatternDiagram extends StatelessWidget {
  const PatternDiagram({
    super.key,
    required this.lesson,
    required this.frame,
    required this.frameIndex,
  });

  final PatternLesson lesson;
  final PatternFrame frame;
  final int frameIndex;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 330);
    return Container(
      key: const Key('pattern-diagram'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.recess,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISUAL TRACE',
            style: noteLabel.copyWith(color: context.palette.muted),
          ),
          const SizedBox(height: 14),
          AnimatedSize(duration: duration, child: _visual(context)),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: duration,
            child: Container(
              key: ValueKey('state-$frameIndex'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.palette.sheet,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: context.palette.accent, width: 3),
                ),
              ),
              child: Text(
                frame.state,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visual(BuildContext context) => switch (lesson.visual) {
    PatternVisual.sequence || PatternVisual.numberLine => _sequence(
      context,
      lesson.tokens,
      showCursor: true,
    ),
    PatternVisual.links => _linked(context),
    PatternVisual.stack => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sequence(context, lesson.tokens, showCursor: true),
        const SizedBox(height: 13),
        _caption(context, 'UNRESOLVED STACK'),
        const SizedBox(height: 6),
        _stack(context),
      ],
    ),
    PatternVisual.tree ||
    PatternVisual.trie ||
    PatternVisual.branches ||
    PatternVisual.heap ||
    PatternVisual.graph => _nodeGraph(context),
    PatternVisual.grid => _grid(context),
    PatternVisual.intervals => _intervals(context),
    PatternVisual.bits => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sequence(context, lesson.tokens, showCursor: true),
        const SizedBox(height: 12),
        _caption(context, 'XOR CHANGES'),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 260),
          child: KeyedSubtree(
            key: ValueKey(frame.display.join('|')),
            child: _sequence(context, frame.display, highlightAll: true),
          ),
        ),
      ],
    ),
  };

  Widget _caption(BuildContext context, String label) => Text(
    label,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: context.palette.muted,
    ),
  );

  Widget _tile(
    BuildContext context,
    String token,
    bool active, {
    double? width,
  }) => AnimatedScale(
    scale: active ? 1.04 : 1,
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 260),
    curve: Curves.easeOutCubic,
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      constraints: BoxConstraints(minWidth: width ?? 43, minHeight: 43),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: active ? context.palette.accentWash : context.palette.sheet,
        border: Border.all(
          color: active ? context.palette.accent : context.palette.line,
          width: active ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        token,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget _sequence(
    BuildContext context,
    List<String> tokens, {
    bool highlightAll = false,
    bool showCursor = false,
  }) {
    const cell = 50.0;
    const gap = 7.0;
    final width = tokens.length * cell + (tokens.length - 1) * gap;
    final active = frame.active.isEmpty
        ? 0
        : frame.active.last.clamp(0, tokens.length - 1);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (final (index, token) in tokens.indexed) ...[
                  SizedBox(
                    width: cell,
                    child: _tile(
                      context,
                      token,
                      highlightAll || frame.active.contains(index),
                    ),
                  ),
                  if (index < tokens.length - 1) const SizedBox(width: gap),
                ],
              ],
            ),
            if (showCursor)
              SizedBox(
                height: 23,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      key: const Key('pattern-cursor'),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 360),
                      curve: Curves.easeInOutCubic,
                      left: active * (cell + gap) + 16,
                      top: 2,
                      child: Icon(
                        Icons.arrow_drop_up,
                        size: 22,
                        color: context.palette.accent,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _linked(BuildContext context) {
    final links = frame.display.isEmpty ? lesson.tokens : frame.display;
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 280),
      child: Wrap(
        key: ValueKey(links.join('|')),
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        runSpacing: 8,
        children: [
          for (final (index, token) in links.indexed) ...[
            _tile(context, token, true),
            if (index < links.length - 1)
              Icon(
                Icons.arrow_forward,
                size: 18,
                color: context.palette.accent,
              ),
          ],
        ],
      ),
    );
  }

  Widget _stack(BuildContext context) => AnimatedSwitcher(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 280),
    child: Column(
      key: ValueKey(frame.display.join('|')),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final token in frame.display.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: _tile(context, token, true, width: 76),
          ),
        _caption(context, 'BOTTOM'),
      ],
    ),
  );

  Widget _grid(BuildContext context) {
    final cells = frame.display.isEmpty ? lesson.tokens : frame.display;
    return SizedBox(
      width: 3 * 48 + 2 * 6,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final (index, cell) in cells.indexed)
            _tile(context, cell, frame.active.contains(index), width: 48),
        ],
      ),
    );
  }

  Widget _intervals(BuildContext context) {
    final ranges = frame.display.isEmpty ? lesson.tokens : frame.display;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final range in ranges)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    range,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final ends = RegExp(r'\d+')
                          .allMatches(range)
                          .map((match) => int.parse(match.group(0)!))
                          .toList();
                      final start = ends.isNotEmpty ? ends.first : 0;
                      final end = ends.length > 1 ? ends[1] : start;
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: constraints.maxWidth * start / 12,
                          ),
                          child: AnimatedContainer(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 320),
                            height: 12,
                            width:
                                constraints.maxWidth * (end - start + 1) / 12,
                            decoration: BoxDecoration(
                              color: context.palette.accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Offset> _positions(int count) {
    if (lesson.visual == PatternVisual.trie) {
      return const [
        Offset(.5, .10),
        Offset(.5, .31),
        Offset(.5, .54),
        Offset(.27, .82),
        Offset(.73, .82),
      ].take(count).toList();
    }
    if (count == 1) {
      return const [Offset(.5, .3)];
    }
    if (count == 2) {
      return const [Offset(.5, .16), Offset(.5, .7)];
    }
    if (count == 3) {
      return const [Offset(.5, .12), Offset(.25, .72), Offset(.75, .72)];
    }
    if (count == 4) {
      return const [
        Offset(.5, .10),
        Offset(.24, .51),
        Offset(.76, .51),
        Offset(.5, .88),
      ];
    }
    return const [
      Offset(.5, .10),
      Offset(.24, .48),
      Offset(.76, .48),
      Offset(.16, .86),
      Offset(.84, .86),
    ];
  }

  List<(int, int)> _edges(int count) {
    if (count < 2) {
      return const [];
    }
    if (lesson.visual == PatternVisual.trie) {
      return const [(0, 1), (1, 2), (2, 3), (2, 4)];
    }
    if (lesson.category == 'Trees') {
      return const [(0, 1), (0, 2), (2, 3), (2, 4)];
    }
    if (lesson.category == 'Graphs') {
      return const [(0, 1), (0, 2), (1, 3), (2, 4)];
    }
    if (lesson.category == 'Advanced graphs') {
      return const [(0, 1), (0, 2), (1, 3), (2, 3)];
    }
    if (lesson.visual == PatternVisual.branches && count == 4) {
      return const [(0, 1), (1, 2), (0, 3)];
    }
    if (count == 2) {
      return const [(0, 1)];
    }
    if (count == 3) {
      return const [(0, 1), (0, 2)];
    }
    return const [(0, 1), (0, 2), (1, 3), (2, 4)];
  }

  Widget _nodeGraph(BuildContext context) {
    final dynamicStructure =
        lesson.visual == PatternVisual.heap ||
        lesson.visual == PatternVisual.trie ||
        lesson.visual == PatternVisual.branches;
    final labels = dynamicStructure && frame.display.isNotEmpty
        ? frame.display
        : lesson.tokens;
    final positions = _positions(labels.length);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(220.0, 340.0);
        const height = 180.0;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 350),
                  child: CustomPaint(
                    key: ValueKey(labels.join('|')),
                    size: Size(width, height),
                    painter: _PatternEdges(
                      positions,
                      _edges(labels.length),
                      context.palette.line,
                    ),
                  ),
                ),
              ),
              for (final (index, label) in labels.indexed)
                AnimatedPositioned(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  left: positions[index].dx * width - 25,
                  top: positions[index].dy * height - 22,
                  child: _tile(
                    context,
                    label,
                    frame.active.contains(index),
                    width: 50,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PatternEdges extends CustomPainter {
  const _PatternEdges(this.positions, this.edges, this.color);
  final List<Offset> positions;
  final List<(int, int)> edges;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final (from, to) in edges) {
      if (from >= positions.length || to >= positions.length) continue;
      final start = Offset(
        positions[from].dx * size.width,
        positions[from].dy * size.height,
      );
      final end = Offset(
        positions[to].dx * size.width,
        positions[to].dy * size.height,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternEdges oldDelegate) =>
      oldDelegate.positions != positions ||
      oldDelegate.edges != edges ||
      oldDelegate.color != color;
}
