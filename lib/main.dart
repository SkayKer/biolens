import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';

/// Point d'entrée de l'application BioLens.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurer l'orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialiser le stockage local
  await LocalStorageService().initialize();
  
  runApp(const BioLensApp());
}

/// Widget racine de l'application BioLens.
/// 
/// Application de reconnaissance de plantes avec un design "Nature & Clean".
class BioLensApp extends StatelessWidget {
  const BioLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ═══════════════════════════════════════════════════════════════════════
      // CONFIGURATION DE BASE
      // ═══════════════════════════════════════════════════════════════════════
      title: 'BioLens',
      debugShowCheckedModeBanner: false,

      // ═══════════════════════════════════════════════════════════════════════
      // THÈME
      // ═══════════════════════════════════════════════════════════════════════
      theme: AppTheme.lightTheme,

      // ═══════════════════════════════════════════════════════════════════════
      // ROUTEUR (GoRouter)
      // ═══════════════════════════════════════════════════════════════════════
      routerConfig: AppRouter.router,
    );
  }
}
