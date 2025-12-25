import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Başlık stilleri
  static TextStyle get heading1 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
  
  static TextStyle get heading2 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.3,
  );
  
  static TextStyle get heading3 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
  
  static TextStyle get heading4 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get headingSmall => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  // Gövde metni stilleri
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  
  // Özel stiller - Tema-aware
  static TextStyle mysticalText(bool isDark) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.getTextSecondary(isDark),
    letterSpacing: 0.5,
    height: 1.6,
  );
  
  static TextStyle get fortuneResult => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.7,
    letterSpacing: 0.2,
  );
  
  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get cardSubtitle => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get cardInput => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get cardOutput => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get input => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  // Buton stilleri
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  

  
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get buttonMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get buttonSmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get buttonLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  // Caption stili
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  // Navigasyon stilleri
  static TextStyle get navLabel => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get navLabelActive => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  
  // Form stilleri
  static TextStyle get inputLabel => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get inputText => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get inputHint => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  // Karma ve puan stilleri
  static TextStyle get karmaText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );
  
  static TextStyle get premiumText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFFD700),
  );
  
  // Hata ve başarı stilleri
  static TextStyle get errorText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );
  
  static TextStyle get successText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
  );
  
  // Özel efekt stilleri
  static TextStyle get glowText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    shadows: [
      Shadow(
        color: AppColors.accent.withValues(alpha: 0.5),
        blurRadius: 10,
        offset: Offset(0, 0),
      ),
    ],
  );
  

  
  // Karma gösterimi stili
  static TextStyle get karmaDisplay => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );
  
  // Navigasyon etiketi stili
  static TextStyle get navigationLabel => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}