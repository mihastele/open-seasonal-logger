import 'package:flutter/material.dart';

/// The Seasonal palette. Keep this in sync with `brand/BRAND.md`.
abstract final class SeasonalColors {
  static const paper = Color(0xFFFBF7F2);
  static const linen = Color(0xFFF3E9DE);
  static const white = Color(0xFFFFFFFF);

  static const ember = Color(0xFFB4633A);
  static const amber = Color(0xFFD99A4E);

  static const bark = Color(0xFF5B4A3E);
  static const ink = Color(0xFF3E332B);
  static const clay = Color(0xFF6B5D50);
  static const stone = Color(0xFF8A7A6B);
  static const moss = Color(0xFF6E7B56);

  /// Leaf gradient stops: Ember -> Amber.
  static const leafGradient = [Color(0xFFA9532F), Color(0xFFC97B44), Color(0xFFE0A659)];
}
