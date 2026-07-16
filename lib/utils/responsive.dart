import 'package:flutter/material.dart';

/// Responsive sizing utility for the Tajory app.
///
/// Provides proportional sizing based on the device screen dimensions.
/// Reference design: ~390x844 (iPhone 14 / typical phone).
class Responsive {
  Responsive._();

  // ── Breakpoints ──

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // ── Reference dimensions (design base) ──

  static const double _refWidth = 390;
  static const double _refHeight = 844;

  // ── Core helpers ──

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Scale a value relative to screen width.
  static double scaleWidth(BuildContext context, double value) =>
      value * screenWidth(context) / _refWidth;

  /// Scale a value relative to screen height.
  static double scaleHeight(BuildContext context, double value) =>
      value * screenHeight(context) / _refHeight;

  /// Use the smaller of width/height scaling to keep proportions safe.
  static double scale(BuildContext context, double value) {
    final wScale = screenWidth(context) / _refWidth;
    final hScale = screenHeight(context) / _refHeight;
    final factor = wScale < hScale ? wScale : hScale;
    return value * factor;
  }

  /// Get a proportional value clamped between [min] and [max].
  static double scaledClamp(
    BuildContext context,
    double value, {
    double? min,
    double? max,
  }) {
    final scaled = scale(context, value);
    if (min != null && scaled < min) return min;
    if (max != null && scaled > max) return max;
    return scaled;
  }

  /// Percentage of screen width (e.g. 0.5 = 50%).
  static double fractionWidth(BuildContext context, double fraction) =>
      screenWidth(context) * fraction;

  /// Percentage of screen height (e.g. 0.5 = 50%).
  static double fractionHeight(BuildContext context, double fraction) =>
      screenHeight(context) * fraction;

  // ── Common responsive values ──

  /// Horizontal padding that adapts to screen width.
  static double horizontalPadding(BuildContext context) =>
      scaleWidth(context, 20);

  /// Standard spacing between sections.
  static double sectionSpacing(BuildContext context) =>
      scaleHeight(context, 24);

  /// Standard small spacing.
  static double smallSpacing(BuildContext context) =>
      scaleHeight(context, 8);

  /// Icon size proportional to screen.
  static double iconSize(BuildContext context, double base) =>
      scale(context, base);

  /// Font size that won't shrink too much on small screens.
  static double fontSize(BuildContext context, double base) {
    final scaled = scale(context, base);
    return scaled < base * 0.85 ? base * 0.85 : scaled;
  }

  /// Border radius proportional to screen.
  static double borderRadius(BuildContext context, double base) =>
      scale(context, base);
}
