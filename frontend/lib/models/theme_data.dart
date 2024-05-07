import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:releaf/models/app_colors.dart';

abstract class AppTheme {
  static ThemeData dark = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkTertiary,
      background: AppColors.darkBackgroundColor,
      primaryContainer: AppColors.darkPrimaryAccent,
      surface: AppColors.darkAccentBackgroundColor,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackgroundColor,
      elevation: 6,
      selectedItemColor: AppColors.darkPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackgroundColor,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardColor: AppColors.darkAccentBackgroundColor,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      linearTrackColor: AppColors.darkAccentBackgroundColor,
      linearMinHeight: 20,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.darkBackgroundColor;
            }
            return AppColors.darkAccentBackgroundColor;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.darkPrimaryAccent;
            }
            return AppColors.darkPrimary;
          },
        ),
        overlayColor: MaterialStatePropertyAll(
          AppColors.darkPrimaryAccent.withOpacity(.3),
        ),
      ),
    ),
    splashColor: AppColors.darkPrimaryAccent.withOpacity(.3),
  );

  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      // ignore: avoid_redundant_argument_values
      background: AppColors.backgroundColor,
      primaryContainer: AppColors.primaryContainer,
      surface: AppColors.accentBackgroundColor,
      surfaceTint: Colors.transparent,
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.backgroundColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundColor,
      elevation: 6,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundColor,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      linearTrackColor: AppColors.accentBackgroundColor,
      linearMinHeight: 20,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.accentBackgroundColor;
            }
            return AppColors.primary;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.secondary;
            }
            return AppColors.backgroundColor;
          },
        ),
        overlayColor: MaterialStatePropertyAll(
          AppColors.primary.withOpacity(.3),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      labelPadding: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      side: BorderSide.none,
    ),
    splashColor: AppColors.primary.withOpacity(.3),
    cardColor: AppColors.backgroundColor,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: AppColors.accentBackgroundColor,
      elevation: 12,
      color: AppColors.backgroundColor,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
