import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/models/saved_plant.dart';
import '../../core/services/local_storage_service.dart';
import '../../main.dart' show themeProvider;
import 'widgets/stat_card.dart';

/// Écran Profil avec statistiques et carte des découvertes.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Nombre total de plantes
  int _plantCount = 0;
  
  /// Dernière plante découverte
  SavedPlant? _lastDiscovery;
  
  /// Plantes avec coordonnées GPS
  List<SavedPlant> _plantsWithLocation = [];
  
  /// Indique si les données sont en cours de chargement
  bool _isLoading = true;

  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// Charge les statistiques.
  Future<void> _loadStats() async {
    try {
      await _storageService.initialize();
      
      final count = await _storageService.getPlantCount();
      final lastPlant = await _storageService.getLastDiscovery();
      final plantsWithLoc = await _storageService.getPlantsWithLocation();

      if (mounted) {
        setState(() {
          _plantCount = count;
          _lastDiscovery = lastPlant;
          _plantsWithLocation = plantsWithLoc;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Calcule le niveau de l'utilisateur.
  String _getUserLevel() {
    if (_plantCount == 0) return 'Débutant';
    if (_plantCount < 5) return 'Curieux';
    if (_plantCount < 15) return 'Explorateur';
    if (_plantCount < 30) return 'Botaniste';
    if (_plantCount < 50) return 'Expert';
    return 'Maître Botaniste';
  }

  /// Formate la dernière découverte.
  String _getLastDiscoveryText() {
    if (_lastDiscovery == null) return 'Aucune';
    
    final now = DateTime.now();
    final diff = now.difference(_lastDiscovery!.discoveryDate);
    
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    if (diff.inDays < 30) return 'Il y a ${diff.inDays ~/ 7} sem.';
    return 'Il y a ${diff.inDays ~/ 30} mois';
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser la couleur de fond du thème actuel
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ═══════════════════════════════════════════════════════════════
                // APP BAR
                // ═══════════════════════════════════════════════════════════════
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(),
                  ),
                ),

                // ═══════════════════════════════════════════════════════════════
                // CONTENU
                // ═══════════════════════════════════════════════════════════════
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ═════════════════════════════════════════════════════════
                        // STATISTIQUES (3 cartes)
                        // ═════════════════════════════════════════════════════════
                        _buildStatsSection(),
                        const SizedBox(height: 24),

                        // ═════════════════════════════════════════════════════════
                        // CARTE DES DÉCOUVERTES
                        // ═════════════════════════════════════════════════════════
                        _buildMapSection(),
                        const SizedBox(height: 24),

                        // ═════════════════════════════════════════════════════════
                        // PARAMÈTRES
                        // ═════════════════════════════════════════════════════════
                        _buildSettingsSection(),
                        
                        // Espace pour la nav bar
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Header du profil avec avatar.
  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: AppColors.secondary,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Nom
            Text(
              'Explorateur',
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            
            // Niveau
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getUserLevel(),
                style: AppTypography.labelMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section des statistiques (3 cartes).
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistiques', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.local_florist,
                title: 'Plantes',
                value: _plantCount.toString(),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.emoji_events,
                title: 'Niveau',
                value: _getUserLevel(),
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.history,
                title: 'Dernière',
                value: _getLastDiscoveryText(),
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section de la carte des découvertes.
  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Mes découvertes', style: AppTypography.headlineSmall),
            const Spacer(),
            Text(
              '${_plantsWithLocation.length} lieu${_plantsWithLocation.length > 1 ? 'x' : ''}',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('/plants-map'),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                _plantsWithLocation.isEmpty
                    ? _buildEmptyMap()
                    : _buildMap(),
                // Overlay pour indiquer que c'est cliquable
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Voir tout',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Carte vide.
  Widget _buildEmptyMap() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune localisation',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Activez le GPS lors de vos scans',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// Carte avec les marqueurs.
  Widget _buildMap() {
    // Calculer le centre de la carte
    final avgLat = _plantsWithLocation
        .map((p) => p.latitude!)
        .reduce((a, b) => a + b) / _plantsWithLocation.length;
    final avgLng = _plantsWithLocation
        .map((p) => p.longitude!)
        .reduce((a, b) => a + b) / _plantsWithLocation.length;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(avgLat, avgLng),
        initialZoom: 10,
      ),
      children: [
        // Couche de tuiles OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.biolens.app',
        ),
        // Marqueurs des plantes
        MarkerLayer(
          markers: _plantsWithLocation.map((plant) {
            return Marker(
              point: LatLng(plant.latitude!, plant.longitude!),
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_florist,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Section des paramètres.
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paramètres', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.download,
                title: 'Exporter mon herbier',
                onTap: _exportHerbier,
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.dark_mode,
                title: 'Mode Sombre',
                trailing: Switch(
                  value: themeProvider.isDarkMode(context),
                  onChanged: (value) {
                    themeProvider.toggleDarkMode(context);
                  },
                  activeTrackColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'À propos',
                onTap: _showAbout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tuile de paramètre.
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.bodyLarge),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Exporte l'herbier.
  void _exportHerbier() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export en cours...'),
        backgroundColor: AppColors.primary,
      ),
    );
    // TODO: Implémenter l'export
  }

  /// Affiche la page À propos.
  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'BioLens',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.local_florist,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'BioLens est une application de reconnaissance de plantes '
          'qui vous aide à identifier les espèces autour de vous.',
        ),
      ],
    );
  }
}
