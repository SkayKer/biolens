import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modes de thème disponibles.
enum ThemePreference {
  /// Suivre le thème système
  system,
  /// Thème clair forcé
  light,
  /// Thème sombre forcé
  dark,
}

/// Provider pour gérer le thème de l'application.
/// 
/// Gère la persistance du choix de thème via SharedPreferences.
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_preference';
  
  ThemePreference _preference = ThemePreference.system;
  SharedPreferences? _prefs;

  /// Préférence de thème actuelle.
  ThemePreference get preference => _preference;

  /// Initialise le provider et charge la préférence sauvegardée.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedValue = _prefs?.getString(_themeKey);
    
    if (savedValue != null) {
      _preference = ThemePreference.values.firstWhere(
        (e) => e.name == savedValue,
        orElse: () => ThemePreference.system,
      );
    }
    notifyListeners();
  }

  /// Définit la préférence de thème et la sauvegarde.
  Future<void> setThemePreference(ThemePreference preference) async {
    _preference = preference;
    await _prefs?.setString(_themeKey, preference.name);
    notifyListeners();
  }

  /// Retourne le ThemeMode correspondant à la préférence.
  ThemeMode get themeMode {
    switch (_preference) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  /// Indique si le mode sombre est actif (pour le Switch).
  /// 
  /// En mode système, retourne la valeur du système.
  bool isDarkMode(BuildContext context) {
    switch (_preference) {
      case ThemePreference.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
      case ThemePreference.light:
        return false;
      case ThemePreference.dark:
        return true;
    }
  }

  /// Bascule entre mode clair et sombre.
  /// 
  /// Si en mode système, passe au mode opposé du système actuel.
  Future<void> toggleDarkMode(BuildContext context) async {
    final isCurrentlyDark = isDarkMode(context);
    await setThemePreference(isCurrentlyDark ? ThemePreference.light : ThemePreference.dark);
  }
}
