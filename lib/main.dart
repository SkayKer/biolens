import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';

/// Instance globale du ThemeProvider pour accès facile.
final themeProvider = ThemeProvider();

/// Classe pour contourner les erreurs de certificat SSL en développement.
/// ⚠️ NE PAS UTILISER EN PRODUCTION !
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// Point d'entrée de l'application BioLens.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Contourner les erreurs SSL en développement
  // ⚠️ À SUPPRIMER EN PRODUCTION !
  HttpOverrides.global = MyHttpOverrides();
  
  // Configurer l'orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialiser le stockage local
  await LocalStorageService().initialize();
  
  // Initialiser le provider de thème (charge la préférence sauvegardée)
  await themeProvider.initialize();
  
  runApp(const BioLensApp());
}

/// Widget racine de l'application BioLens.
/// 
/// Application de reconnaissance de plantes avec un design "Nature & Clean".
class BioLensApp extends StatefulWidget {
  const BioLensApp({super.key});

  @override
  State<BioLensApp> createState() => _BioLensAppState();
}

class _BioLensAppState extends State<BioLensApp> {
  @override
  void initState() {
    super.initState();
    // Écouter les changements de thème
    themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ═══════════════════════════════════════════════════════════════════════
      // CONFIGURATION DE BASE
      // ═══════════════════════════════════════════════════════════════════════
      title: 'BioLens',
      debugShowCheckedModeBanner: false,

      // ═══════════════════════════════════════════════════════════════════════
      // THÈMES
      // ═══════════════════════════════════════════════════════════════════════
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // ═══════════════════════════════════════════════════════════════════════
      // ROUTEUR (GoRouter)
      // ═══════════════════════════════════════════════════════════════════════
      routerConfig: AppRouter.router,
    );
  }
}
