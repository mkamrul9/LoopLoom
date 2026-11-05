import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class StudyPalette extends ThemeExtension<StudyPalette> {
  const StudyPalette({
    required this.paper,
    required this.sheet,
    required this.ink,
    required this.muted,
    required this.line,
    required this.recess,
    required this.accent,
    required this.accentWash,
    required this.onAccent,
  });

  static const light = StudyPalette(
    paper: Color(0xFFF7F4EF),
    sheet: Color(0xFFFFFDF9),
    ink: Color(0xFF262B2D),
    muted: Color(0xFF5F6466),
    line: Color(0xFFD9D3CC),
    recess: Color(0xFFECE7DF),
    accent: Color(0xFF914B36),
    accentWash: Color(0xFFF2E1D6),
    onAccent: Color(0xFFFFFFFF),
  );

  static const dark = StudyPalette(
    paper: Color(0xFF17191B),
    sheet: Color(0xFF202326),
    ink: Color(0xFFF2EEE8),
    muted: Color(0xFFB9B2AA),
    line: Color(0xFF49433E),
    recess: Color(0xFF292C2F),
    accent: Color(0xFFE3A58B),
    accentWash: Color(0xFF45312A),
    onAccent: Color(0xFF231814),
  );

  final Color paper;
  final Color sheet;
  final Color ink;
  final Color muted;
  final Color line;
  final Color recess;
  final Color accent;
  final Color accentWash;
  final Color onAccent;

  @override
  StudyPalette copyWith({
    Color? paper,
    Color? sheet,
    Color? ink,
    Color? muted,
    Color? line,
    Color? recess,
    Color? accent,
    Color? accentWash,
    Color? onAccent,
  }) => StudyPalette(
    paper: paper ?? this.paper,
    sheet: sheet ?? this.sheet,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    line: line ?? this.line,
    recess: recess ?? this.recess,
    accent: accent ?? this.accent,
    accentWash: accentWash ?? this.accentWash,
    onAccent: onAccent ?? this.onAccent,
  );

  @override
  StudyPalette lerp(ThemeExtension<StudyPalette>? other, double t) {
    if (other is! StudyPalette) return this;
    return StudyPalette(
      paper: Color.lerp(paper, other.paper, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      recess: Color.lerp(recess, other.recess, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentWash: Color.lerp(accentWash, other.accentWash, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

extension StudyPaletteContext on BuildContext {
  StudyPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<StudyPalette>() ??
        (theme.brightness == Brightness.dark
            ? StudyPalette.dark
            : StudyPalette.light);
  }
}

const noteLabel = TextStyle(
  fontFamily: 'monospace',
  fontSize: 13,
  letterSpacing: .55,
  fontWeight: FontWeight.w600,
);

ThemeData studyTheme([Brightness brightness = Brightness.light]) {
  final colors = brightness == Brightness.light
      ? StudyPalette.light
      : StudyPalette.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: colors.accent,
    brightness: brightness,
  ).copyWith(
    primary: colors.accent,
    onPrimary: colors.onAccent,
    primaryContainer: colors.accentWash,
    onPrimaryContainer: colors.ink,
    secondary: colors.accent,
    onSecondary: colors.onAccent,
    secondaryContainer: colors.recess,
    onSecondaryContainer: colors.ink,
    surface: colors.paper,
    onSurface: colors.ink,
    surfaceContainerLowest: colors.paper,
    surfaceContainerLow: colors.sheet,
    surfaceContainer: colors.sheet,
    surfaceContainerHigh: colors.recess,
    surfaceContainerHighest: colors.recess,
    onSurfaceVariant: colors.muted,
    outline: colors.muted,
    outlineVariant: colors.line,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  final baseTextTheme = ThemeData(brightness: brightness).textTheme;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    extensions: [colors],
    scaffoldBackgroundColor: colors.paper,
    canvasColor: colors.paper,
    textTheme: baseTextTheme
        .copyWith(
          bodyLarge: const TextStyle(fontSize: 18, height: 1.65),
          bodyMedium: const TextStyle(fontSize: 16, height: 1.6),
          bodySmall: const TextStyle(fontSize: 14, height: 1.5),
          labelLarge: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: const TextStyle(fontSize: 14),
          labelSmall: const TextStyle(fontSize: 12),
        )
        .apply(bodyColor: colors.ink, displayColor: colors.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.paper,
      foregroundColor: colors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: colors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: colors.ink, size: 22),
      ),
      backgroundColor: colors.paper,
      surfaceTintColor: Colors.transparent,
      indicatorColor: colors.accentWash,
      height: 80,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 13, color: colors.ink),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.paper,
      indicatorColor: colors.accentWash,
      selectedIconTheme: IconThemeData(color: colors.accent),
      unselectedIconTheme: IconThemeData(color: colors.muted),
      selectedLabelTextStyle: TextStyle(
        color: colors.accent,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: colors.muted,
        fontSize: 12,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: colors.onAccent,
        backgroundColor: colors.accent,
        shape: shape,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: colors.ink,
        shape: shape,
        side: BorderSide(color: colors.line),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: colors.accent,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.line,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.accent,
      linearTrackColor: colors.recess,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.sheet,
      labelStyle: TextStyle(color: colors.muted, fontSize: 16),
      hintStyle: TextStyle(color: colors.muted),
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.accent, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(backgroundColor: colors.sheet),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.sheet,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.recess,
      contentTextStyle: TextStyle(color: colors.ink, fontSize: 15),
      actionTextColor: colors.accent,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.accent,
      selectionColor: colors.accent.withValues(alpha: .25),
      selectionHandleColor: colors.accent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.sheet,
      selectedColor: colors.accentWash,
      disabledColor: colors.recess,
      side: BorderSide(color: colors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(color: colors.ink, fontSize: 14),
      secondaryLabelStyle: TextStyle(color: colors.ink, fontSize: 14),
    ),
    radioTheme: RadioThemeData(fillColor: WidgetStatePropertyAll(colors.accent)),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? colors.accent : null),
      checkColor: WidgetStatePropertyAll(colors.onAccent),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? colors.accent : colors.muted),
      trackColor: WidgetStatePropertyAll(colors.recess),
    ),
  );
}

class LoopLoomWordmark extends StatelessWidget {
  const LoopLoomWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.palette;
    final style = TextStyle(
      color: colors.ink,
      fontSize: 21,
      fontWeight: FontWeight.w700,
      letterSpacing: -.8,
    );
    return Semantics(
      label: 'LoopLoom',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('L', style: style),
            _LoopPair(accent: colors.accent),
            Text('pL', style: style),
            _LoopPair(accent: colors.accent),
            Text('m', style: style),
          ],
        ),
      ),
    );
  }
}

class _LoopPair extends StatelessWidget {
  const _LoopPair({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    height: 27,
    child: CustomPaint(painter: _LoopPairPainter(accent)),
  );
}

class _LoopPairPainter extends CustomPainter {
  const _LoopPairPainter(this.accent);
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;
    final loop = Path()
      ..moveTo(14, 15.5)
      ..cubicTo(10, 4.5, 1.5, 4.5, 1.5, 15.5)
      ..cubicTo(1.5, 26.5, 10, 26.5, 14, 15.5)
      ..cubicTo(18, 4.5, 26.5, 4.5, 26.5, 15.5)
      ..cubicTo(26.5, 26.5, 18, 26.5, 14, 15.5);
    canvas.drawPath(loop, paint);
  }

  @override
  bool shouldRepaint(covariant _LoopPairPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
