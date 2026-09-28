import 'package:flutter/material.dart';

/// A calm, warm, paper-like palette. No alarm colors, no red failure states.
const _seed = Color(0xFFB4633A);

ThemeData buildSeasonalTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFBF7F2),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
