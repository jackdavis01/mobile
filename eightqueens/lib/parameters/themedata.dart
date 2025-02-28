import 'package:flutter/material.dart';

MaterialColor _seedThemeColor = Colors.blue;

final ThemeData blueTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
      seedColor: _seedThemeColor,
      surface: _seedThemeColor.shade50,
      surfaceTint: _seedThemeColor.shade50),
  brightness: Brightness.light,
);
