import 'package:flutter/material.dart';

/// Palette de couleurs "Nature & Clean" pour l'application BioLens.
/// 
/// Ambiance naturelle avec des tons verts et terreux.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // COULEURS PRINCIPALES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Vert Forêt - Couleur primaire pour les app bars et boutons principaux
  static const Color primary = Color(0xFF3A5A40);

  /// Vert Clair/Sauge - Couleur secondaire pour les arrière-plans de cartes et accents
  static const Color secondary = Color(0xFFA3B18A);

  /// Blanc Cassé/Crème - Fond de l'application (plus doux que le blanc pur)
  static const Color background = Color(0xFFDAD7CD);

  // ═══════════════════════════════════════════════════════════════════════════
  // COULEURS SÉMANTIQUES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Couleur du texte/icônes sur fond primaire
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Couleur du texte/icônes sur fond secondaire
  static const Color onSecondary = Color(0xFF1A1A1A);

  /// Couleur du texte/icônes sur fond de l'application
  static const Color onBackground = Color(0xFF1A1A1A);

  /// Surface pour les cartes et éléments surélevés
  static const Color surface = Color(0xFFF5F3EF);

  /// Couleur du texte/icônes sur les surfaces
  static const Color onSurface = Color(0xFF1A1A1A);

  /// Couleur d'erreur
  static const Color error = Color(0xFFC1121F);

  /// Couleur du texte/icônes sur erreur
  static const Color onError = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // COULEURS SUPPLÉMENTAIRES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Vert foncé pour les variantes du primaire
  static const Color primaryDark = Color(0xFF2D4632);

  /// Vert très clair pour les variantes du secondaire
  static const Color secondaryLight = Color(0xFFBBC8A5);

  /// Couleur de bordure subtile
  static const Color border = Color(0xFFB5B3AA);

  /// Couleur de texte secondaire/désactivé
  static const Color textSecondary = Color(0xFF5C5C5C);
}
