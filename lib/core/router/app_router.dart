import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/shell/shell_screen.dart';
import '../../features/herbier/herbier_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/plants_map_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/scan/scan_result_screen.dart';
import '../../features/scan/location_picker_screen.dart';
import '../../features/species/species_detail_screen.dart';

/// Configuration du routeur de l'application BioLens.
/// 
/// Utilise GoRouter avec un ShellRoute pour la navigation principale
/// et des routes séparées pour le scanner et les détails d'espèce.
class AppRouter {
  AppRouter._();

  /// Clé de navigation globale
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Clé de navigation pour le shell
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  /// Instance du routeur
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/herbier',
    debugLogDiagnostics: true,
    routes: [
      // ═══════════════════════════════════════════════════════════════════════
      // SHELL ROUTE - Navigation principale avec bottom bar
      // ═══════════════════════════════════════════════════════════════════════
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/herbier',
            name: 'herbier',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HerbierScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // ROUTES PLEIN ÉCRAN (sans bottom bar)
      // ═══════════════════════════════════════════════════════════════════════
      GoRoute(
        path: '/scan',
        name: 'scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/scan/result',
        name: 'scanResult',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final imagePath = state.extra as String;
          return ScanResultScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: '/species/:id',
        name: 'species',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SpeciesDetailScreen(plantId: id);
        },
      ),
      GoRoute(
        path: '/location-picker',
        name: 'locationPicker',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LocationPickerScreen(),
      ),
      GoRoute(
        path: '/plants-map',
        name: 'plantsMap',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlantsMapScreen(),
      ),
    ],
  );
}
