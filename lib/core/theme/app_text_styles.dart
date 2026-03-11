import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// App text styles
class AppTextStyles {
  AppTextStyles._();

  // Display
  static TextStyle displayLarge(Color color) => GoogleFonts.inter(
    fontSize: 57.sp,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium(Color color) => GoogleFonts.inter(
    fontSize: 45.sp,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.2,
  );

  static TextStyle displaySmall(Color color) => GoogleFonts.inter(
    fontSize: 36.sp,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.2,
  );

  // Headline
  static TextStyle headlineLarge(Color color) => GoogleFonts.inter(
    fontSize: 32.sp,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.25,
  );

  static TextStyle headlineMedium(Color color) => GoogleFonts.inter(
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle headlineSmall(Color color) => GoogleFonts.inter(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  // Title
  static TextStyle titleLarge(Color color) => GoogleFonts.inter(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle titleMedium(Color color) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // Body
  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
    letterSpacing: 0.5,
  );

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
    letterSpacing: 0.4,
  );

  // Label
  static TextStyle labelLarge(Color color) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium(Color color) => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall(Color color) => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Code
  static TextStyle code(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.6,
  );

  static TextStyle codeSmall(Color color) => GoogleFonts.jetBrainsMono(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.6,
  );
}
