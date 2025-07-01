import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // GitHub-inspired color palette
  static const Color _gitHubBlack = Color(0xFF0D1117);
  static const Color _gitHubDarkGray = Color(0xFF161B22);
  static const Color _gitHubGray = Color(0xFF21262D);
  static const Color _gitHubLightGray = Color(0xFF30363D);
  static const Color _gitHubGreen = Color(0xFF238636);
  static const Color _gitHubBrightGreen = Color(0xFF2EA043);
  static const Color _gitHubLimeGreen = Color(0xFF3FB950);
  static const Color _gitHubWhite = Color(0xFFF0F6FC);
  static const Color _gitHubLightText = Color(0xFFE6EDF3);
  static const Color _gitHubMutedText = Color(0xFF7D8590);
  static const Color _gitHubBorder = Color(0xFF30363D);
  static const Color _gitHubRed = Color(0xFFDA3633);
  static const Color _gitHubYellow = Color(0xFFFBD400);
  static const Color _gitHubBlue = Color(0xFF1F6FEB);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme inspired by GitHub Dark
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: _gitHubGreen,
        onPrimary: _gitHubBlack,
        primaryContainer: _gitHubBrightGreen,
        onPrimaryContainer: _gitHubWhite,
        secondary: _gitHubLimeGreen,
        onSecondary: _gitHubBlack,
        secondaryContainer: _gitHubGray,
        onSecondaryContainer: _gitHubLightText,
        tertiary: _gitHubBlue,
        onTertiary: _gitHubWhite,
        tertiaryContainer: _gitHubDarkGray,
        onTertiaryContainer: _gitHubLightText,
        error: _gitHubRed,
        onError: _gitHubWhite,
        errorContainer: Color(0xFF5A1E1E),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: _gitHubDarkGray,
        onSurface: _gitHubLightText,
        surfaceVariant: _gitHubGray,
        onSurfaceVariant: _gitHubMutedText,
        outline: _gitHubBorder,
        outlineVariant: _gitHubLightGray,
        shadow: Colors.black87,
        scrim: Colors.black54,
        inverseSurface: _gitHubWhite,
        onInverseSurface: _gitHubBlack,
        inversePrimary: _gitHubGreen,
        surfaceTint: _gitHubGreen,
      ),

      // Background colors
      scaffoldBackgroundColor: _gitHubBlack,
      canvasColor: _gitHubDarkGray,
      cardColor: _gitHubGray,
      dividerColor: _gitHubBorder,

      // Typography with GitHub-style fonts
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: _gitHubWhite,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: _gitHubWhite,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: _gitHubWhite,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: _gitHubWhite,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: _gitHubWhite,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _gitHubWhite,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _gitHubWhite,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: _gitHubLightText,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: _gitHubLightText,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: _gitHubLightText,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: _gitHubLightText,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: _gitHubMutedText,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: _gitHubWhite,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: _gitHubLightText,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: _gitHubMutedText,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _gitHubBlack,
        foregroundColor: _gitHubWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: _gitHubGreen,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _gitHubWhite,
        ),
        iconTheme: const IconThemeData(
          color: _gitHubWhite,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: _gitHubWhite,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: _gitHubGray,
        shadowColor: Colors.black54,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: _gitHubBorder,
            width: 1,
          ),
        ),
      ),

      // Elevated Button Theme (Primary GitHub Green)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _gitHubGreen,
          foregroundColor: _gitHubWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered)) {
              return _gitHubBrightGreen;
            }
            if (states.contains(MaterialState.pressed)) {
              return _gitHubLimeGreen;
            }
            if (states.contains(MaterialState.disabled)) {
              return _gitHubLightGray;
            }
            return _gitHubGreen;
          }),
        ),
      ),

      // Outlined Button Theme (GitHub Style)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _gitHubWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(
            color: _gitHubBorder,
            width: 1,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(MaterialState.hovered)) {
              return const BorderSide(color: _gitHubGreen, width: 1);
            }
            return const BorderSide(color: _gitHubBorder, width: 1);
          }),
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered)) {
              return _gitHubGray;
            }
            return Colors.transparent;
          }),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _gitHubGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered)) {
              return _gitHubBrightGreen;
            }
            return _gitHubGreen;
          }),
        ),
      ),

      // Input Decoration Theme (GitHub style)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _gitHubDarkGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _gitHubBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _gitHubBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _gitHubGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _gitHubRed,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _gitHubRed,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          color: _gitHubMutedText,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: _gitHubMutedText,
          fontSize: 14,
        ),
        helperStyle: GoogleFonts.inter(
          color: _gitHubMutedText,
          fontSize: 12,
        ),
        errorStyle: GoogleFonts.inter(
          color: _gitHubRed,
          fontSize: 12,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _gitHubGreen,
        foregroundColor: _gitHubWhite,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: _gitHubGreen,
        unselectedLabelColor: _gitHubMutedText,
        indicatorColor: _gitHubGreen,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _gitHubDarkGray,
        selectedItemColor: _gitHubGreen,
        unselectedItemColor: _gitHubMutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return _gitHubWhite;
          }
          return _gitHubMutedText;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return _gitHubGreen;
          }
          return _gitHubLightGray;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return _gitHubGreen;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(_gitHubWhite),
        side: const BorderSide(
          color: _gitHubBorder,
          width: 2,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _gitHubGreen,
        linearTrackColor: _gitHubLightGray,
        circularTrackColor: _gitHubLightGray,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _gitHubGray,
        contentTextStyle: GoogleFonts.inter(
          color: _gitHubWhite,
          fontSize: 14,
        ),
        actionTextColor: _gitHubGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: _gitHubGray,
        surfaceTintColor: _gitHubGreen,
        titleTextStyle: GoogleFonts.inter(
          color: _gitHubWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: _gitHubLightText,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: _gitHubBorder,
            width: 1,
          ),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: _gitHubLightText,
        iconColor: _gitHubMutedText,
        titleTextStyle: GoogleFonts.inter(
          color: _gitHubWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          color: _gitHubMutedText,
          fontSize: 14,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _gitHubGray,
        selectedColor: _gitHubGreen,
        secondarySelectedColor: _gitHubBrightGreen,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.inter(
          color: _gitHubLightText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          color: _gitHubWhite,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.dark,
        side: const BorderSide(
          color: _gitHubBorder,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _gitHubLightText,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: _gitHubGreen,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _gitHubBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Custom GitHub-style gradients
  static const LinearGradient gitHubGreenGradient = LinearGradient(
    colors: [_gitHubGreen, _gitHubBrightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gitHubDarkGradient = LinearGradient(
    colors: [_gitHubBlack, _gitHubDarkGray],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gitHubAccentGradient = LinearGradient(
    colors: [_gitHubGreen, _gitHubLimeGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // GitHub-style box shadows
  static const List<BoxShadow> gitHubShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> gitHubGlowShadow = [
    BoxShadow(
      color: _gitHubGreen,
      blurRadius: 20,
      spreadRadius: 2,
      offset: Offset(0, 0),
    ),
  ];

  // Custom colors for specific use cases
  static const Color success = _gitHubLimeGreen;
  static const Color warning = _gitHubYellow;
  static const Color error = _gitHubRed;
  static const Color info = _gitHubBlue;
  static const Color codeBackground = Color(0xFF161B22);
  static const Color terminalGreen = Color(0xFF39D353);
}
