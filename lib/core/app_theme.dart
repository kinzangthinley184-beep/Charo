import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.saffron,
        secondary: AppColors.gold,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48, fontWeight: FontWeight.w700,
          color: AppColors.cream, letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: AppColors.darkTextPrimary),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: AppColors.darkTextSecondary),
        labelLarge: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: Colors.white, letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      dividerColor: AppColors.darkDivider,
      cardColor: AppColors.darkCard,
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkTextPrimary,
        unselectedItemColor: AppColors.navUnselected,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.saffron,
        thumbColor: AppColors.saffron,
        inactiveTrackColor: AppColors.darkBorder,
      ),
    );
  }
}
