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

  // ═══════════════════════════════════════════════════════════════════════════
  // THÈME SOMBRE - "Nature Nocturne"
  // ═══════════════════════════════════════════════════════════════════════════
  // Un thème sombre profond et reposant, évoquant une immersion nocturne en forêt.
  // Évite le noir pur pour un rendu plus organique et chaleureux.

  /// Couleurs spécifiques au thème sombre
  static const _darkBackground = Color(0xFF181A1B);      // Gris charbon profond
  static const _darkSurface = Color(0xFF262626);         // Gris foncé pour les cartes
  static const _darkSurfaceElevated = Color(0xFF2C2C2C); // Surface légèrement élevée
  static const _darkPrimary = Color(0xFF4A7C59);         // Vert émeraude sourd (accent)
  static const _darkPrimaryMuted = Color(0xFF3D6B4A);    // Vert forêt très foncé (header)
  static const _darkTextPrimary = Color(0xFFF5F5F5);     // Blanc cassé
  static const _darkTextSecondary = Color(0xFFBDBDBD);   // Gris moyen
  static const _darkTextMuted = Color(0xFF8A8A8A);       // Gris plus foncé
  static const _darkError = Color(0xFFB85C5C);           // Rouge/brun dé-saturé
  static const _darkDivider = Color(0xFF3A3A3A);         // Ligne de séparation subtile

  /// Thème sombre BioDex - Nature Nocturne
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // ═══════════════════════════════════════════════════════════════════════
    // SCHÉMA DE COULEURS
    // ═══════════════════════════════════════════════════════════════════════
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      // Accent principal - Vert émeraude sourd
      primary: _darkPrimary,
      onPrimary: _darkTextPrimary,
      primaryContainer: _darkPrimaryMuted,
      onPrimaryContainer: _darkTextPrimary,
      // Secondaire
      secondary: _darkPrimary,
      onSecondary: _darkTextPrimary,
      secondaryContainer: _darkSurfaceElevated,
      onSecondaryContainer: _darkTextPrimary,
      // Tertiaire
      tertiary: _darkPrimaryMuted,
      onTertiary: _darkTextPrimary,
      // Erreur - Rouge/brun dé-saturé
      error: _darkError,
      onError: _darkTextPrimary,
      // Surfaces
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      onSurfaceVariant: _darkTextSecondary,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // FOND PRINCIPAL - Gris charbon profond
    // ═══════════════════════════════════════════════════════════════════════
    scaffoldBackgroundColor: _darkBackground,

    // ═══════════════════════════════════════════════════════════════════════
    // APP BAR - Transparent / même couleur que le scaffold
    // ═══════════════════════════════════════════════════════════════════════
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _darkTextPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _darkTextPrimary,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // TYPOGRAPHIE - Poppins avec contrastes doux
    // ═══════════════════════════════════════════════════════════════════════
    textTheme: AppTypography.textTheme.copyWith(
      // Headlines - Blanc cassé
      displayLarge: AppTypography.displayLarge.copyWith(color: _darkTextPrimary),
      displayMedium: AppTypography.displayMedium.copyWith(color: _darkTextPrimary),
      displaySmall: AppTypography.displaySmall.copyWith(color: _darkTextPrimary),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: _darkTextPrimary),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: _darkTextPrimary),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: _darkTextPrimary),
      titleLarge: AppTypography.titleLarge.copyWith(color: _darkTextPrimary),
      titleMedium: AppTypography.titleMedium.copyWith(color: _darkTextPrimary),
      titleSmall: AppTypography.titleSmall.copyWith(color: _darkTextSecondary),
      // Body - Gris clair pour un contraste doux
      bodyLarge: AppTypography.bodyLarge.copyWith(color: _darkTextPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: _darkTextSecondary),
      bodySmall: AppTypography.bodySmall.copyWith(color: _darkTextMuted),
      // Labels
      labelLarge: AppTypography.labelLarge.copyWith(color: _darkTextPrimary),
      labelMedium: AppTypography.labelMedium.copyWith(color: _darkTextSecondary),
      labelSmall: AppTypography.labelSmall.copyWith(color: _darkTextMuted),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // BOUTONS
    // ═══════════════════════════════════════════════════════════════════════
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: _darkTextPrimary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimary,
        side: const BorderSide(color: _darkPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimary,
        textStyle: AppTypography.labelLarge,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // CARTES - Surface gris foncé avec élévation subtile
    // ═══════════════════════════════════════════════════════════════════════
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // FLOATING ACTION BUTTON - Vert primaire, forme pill/arrondie
    // ═══════════════════════════════════════════════════════════════════════
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimary,
      foregroundColor: _darkTextPrimary,
      elevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // BOTTOM NAVIGATION BAR - Fond surface, accent vert
    // ═══════════════════════════════════════════════════════════════════════
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _darkPrimary,
      unselectedItemColor: _darkTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // BOTTOM APP BAR
    // ═══════════════════════════════════════════════════════════════════════
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: _darkSurface,
      elevation: 8,
      shadowColor: Colors.black,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NAVIGATION BAR (Material 3)
    // ═══════════════════════════════════════════════════════════════════════
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _darkSurface, 
      indicatorColor: _darkPrimary.withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: _darkPrimary, size: 24);
        }
        return const IconThemeData(color: _darkTextMuted, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(color: _darkPrimary);
        }
        return AppTypography.labelSmall.copyWith(color: _darkTextMuted);
      }),
      elevation: 3,
      height: 65,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // INPUT DECORATION
    // ═══════════════════════════════════════════════════════════════════════
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkError),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: _darkTextMuted),
      labelStyle: AppTypography.bodyMedium.copyWith(color: _darkTextSecondary),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // DIVIDER - Ligne subtile
    // ═══════════════════════════════════════════════════════════════════════
    dividerTheme: const DividerThemeData(
      color: _darkDivider,
      thickness: 1,
      space: 1,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // ICONS - Vert primaire par défaut
    // ═══════════════════════════════════════════════════════════════════════
    iconTheme: const IconThemeData(
      color: _darkPrimary,
      size: 24,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // CHIPS
    // ═══════════════════════════════════════════════════════════════════════
    chipTheme: ChipThemeData(
      backgroundColor: _darkPrimary.withValues(alpha: 0.15),
      labelStyle: AppTypography.labelMedium.copyWith(color: _darkPrimary),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // SWITCH
    // ═══════════════════════════════════════════════════════════════════════
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkPrimary;
        }
        return _darkTextMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkPrimary.withValues(alpha: 0.4);
        }
        return _darkDivider;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // DIALOG
    // ═══════════════════════════════════════════════════════════════════════
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: AppTypography.headlineSmall.copyWith(color: _darkTextPrimary),
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: _darkTextSecondary),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // BOTTOM SHEET
    // ═══════════════════════════════════════════════════════════════════════
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleColor: _darkTextMuted,
      dragHandleSize: Size(40, 4),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // LIST TILE
    // ═══════════════════════════════════════════════════════════════════════
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: _darkPrimary,
      textColor: _darkTextPrimary,
      subtitleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: _darkTextSecondary,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // SNACKBAR
    // ═══════════════════════════════════════════════════════════════════════
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkSurfaceElevated,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: _darkTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // PROGRESS INDICATOR
    // ═══════════════════════════════════════════════════════════════════════
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _darkPrimary,
      circularTrackColor: _darkDivider,
      linearTrackColor: _darkDivider,
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // SLIDER
    // ═══════════════════════════════════════════════════════════════════════
    sliderTheme: SliderThemeData(
      activeTrackColor: _darkPrimary,
      inactiveTrackColor: _darkDivider,
      thumbColor: _darkPrimary,
      overlayColor: _darkPrimary.withValues(alpha: 0.2),
    ),
  );
}


