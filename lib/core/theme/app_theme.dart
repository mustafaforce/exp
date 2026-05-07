import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Colors.black,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.divider,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          toolbarHeight: 48,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        listTileTheme: const ListTileThemeData(
          dense: true,
          visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minLeadingWidth: 28,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          height: 60,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              );
            }
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                size: 20,
                color: AppColors.primary,
              );
            }
            return const IconThemeData(
              size: 20,
              color: AppColors.textSecondary,
            );
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: CircleBorder(),
          sizeConstraints: BoxConstraints.tightFor(width: 52, height: 52),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 0.5,
          space: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.darkPrimary,
          onPrimary: Colors.black,
          secondary: AppColors.darkSecondary,
          onSecondary: Colors.black,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          error: AppColors.darkError,
          onError: Colors.black,
          outline: AppColors.darkDivider,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextPrimary,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.darkTextPrimary,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.darkTextPrimary,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.darkTextSecondary,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextPrimary,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextSecondary,
          ),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          toolbarHeight: 48,
          backgroundColor: AppColors.darkBackground,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.darkDivider),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        listTileTheme: const ListTileThemeData(
          dense: true,
          visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          minLeadingWidth: 28,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          height: 60,
          backgroundColor: AppColors.darkSurface,
          indicatorColor: AppColors.darkPrimaryContainer,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.darkPrimary,
              );
            }
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.darkTextSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                size: 20,
                color: AppColors.darkPrimary,
              );
            }
            return const IconThemeData(
              size: 20,
              color: AppColors.darkTextSecondary,
            );
          }),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.darkSurfaceElevated,
          foregroundColor: AppColors.darkPrimary,
          elevation: 0,
          shape: const CircleBorder(),
          sizeConstraints: const BoxConstraints.tightFor(width: 52, height: 52),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 0.5,
          space: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
}
