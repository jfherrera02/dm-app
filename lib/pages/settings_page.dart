import 'package:dmessages/themes/theme_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the theme cubit
    final themeCubit = context.watch<ThemeCubit>();

    // check if the theme is dark or light
    bool isDarkMode = themeCubit.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // dark mode switch
            const Text("Dark Mode"),

            // light mode switch
            Text("Light Mode"),

            // switch toggle ->
            CupertinoSwitch(
              value:
                  isDarkMode,
              onChanged: (value) =>
                  themeCubit.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
