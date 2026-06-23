import 'package:flutter/material.dart';

abstract final class AppColors {
  static const cream = Color(0xFFFFF8EA);
  static const orange = Color(0xFFFF9F43);
  static const green = Color(0xFF58C78C);
  static const blue = Color(0xFF55B8D9);
  static const coral = Color(0xFFFF786C);
  static const ink = Color(0xFF3E3A35);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      primary: AppColors.orange,
      secondary: AppColors.green,
      surface: AppColors.cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 18, height: 1.4),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.orange.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.ink
                : AppColors.ink.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          );
        }),
      ),
    );
  }
}
