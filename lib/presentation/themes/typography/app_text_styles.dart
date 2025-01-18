import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextStyle _base = GoogleFonts.poppins();

  static final TextStyle displayLarge = _base.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
  static final TextStyle displayMedium = _base.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static final TextStyle displaySmall = _base.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );
  static final TextStyle headlineMedium = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static final TextStyle headlineSmall = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static final TextStyle titleLarge = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static final TextStyle titleMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static final TextStyle titleSmall = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.2,
  );

  static final TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static final TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.5,
  );
  static final TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w200,
    height: 1.5,
  );

  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static final TextStyle labelMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 1.3,
  );
  static final TextStyle labelSmall = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w200,
    height: 1.2,
  );
}
