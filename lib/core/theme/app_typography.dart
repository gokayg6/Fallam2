import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static String get fontFamily => GoogleFonts.inter().fontFamily!;
  static TextStyle tabLabel({Color? color}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.2,
    color: color ?? Colors.white,
  );
}
