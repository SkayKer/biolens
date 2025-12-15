import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Thème principal de l'application BioLens.
/// 
/// Ambiance "Nature & Clean" avec des couleurs vertes naturelles
/// et une typographie moderne et arrondie.
class AppTheme {
  AppTheme._();

  /// Thème clair (thème par défaut)
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    
    // ═══════════════════════════════════════════════════════════════════════
    // SCHÉMA DE COULEURS
    // ═══════════════════════════════════════════════════════════════════════
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.secondaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.primaryDark,
      tertiary: AppColors.secondary,
      onTertiary: AppColors.onSecondary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // COULEUR DE FOND
    // ═══════════════════════════════════════════════════════════════════════
    scaffoldBackgroundColor: AppColors.background,

    // ═══════════════════════════════════════════════════════════════════════
    // APP BAR
    // ═══════════════════════════════════════════════════════════════════════
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.onPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // TYPOGRAPHIE
    // ═══════════════════════════════════════════════════════════════════════
    textTheme: AppTypography.textTheme,

    // ═══════════════════════════════════════════════════════════════════════
    // BOUTONS
    // ═══════════════════════════════════════════════════════════════════════
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.labelLarge,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // CARTES
    // ═══════════════════════════════════════════════════════════════════════
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // FLOATING ACTION BUTTON
    // ═══════════════════════════════════════════════════════════════════════
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // BOTTOM NAVIGATION BAR
    // ═══════════════════════════════════════════════════════════════════════
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NAVIGATION BAR (Material 3)
    // ═══════════════════════════════════════════════════════════════════════
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface, 
      indicatorColor: AppColors.secondary.withValues(alpha: 0.3),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.textSecondary, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(color: AppColors.primary);
        }
        return AppTypography.labelSmall.copyWith(color: AppColors.textSecondary);
      }),
      elevation: 3,
      height: 65,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // INPUT DECORATION
    // ═══════════════════════════════════════════════════════════════════════
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // DIVIDER
    // ═══════════════════════════════════════════════════════════════════════
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // ICON
    // ═══════════════════════════════════════════════════════════════════════
    iconTheme: const IconThemeData(
      color: AppColors.primary,
      size: 24,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // CHIP
    // ═══════════════════════════════════════════════════════════════════════
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
      labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
