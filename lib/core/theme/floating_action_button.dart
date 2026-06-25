import 'package:flutter/material.dart';
import 'colors.dart';

class CustomFloatingActionButtonTheme {
  CustomFloatingActionButtonTheme._();

  static FloatingActionButtonThemeData build(AppColors colors) {
    return FloatingActionButtonThemeData(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      foregroundColor: colors.accent,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: CircleBorder(
        side: BorderSide(color: colors.accent, width: 1.5),
      ),
    );
  }
}
