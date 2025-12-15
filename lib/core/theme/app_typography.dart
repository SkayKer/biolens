import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Styles de typographie pour l'application BioLens.
/// 
/// Utilise la police Poppins (sans-serif ronde et moderne) via Google Fonts.
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLES DE TEXTE PRINCIPAUX
  // ═══════════════════════════════════════════════════════════════════════════

  /// Headline Large - Pour les titres principaux (Gras)
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
  );

  /// Headline Medium - Pour les noms d'espèces (Gras)
  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    letterSpacing: -0.25,
  );

  /// Headline Small - Pour les sous-titres importants (Semi-Gras)
  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLES DE CORPS DE TEXTE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Body Large - Pour le texte principal (Normal)
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
    height: 1.5,
  );

  /// Body Medium - Pour les descriptions (Léger)
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.onBackground,
    height: 1.5,
  );

  /// Body Small - Pour le texte secondaire (Léger)
  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // STYLES SPÉCIAUX
  // ═══════════════════════════════════════════════════════════════════════════

  /// Caption - Pour les noms latins (Italique)
  static TextStyle get caption => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  /// Label Large - Pour les boutons et labels
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Label Medium - Pour les petits labels
  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// Label Small - Pour les très petits labels
  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // THÈME DE TEXTE COMPLET
  // ═══════════════════════════════════════════════════════════════════════════

  /// Retourne le TextTheme complet pour Material Design 3
  static TextTheme get textTheme => TextTheme(
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
