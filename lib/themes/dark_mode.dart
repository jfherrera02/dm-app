import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.brown.shade900, // Deep maroon/burgundy-like background
    primary: Colors.amber.shade400, // Golden-yellow accent for highlights
    secondary: Colors.brown.shade800, // Dark brown for subtle contrast
    tertiary: Colors.grey.shade300, // Light grey for input fields & borders
    inversePrimary: Colors.white, // White for high contrast text/icons
  ),
);
