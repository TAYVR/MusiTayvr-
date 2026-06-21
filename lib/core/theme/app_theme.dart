import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:musitayvr/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Noto Sans',
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cardLight,
        error: AppColors.highlight,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.cardLight,
        titleTextStyle: TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        color: AppColors.cardLight,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.highlight,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Noto Sans',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkSurface,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cardLight,
        secondary: AppColors.accent,
        surface: AppColors.darkCard,
        error: AppColors.highlight,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkCard,
        titleTextStyle: TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        color: AppColors.darkCard,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.highlight,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyLarge: TextStyle(
          fontSize: 14.sp,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
        ),
      ),
    );
  }
}
