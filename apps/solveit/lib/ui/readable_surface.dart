import 'package:flutter/material.dart';

class _PreferenceTextScaler extends TextScaler {
  const _PreferenceTextScaler(this.systemScaler, this.preferenceScale);

  final TextScaler systemScaler;
  final double preferenceScale;

  @override
  double scale(double fontSize) =>
      systemScaler.scale(fontSize) * preferenceScale;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _PreferenceTextScaler &&
      other.systemScaler == systemScaler &&
      other.preferenceScale == preferenceScale;

  @override
  int get hashCode => Object.hash(systemScaler, preferenceScale);
}

/// Combines the learner's readable-text preference with the device setting.
class ReadableSurface extends StatelessWidget {
  const ReadableSurface({super.key, required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: _PreferenceTextScaler(media.textScaler, scale),
      ),
      child: child,
    );
  }
}
