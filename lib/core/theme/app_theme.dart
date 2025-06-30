import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Color Scheme
      colorScheme: _buildColorScheme(brightness),

      // Typography
      textTheme: _buildTextTheme(isDark),

      // App Bar
      appBarTheme: _buildAppBarTheme(isDark),

      // Scaffold
      scaffoldBackgroundColor: isDark ? AppColors.darkBase : Colors.white,

      // Cards
      cardTheme: _buildCardTheme(isDark),

      // Buttons
      elevatedButtonTheme: _buildElevatedButtonTheme(isDark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark),
      textButtonTheme: _buildTextButtonTheme(isDark),

      // Input Fields
      inputDecorationTheme: _buildInputDecorationTheme(isDark),

      // Bottom Navigation
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(isDark),

      // Tab Bar
      tabBarTheme: _buildTabBarTheme(isDark),

      // Dialog
      dialogTheme: _buildDialogTheme(isDark),

      // Bottom Sheet
      bottomSheetTheme: _buildBottomSheetTheme(isDark),

      // Snack Bar
      snackBarTheme: _buildSnackBarTheme(isDark),

      // Chip
      chipTheme: _buildChipTheme(isDark),

      // Switch
      switchTheme: _buildSwitchTheme(isDark),

      // Slider
      sliderTheme: _buildSliderTheme(isDark),

      // Progress Indicator
      progressIndicatorTheme: _buildProgressIndicatorTheme(isDark),

      // List Tile
      listTileTheme: _buildListTileTheme(isDark),

      // Divider
      dividerTheme: _buildDividerTheme(isDark),
    );
  }

  static ColorScheme _buildColorScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    if (isDark) {
      return const ColorScheme.dark(
        primary: AppColors.primaryNeon,
        secondary: AppColors.secondaryNeon,
        tertiary: AppColors.accentNeon,
        surface: AppColors.surfaceGlass,
        onSurface: AppColors.textPrimary,
        error: AppColors.errorNeon,
        onError: Colors.white,
        outline: AppColors.textTertiary,
        outlineVariant: AppColors.textSecondary,
      );
    } else {
      return ColorScheme.light(
        primary: AppColors.primaryNeon,
        secondary: AppColors.secondaryNeon,
        tertiary: AppColors.accentNeon,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: AppColors.errorNeon,
        onError: Colors.white,
        outline: Colors.grey[400]!,
        outlineVariant: Colors.grey[300]!,
      );
    }
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor = isDark ? AppColors.textPrimary : Colors.black87;
    final secondaryColor = isDark ? AppColors.textSecondary : Colors.black54;

    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.orbitron(
        fontSize: 57.sp,
        fontWeight: FontWeight.w900,
        color: baseColor,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.orbitron(
        fontSize: 45.sp,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.orbitron(
        fontSize: 36.sp,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.rajdhani(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.rajdhani(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.rajdhani(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles
      titleLarge: GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles
      bodyLarge: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles
      labelLarge: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(bool isDark) {
    return AppBarTheme(
      backgroundColor: isDark
          ? AppColors.surfaceGlass.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimary : Colors.black87,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.textPrimary : Colors.black87,
        size: 24.w,
      ),
    );
  }

  static CardTheme _buildCardTheme(bool isDark) {
    return CardTheme(
      color:
          isDark ? AppColors.surfaceGlass.withValues(alpha: 0.1) : Colors.white,
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? Colors.transparent : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.md.r),
        side: isDark
            ? BorderSide(
                color: AppColors.primaryNeon.withValues(alpha: 0.1),
                width: 1,
              )
            : BorderSide.none,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.lg.w,
          vertical: AppSizes.md.h,
        ),
        minimumSize: Size(120.w, AppSizes.buttonHeight.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.md.r),
          side: const BorderSide(color: AppColors.primaryNeon, width: 2),
        ),
        textStyle: GoogleFonts.rajdhani(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(bool isDark) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondaryNeon,
        side: const BorderSide(color: AppColors.secondaryNeon, width: 2),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.lg.w,
          vertical: AppSizes.md.h,
        ),
        minimumSize: Size(120.w, AppSizes.buttonHeight.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.md.r),
        ),
        textStyle: GoogleFonts.rajdhani(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(bool isDark) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryNeon,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md.w,
          vertical: AppSizes.sm.h,
        ),
        minimumSize: Size(80.w, 40.h),
        textStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? AppColors.surfaceGlass.withValues(alpha: 0.1)
          : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.md.r),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.primaryNeon.withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.md.r),
        borderSide: BorderSide(
          color: isDark
              ? AppColors.primaryNeon.withValues(alpha: 0.3)
              : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.md.r),
        borderSide: const BorderSide(color: AppColors.primaryNeon, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.md.r),
        borderSide: const BorderSide(color: AppColors.errorNeon, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: isDark ? AppColors.textSecondary : Colors.grey[600],
        fontSize: 14.sp,
      ),
      hintStyle: GoogleFonts.inter(
        color: isDark
            ? AppColors.textSecondary.withValues(alpha: 0.7)
            : Colors.grey[500],
        fontSize: 14.sp,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.md.w,
        vertical: AppSizes.md.h,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
    bool isDark,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor:
          isDark ? AppColors.surfaceGlass.withValues(alpha: 0.1) : Colors.white,
      selectedItemColor: AppColors.primaryNeon,
      unselectedItemColor: isDark ? AppColors.textSecondary : Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static TabBarTheme _buildTabBarTheme(bool isDark) {
    return TabBarTheme(
      labelColor: AppColors.primaryNeon,
      unselectedLabelColor: isDark ? AppColors.textSecondary : Colors.grey[600],
      indicator: BoxDecoration(
        color: AppColors.primaryNeon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.md.r),
        border: Border.all(color: AppColors.primaryNeon, width: 1),
      ),
      labelStyle: GoogleFonts.rajdhani(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.rajdhani(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }

  static DialogTheme _buildDialogTheme(bool isDark) {
    return DialogTheme(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: isDark ? 0 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg.r),
        side: isDark
            ? BorderSide(
                color: AppColors.primaryNeon.withValues(alpha: 0.2),
                width: 1,
              )
            : BorderSide.none,
      ),
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimary : Colors.black87,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14.sp,
        color: isDark ? AppColors.textSecondary : Colors.black54,
      ),
    );
  }

  static BottomSheetThemeData _buildBottomSheetTheme(bool isDark) {
    return BottomSheetThemeData(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: isDark ? 0 : 8,
      modalElevation: isDark ? 0 : 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.lg.r),
        ),
        side: isDark
            ? BorderSide(
                color: AppColors.primaryNeon.withValues(alpha: 0.2),
                width: 1,
              )
            : BorderSide.none,
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(bool isDark) {
    return SnackBarThemeData(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey[800],
      contentTextStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.sm.r),
      ),
    );
  }

  static ChipThemeData _buildChipTheme(bool isDark) {
    return ChipThemeData(
      backgroundColor: isDark
          ? AppColors.surfaceGlass.withValues(alpha: 0.1)
          : Colors.grey[200],
      selectedColor: AppColors.primaryNeon.withValues(alpha: 0.2),
      side: BorderSide(
        color: isDark
            ? AppColors.primaryNeon.withValues(alpha: 0.3)
            : Colors.grey[300]!,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textPrimary : Colors.black87,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.lg.r),
      ),
    );
  }

  static SwitchThemeData _buildSwitchTheme(bool isDark) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryNeon;
        }
        return isDark ? AppColors.textSecondary : Colors.grey[400];
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryNeon.withValues(alpha: 0.3);
        }
        return isDark
            ? AppColors.textTertiary.withValues(alpha: 0.3)
            : Colors.grey[300];
      }),
    );
  }

  static SliderThemeData _buildSliderTheme(bool isDark) {
    return SliderThemeData(
      activeTrackColor: AppColors.primaryNeon,
      inactiveTrackColor: isDark
          ? AppColors.textTertiary.withValues(alpha: 0.3)
          : Colors.grey[300],
      thumbColor: AppColors.primaryNeon,
      overlayColor: AppColors.primaryNeon.withValues(alpha: 0.2),
    );
  }

  static ProgressIndicatorThemeData _buildProgressIndicatorTheme(bool isDark) {
    return const ProgressIndicatorThemeData(
      color: AppColors.primaryNeon,
      linearTrackColor: Colors.transparent,
      circularTrackColor: Colors.transparent,
    );
  }

  static ListTileThemeData _buildListTileTheme(bool isDark) {
    return ListTileThemeData(
      iconColor: isDark ? AppColors.textSecondary : Colors.grey[600],
      textColor: isDark ? AppColors.textPrimary : Colors.black87,
      tileColor: isDark
          ? AppColors.surfaceGlass.withValues(alpha: 0.05)
          : Colors.transparent,
      selectedTileColor: AppColors.primaryNeon.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.sm.r),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.md.w,
        vertical: AppSizes.sm.h,
      ),
    );
  }

  static DividerThemeData _buildDividerTheme(bool isDark) {
    return DividerThemeData(
      color: isDark
          ? AppColors.primaryNeon.withValues(alpha: 0.1)
          : Colors.grey[300],
      thickness: 1,
      space: 1,
    );
  }
}
