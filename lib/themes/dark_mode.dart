import 'package:flutter/material.dart';


ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: const Color(0xFF121212), // Soft black background
    primary: const Color(0xFF0095F6), // Instagram's bright blue accent
    secondary: const Color(0xFF1F1F1F), // Darker grey for cards and containers
    tertiary: const Color(0xFF9E9E9E), // Medium grey for borders and disabled text
    inversePrimary: Colors.white, // White for text and icons
  ),
);
