import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration
class AppTheme {
  // Color Palette
  /// Primary brand color
  static const Color primaryColor = Color(0xFF6366F1);

  /// Secondary brand color
  static const Color secondaryColor = Color(0xFF8B5CF6);

  /// Accent color for highlights
  static const Color accentColor = Color(0xFF06B6D4);

  /// Success state color
  static const Color successColor = Color(0xFF10B981);

  /// Warning state color
  static const Color warningColor = Color(0xFFF59E0B);

  /// Error state color
  static const Color errorColor = Color(0xFFEF4444);

  // Neutral Colors
  /// Background color for light theme
  static const Color backgroundColor = Color(0xFFFAFAFA);

  /// Surface color for cards and containers
  static const Color surfaceColor = Color(0xFFFFFFFF);

  /// Card background color
  static const Color cardColor = Color(0xFFFFFFFF);

  /// Divider and border color
  static const Color dividerColor = Color(0xFFE5E7EB);

  // Text Colors
  /// Primary text color
  static const Color textPrimaryColor = Color(0xFF111827);

  /// Secondary text color
  static const Color textSecondaryColor = Color(0xFF6B7280);

  /// Tertiary text color
  static const Color textTertiaryColor = Color(0xFF9CA3AF);

  // Dark Theme Colors
  /// Background color for dark theme
  static const Color darkBackgroundColor = Color(0xFF0F172A);

  /// Surface color for dark theme
  static const Color darkSurfaceColor = Color(0xFF1E293B);

  /// Card color for dark theme
  static const Color darkCardColor = Color(0xFF334155);

  /// Divider color for dark theme
  static const Color darkDividerColor = Color(0xFF475569);

  /// Primary text color for dark theme
  static const Color darkTextPrimaryColor = Color(0xFFF8FAFC);

  /// Secondary text color for dark theme
  static const Color darkTextSecondaryColor = Color(0xFFCBD5E1);

  /// Tertiary text color for dark theme
  static const Color darkTextTertiaryColor = Color(0xFF94A3B8);

  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    textTheme: _buildTextTheme(GoogleFonts.interTextTheme()),
    appBarTheme: _buildAppBarTheme(),
    cardTheme: _buildCardTheme(),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(),
    bottomNavigationBarTheme: _buildBottomNavigationBarTheme(),
    scaffoldBackgroundColor: backgroundColor,
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
  );

  /// Dark theme configuration
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: darkSurfaceColor,
      error: errorColor,
    ),
    textTheme: _buildTextTheme(
      GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    ),
    appBarTheme: _buildAppBarTheme(isDark: true),
    cardTheme: _buildCardTheme(isDark: true),
    elevatedButtonTheme: _buildElevatedButtonTheme(isDark: true),
    outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
    textButtonTheme: _buildTextButtonTheme(isDark: true),
    inputDecorationTheme: _buildInputDecorationTheme(isDark: true),
    bottomNavigationBarTheme: _buildBottomNavigationBarTheme(isDark: true),
    scaffoldBackgroundColor: darkBackgroundColor,
    dividerTheme: const DividerThemeData(
      color: darkDividerColor,
      thickness: 1,
      space: 1,
    ),
  );

  /// Builds custom text theme
  static TextTheme _buildTextTheme(TextTheme base) => base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontSize: 32.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: base.labelSmall?.copyWith(
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
    ),
  );

  /// Builds app bar theme
  static AppBarTheme _buildAppBarTheme({bool isDark = false}) => AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: isDark ? darkSurfaceColor : surfaceColor,
    foregroundColor: isDark ? darkTextPrimaryColor : textPrimaryColor,
    titleTextStyle: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: isDark ? darkTextPrimaryColor : textPrimaryColor,
    ),
    iconTheme: IconThemeData(
      color: isDark ? darkTextPrimaryColor : textPrimaryColor,
      size: 24.sp,
    ),
  );

  /// Builds card theme
  static CardTheme _buildCardTheme({bool isDark = false}) => CardTheme(
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    color: isDark ? darkCardColor : cardColor,
    margin: EdgeInsets.all(8.w),
  );

  /// Builds elevated button theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme({
    bool isDark = false,
  }) => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      shadowColor: primaryColor.withValues(alpha: 0.3),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    ),
  );

  /// Builds outlined button theme
  static OutlinedButtonThemeData _buildOutlinedButtonTheme({
    bool isDark = false,
  }) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: BorderSide(color: primaryColor, width: 1.5),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    ),
  );

  /// Builds text button theme
  static TextButtonThemeData _buildTextButtonTheme({bool isDark = false}) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
      );

  /// Builds input decoration theme
  static InputDecorationTheme _buildInputDecorationTheme({
    bool isDark = false,
  }) => InputDecorationTheme(
    filled: true,
    fillColor: isDark ? darkSurfaceColor : Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: isDark ? darkDividerColor : dividerColor,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(
        color: isDark ? darkDividerColor : dividerColor,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    hintStyle: TextStyle(
      color: isDark ? darkTextTertiaryColor : textTertiaryColor,
      fontSize: 14.sp,
    ),
  );

  /// Builds bottom navigation bar theme
  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme({
    bool isDark = false,
  }) => BottomNavigationBarThemeData(
    backgroundColor: isDark ? darkSurfaceColor : surfaceColor,
    selectedItemColor: primaryColor,
    unselectedItemColor: isDark ? darkTextTertiaryColor : textTertiaryColor,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    ),
  );
}
