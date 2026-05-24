import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.authBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.authAppBarBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.midnightNavy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.pastelPurple,
          brightness: Brightness.dark,
          surface: AppColors.midnightNavy,
          onSurface: AppColors.offWhite,
          primary: AppColors.pastelPurple,
          secondary: AppColors.sunsetOrange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.offWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.offWhite),
          bodyMedium: TextStyle(color: AppColors.lavenderGrey),
        ),
      );
}
