import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🎨 GitHub-inspired theme for Gitalong
/// Colors: #0D1117 (background), #2EA043 (accent), #C9D1D9 (text)
/// Font: JetBrains Mono for code, Inter for UI
class AppTheme {
  // GitHub Dark Theme Colors
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color surfaceColor = Color(0xFF21262D);
  static const Color cardColor = Color(0xFF161B22);
  static const Color accentColor = Color(0xFF2EA043);
  static const Color accentHoverColor = Color(0xFF3FB950);
  static const Color textPrimary = Color(0xFFC9D1D9);
  static const Color textSecondary = Color(0xFF7D8590);
  static const Color textMuted = Color(0xFF484F58);
  static const Color borderColor = Color(0xFF30363D);
  static const Color errorColor = Color(0xFFDA3633);
  static const Color warningColor = Color(0xFFD29922);
  static const Color successColor = Color(0xFF238636);
  static const Color infoColor = Color(0xFF58A6FF);

  // Additional colors for GitHub profile card
  static const Color surfaceGray = surfaceColor;
  static const Color borderGray = borderColor;
  static const Color devGray = textSecondary;
  static const Color neonGreen = accentColor;
  static const Color carbonBlack = backgroundColor;

  // Custom gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentHoverColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardColor, surfaceColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 🎯 Main theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentHoverColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      
      // Typography with JetBrains Mono
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
        fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
        fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
        fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        actionsIconTheme: const IconThemeData(color: textPrimary),
      ),

      // Scaffold theme
      scaffoldBackgroundColor: backgroundColor,

      // Card theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textMuted,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: accentColor,
        disabledColor: cardColor,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          color: textPrimary,
        ),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: borderColor,
        circularTrackColor: borderColor,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
            return accentColor.withOpacity(0.3);
            }
          return borderColor;
          }),
        ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: borderColor, width: 2),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return textSecondary;
        }),
      ),
    );
  }

  /// 🎨 Custom text styles
  static TextStyle get codeStyle => GoogleFonts.inter(
        fontSize: 14,
        color: textPrimary,
        backgroundColor: cardColor,
      );

  static TextStyle get titleStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get terminalStyle => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        color: textPrimary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 14,
        color: textPrimary,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get mutedStyle => GoogleFonts.inter(
        fontSize: 12,
        color: textSecondary,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get successText => GoogleFonts.inter(
        fontSize: 14,
        color: successColor,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 14,
        color: errorColor,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get warningText => GoogleFonts.inter(
        fontSize: 14,
        color: warningColor,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get infoText => GoogleFonts.inter(
        fontSize: 14,
        color: infoColor,
        fontWeight: FontWeight.w500,
      );

  /// 🎨 Custom decoration styles
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardColor,
            borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get accentCardDecoration => BoxDecoration(
        gradient: accentGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get glassDecoration => BoxDecoration(
        color: surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
