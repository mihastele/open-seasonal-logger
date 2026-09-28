import 'package:flutter/material.dart';
import 'package:seasonal/brand/palette.dart';

/// The Seasonal theme. Warm, paper-like, calm. No red failure states and no
/// green "success" colour — a season is not a task (see brand/BRAND.md).
ThemeData buildSeasonalTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: SeasonalColors.ember,
    primary: SeasonalColors.ember,
    secondary: SeasonalColors.amber,
    surface: SeasonalColors.white,
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: SeasonalColors.paper,
    cardTheme: CardThemeData(
      elevation: 0,
      color: SeasonalColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: SeasonalColors.ink,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: SeasonalColors.ink,
      ),
      bodyMedium: TextStyle(color: SeasonalColors.clay, height: 1.5),
    ),
  );
}
