import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFAFAF5);
  static const primary = Color.fromARGB(255, 104, 174, 132);
  static const text = Color(0xFF2C2C2C);
  static const card = Colors.white;
}

const double appPadding = 16;
const double cardRadius = 10;

ThemeData appTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.text,
    secondary: AppColors.primary,
    onSecondary: AppColors.text,
    error: Colors.red,
    onError: Colors.white,
    surface: AppColors.background,
    onSurface: AppColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.text,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
    ),
    navigationDrawerTheme: const NavigationDrawerThemeData(
      indicatorColor: AppColors.primary,
    ),
    listTileTheme: const ListTileThemeData(
      selectedTileColor: AppColors.primary,
      iconColor: AppColors.text,
      textColor: AppColors.text,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.text),
      bodyMedium: TextStyle(color: AppColors.text),
      titleLarge: TextStyle(color: AppColors.text),
      titleMedium: TextStyle(color: AppColors.text),
    ),
  );
}
