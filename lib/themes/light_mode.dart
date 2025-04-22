import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white, // Beige (hex code for beige)
    primary: const Color.fromARGB(255, 134, 134, 134), // Deep warm brown for text/icons
    secondary: Colors.grey.shade100, // Soft gold as an accent
    tertiary: Colors.white, // For borders or highlights
    inversePrimary: Colors.black, // Burgundy (hex code for burgundy)
  ),
);
