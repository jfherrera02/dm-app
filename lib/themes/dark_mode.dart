import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF800020), // Deep Burgundy
    secondary: Color(0xFFFFD700), // Gold
    surface: Color(0xFF4A001F), // Darker Burgundy for background
    onPrimary: Colors.white, // White text on primary color
    onSecondary: Colors.black, // Black text on secondary color
    onSurface: Colors.white, // White text on surface
  ),
);