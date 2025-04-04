import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white, // Beige (hex code for beige)
    primary: Colors.brown.shade600, // Deep warm brown for text/icons
    secondary: Colors.grey.shade100, // Soft gold as an accent
    tertiary: Colors.white, // For borders or highlights
    inversePrimary: Colors.black, // Burgundy (hex code for burgundy)
  ),
);