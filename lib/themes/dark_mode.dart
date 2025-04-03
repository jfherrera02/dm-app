import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(218, 0, 0, 0), // Deep maroon/burgundy-like background
    primary: Colors.amber.shade400, // Golden-yellow accent for highlights
    secondary: const Color.fromARGB(64, 128, 0, 32), // Dark brown for subtle contrast
    tertiary: Colors.grey.shade300, // Light grey for input fields & borders
    inversePrimary: Colors.white, // White for high contrast text/icons
  ),
);
