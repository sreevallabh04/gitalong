import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// GitHub-acquisition-worthy theme that makes developers weep with joy
class GitAlongTheme {
  // 🎨 Precise GitHub Color Palette - Not approximations, but perfection
  static const Color carbonBlack = Color(0xFF0D1117); // Deep space black
  static const Color neonGreen = Color(0xFF2EA043); // The holy green
  static const Color accentGreen = Color(0xFF238636); // Secondary green
  static const Color mutedGreen = Color(0xFF1F6E32); // Darker green
  static const Color ghostWhite = Color(0xFFF0F6FC); // Pure text white
  static const Color codeSilver = Color(0xFFE6EDF3); // Light text
  static const Color devGray = Color(0xFF8B949E); // Muted text
  static const Color terminalGray = Color(0xFF6E7681); // Disabled text
  static const Color borderGray = Color(0xFF30363D); // Subtle borders
  static const Color surfaceGray = Color(0xFF161B22); // Card surfaces
  static const Color errorRed = Color(0xFFDA3633); // Error states
  static const Color warningOrange = Color(0xFFBC4C00); // Warning states
  static const Color infoBlue = Color(0xFF1F6FEB); // Info states

  // 🔥 Glow Effects - The secret sauce
  static const BoxShadow primaryGlow = BoxShadow(
    color: Color(0x332EA043),
    blurRadius: 20,
    spreadRadius: 2,
    offset: Offset(0, 4),
  );

  static const BoxShadow subtleGlow = BoxShadow(
    color: Color(0x1A2EA043),
    blurRadius: 12,
    spreadRadius: 1,
    offset: Offset(0, 2),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    spreadRadius: 0,
    offset: Offset(0, 8),
  );

  // 💎 Text Styles - Terminal-inspired perfection
  static TextStyle get headlineStyle => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: ghostWhite,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get titleStyle => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ghostWhite,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get subtitleStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: codeSilver,
        height: 1.4,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: codeSilver,
        height: 1.5,
      );

  static TextStyle get codeStyle => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: neonGreen,
        height: 1.4,
        letterSpacing: 0.2,
      );

  static TextStyle get mutedStyle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: devGray,
        height: 1.4,
      );

  static TextStyle get terminalStyle => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: terminalGray,
        height: 1.3,
        letterSpacing: 0.1,
      );

  // ⚡ Button Styles - Glow-enhanced interactions
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: neonGreen,
        foregroundColor: carbonBlack,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: neonGreen,
        backgroundColor: Colors.transparent,
        elevation: 0,
        side: const BorderSide(color: neonGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(neonGreen.withOpacity(0.1)),
      );

  static ButtonStyle get ghostButtonStyle => TextButton.styleFrom(
        foregroundColor: devGray,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(devGray.withOpacity(0.1)),
      );

  // 🎯 Input Styles - Developer-focused forms
  static InputDecorationTheme get inputTheme => InputDecorationTheme(
        filled: true,
        fillColor: surfaceGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: devGray,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: terminalGray,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: GoogleFonts.inter(
          fontSize: 12,
          color: errorRed,
          fontWeight: FontWeight.w500,
        ),
      );

  // 🎨 The Complete Theme - GitHub's envy
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Core Colors
        scaffoldBackgroundColor: carbonBlack,
        canvasColor: carbonBlack,
        cardColor: surfaceGray,
        dividerColor: borderGray,
        focusColor: neonGreen,
        hoverColor: neonGreen.withOpacity(0.1),
        highlightColor: neonGreen.withOpacity(0.2),
        splashColor: neonGreen.withOpacity(0.3),

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: neonGreen,
          onPrimary: carbonBlack,
          secondary: accentGreen,
          onSecondary: ghostWhite,
          tertiary: infoBlue,
          onTertiary: ghostWhite,
          surface: surfaceGray,
          onSurface: ghostWhite,
          background: carbonBlack,
          onBackground: ghostWhite,
          error: errorRed,
          onError: ghostWhite,
          outline: borderGray,
          outlineVariant: terminalGray,
          surfaceVariant: borderGray,
          onSurfaceVariant: devGray,
        ),

        // Typography
        textTheme: TextTheme(
          displayLarge: headlineStyle.copyWith(fontSize: 32),
          displayMedium: headlineStyle,
          displaySmall: titleStyle.copyWith(fontSize: 24),
          headlineLarge: titleStyle.copyWith(fontSize: 22),
          headlineMedium: titleStyle,
          headlineSmall: titleStyle.copyWith(fontSize: 18),
          titleLarge: subtitleStyle.copyWith(fontSize: 18),
          titleMedium: subtitleStyle,
          titleSmall: subtitleStyle.copyWith(fontSize: 14),
          bodyLarge: bodyStyle.copyWith(fontSize: 16),
          bodyMedium: bodyStyle,
          bodySmall: mutedStyle.copyWith(fontSize: 13),
          labelLarge: codeStyle,
          labelMedium: terminalStyle,
          labelSmall: mutedStyle,
        ),

        // Component Themes
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceGray,
          foregroundColor: ghostWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: titleStyle,
          centerTitle: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
        outlinedButtonTheme:
            OutlinedButtonThemeData(style: secondaryButtonStyle),
        textButtonTheme: TextButtonThemeData(style: ghostButtonStyle),

        inputDecorationTheme: inputTheme,

        cardTheme: CardTheme(
          color: surfaceGray,
          shadowColor: Colors.black.withOpacity(0.2),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderGray, width: 1),
          ),
          margin: const EdgeInsets.all(8),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surfaceGray,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: neonGreen.withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: neonGreen,
                letterSpacing: 0.1,
              );
            }
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: devGray,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: neonGreen, size: 24);
            }
            return const IconThemeData(color: devGray, size: 24);
          }),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: surfaceGray,
          contentTextStyle: bodyStyle,
          actionTextColor: neonGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: borderGray, width: 1),
          ),
          elevation: 16,
        ),

        dialogTheme: DialogTheme(
          backgroundColor: surfaceGray,
          titleTextStyle: titleStyle,
          contentTextStyle: bodyStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderGray, width: 1),
          ),
          elevation: 24,
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surfaceGray,
          modalBackgroundColor: surfaceGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            side: BorderSide(color: borderGray, width: 1),
          ),
          elevation: 24,
        ),

        // Extensions for custom components
        extensions: const <ThemeExtension<dynamic>>[
          GitAlongThemeExtension(
            primaryGlow: primaryGlow,
            subtleGlow: subtleGlow,
            cardShadow: cardShadow,
            commitDotColors: [
              Color(0xFF161B22), // Level 0 - Empty
              Color(0xFF0E4429), // Level 1 - Low
              Color(0xFF006D32), // Level 2 - Medium-low
              Color(0xFF26A641), // Level 3 - Medium
              Color(0xFF39D353), // Level 4 - High
            ],
          ),
        ],
      );
}

