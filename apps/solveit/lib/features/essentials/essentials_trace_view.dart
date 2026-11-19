import 'package:flutter/material.dart';

import '../../ui/looploom_theme.dart';

class EssentialsTraceView extends StatelessWidget {
  const EssentialsTraceView({
    super.key,
    required this.input,
    required this.active,
    required this.output,
    required this.stepIndex,
    required this.stepCount,
  });
  final List<String> input;
  final List<int> active;
  final List<String> output;
  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 360);
    final progress = stepCount == 1 ? 1.0 : stepIndex / (stepCount - 1);
    return Container(
      key: const Key('essentials-trace'),
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: context.palette.recess,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SOURCE ROWS / EVENTS',
            style: noteLabel.copyWith(color: context.palette.muted),
          ),
          const SizedBox(height: 10),
          for (final (index, row) in input.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: AnimatedContainer(
                key: Key('essentials-input-$index'),
                duration: duration,
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active.contains(index)
                      ? context.palette.accentWash
                      : context.palette.sheet,
                  border: Border.all(
                    color: active.contains(index)
                        ? context.palette.accent
                        : context.palette.line,
                    width: active.contains(index) ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  row,
                  style: const TextStyle(fontSize: 15, height: 1.35),
                ),
              ),
            ),
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              height: 30,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 14,
                    child: Container(height: 2, color: context.palette.line),
                  ),
                  AnimatedPositioned(
                    duration: duration,
                    curve: Curves.easeInOutCubic,
                    left: progress * (constraints.maxWidth - 30),
                    top: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: context.palette.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 17,
                        color: context.palette.onAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'RESULT / EFFECT',
            style: noteLabel.copyWith(color: context.palette.muted),
          ),
          const SizedBox(height: 9),
          AnimatedSize(
            duration: duration,
            child: AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, .08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey('essentials-result-$stepIndex'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final row in output)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: context.palette.sheet,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        row,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
