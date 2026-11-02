import 'package:flutter/material.dart';

/// A quiet workbook palette. Accent color identifies an action or focus state.
abstract final class StudyColors {
  static const paper = Color(0xFFF6F4F0);
  static const sheet = Color(0xFFFFFEFC);
  static const ink = Color(0xFF272630);
  static const muted = Color(0xFF66636D);
  static const line = Color(0xFFDCD8D2);
  static const recess = Color(0xFFEDEAE5);
  static const accent = Color(0xFF272630);
  static const accentWash = Color(0xFFE7E3DD);
  static const hint = Color(0xFF66636D);
}

const noteLabel = TextStyle(
  fontFamily: 'monospace',
  fontSize: 13,
  letterSpacing: .55,
  fontWeight: FontWeight.w600,
  color: StudyColors.muted,
);

ThemeData studyTheme() {
  const scheme = ColorScheme.light(
    primary: StudyColors.accent,
    onPrimary: Colors.white,
    primaryContainer: StudyColors.accentWash,
    onPrimaryContainer: StudyColors.ink,
    secondary: StudyColors.muted,
    onSecondary: Colors.white,
    secondaryContainer: StudyColors.recess,
    onSecondaryContainer: StudyColors.ink,
    surface: StudyColors.paper,
    onSurface: StudyColors.ink,
    onSurfaceVariant: StudyColors.muted,
    outline: StudyColors.muted,
    outlineVariant: StudyColors.line,
    surfaceContainerHighest: StudyColors.recess,
  );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: StudyColors.paper,
    textTheme: ThemeData.light().textTheme
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
        .apply(bodyColor: StudyColors.ink, displayColor: StudyColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: StudyColors.paper,
      foregroundColor: StudyColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: StudyColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: StudyColors.ink, size: 22),
      ),
      backgroundColor: StudyColors.paper,
      surfaceTintColor: Colors.transparent,
      indicatorColor: StudyColors.accentWash,
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 13, color: StudyColors.ink),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: StudyColors.paper,
      indicatorColor: StudyColors.accentWash,
      selectedIconTheme: IconThemeData(color: StudyColors.accent),
      unselectedIconTheme: IconThemeData(color: StudyColors.muted),
      selectedLabelTextStyle: TextStyle(
        color: StudyColors.accent,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: StudyColors.muted,
        fontSize: 12,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: shape,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: shape,
        side: const BorderSide(color: StudyColors.line),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: StudyColors.muted,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: StudyColors.line,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: StudyColors.accent,
      linearTrackColor: StudyColors.recess,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StudyColors.sheet,
      labelStyle: const TextStyle(color: StudyColors.muted, fontSize: 16),
      hintStyle: const TextStyle(color: StudyColors.muted),
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StudyColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: StudyColors.accent, width: 1.5),
      ),
    ),
  );
}

class StudyMark extends StatelessWidget {
  const StudyMark({super.key});
  @override
  Widget build(BuildContext context) => const Text.rich(
    TextSpan(
      children: [
        TextSpan(text: 's'),
        TextSpan(
          text: '/',
          style: TextStyle(color: StudyColors.accent),
        ),
      ],
    ),
    style: TextStyle(
      fontFamily: 'monospace',
      fontSize: 27,
      fontWeight: FontWeight.w700,
      letterSpacing: -5,
    ),
  );
}