/// Custom theme extension for GitAlong-specific properties
@immutable
class GitAlongThemeExtension extends ThemeExtension<GitAlongThemeExtension> {
  const GitAlongThemeExtension({
    required this.primaryGlow,
    required this.subtleGlow,
    required this.cardShadow,
    required this.commitDotColors,
  });

  final BoxShadow primaryGlow;
  final BoxShadow subtleGlow;
  final BoxShadow cardShadow;
  final List<Color> commitDotColors;

  @override
  GitAlongThemeExtension copyWith({
    BoxShadow? primaryGlow,
    BoxShadow? subtleGlow,
    BoxShadow? cardShadow,
    List<Color>? commitDotColors,
  }) {
    return GitAlongThemeExtension(
      primaryGlow: primaryGlow ?? this.primaryGlow,
      subtleGlow: subtleGlow ?? this.subtleGlow,
      cardShadow: cardShadow ?? this.cardShadow,
      commitDotColors: commitDotColors ?? this.commitDotColors,
    );
  }

  @override
  GitAlongThemeExtension lerp(
      ThemeExtension<GitAlongThemeExtension>? other, double t) {
    if (other is! GitAlongThemeExtension) {
      return this;
    }
    return GitAlongThemeExtension(
      primaryGlow:
          BoxShadow.lerp(primaryGlow, other.primaryGlow, t) ?? primaryGlow,
      subtleGlow: BoxShadow.lerp(subtleGlow, other.subtleGlow, t) ?? subtleGlow,
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t) ?? cardShadow,
      commitDotColors:
          commitDotColors, // Colors don't interpolate well, keep original
    );
  }
}

/// Helper extension for accessing custom theme properties
extension GitAlongThemeContext on BuildContext {
  GitAlongThemeExtension get gitAlongTheme =>
      Theme.of(this).extension<GitAlongThemeExtension>()!;
}
