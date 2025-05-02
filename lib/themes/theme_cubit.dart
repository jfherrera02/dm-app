import 'package:dmessages/themes/dark_mode.dart';
import 'package:dmessages/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  bool isDarkMode = false;

  ThemeCubit() : super(lightMode);

  bool get isDark => isDarkMode;

  void toggleTheme() {
    isDarkMode = !isDarkMode;

    if (isDarkMode) {
      emit(darkMode);
    } else {
      emit(lightMode);
    }
  }
}