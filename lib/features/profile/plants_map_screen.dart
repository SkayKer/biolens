import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/models/saved_plant.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Écran de carte affichant toutes les plantes localisées.
/// 
/// Affiche une carte de France avec des marqueurs pour chaque plante.
/// Cliquer sur un marqueur affiche les détails de la plante.
class PlantsMapScreen extends StatefulWidget {
  const PlantsMapScreen({super.key});

  @override
  State<PlantsMapScreen> createState() => _PlantsMapScreenState();
}

class _PlantsMapScreenState extends State<PlantsMapScreen> {
  /// Contrôleur de la carte
  final MapController _mapController = MapController();

  /// Service de stockage local
  final LocalStorageService _storageService = LocalStorageService();

  /// Plantes avec localisation
  List<SavedPlant> _plants = [];

  /// Indique si les données sont en cours de chargement
  bool _isLoading = true;

  /// Plante actuellement sélectionnée (pour la preview)
  SavedPlant? _selectedPlant;

  /// Centre initial de la carte (France)
  static const LatLng _franceCenter = LatLng(46.603354, 1.888334);

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  /// Charge les plantes avec localisation.
  Future<void> _loadPlants() async {
    try {
      await _storageService.initialize();
      final plants = await _storageService.getPlantsWithLocation();

      if (mounted) {
        setState(() {
          _plants = plants;
          _isLoading = false;
        });

        // Centrer la carte sur les plantes si disponibles
        if (plants.isNotEmpty) {
          _centerOnPlants();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Centre la carte sur l'ensemble des plantes.
  void _centerOnPlants() {
    if (_plants.isEmpty) return;

    if (_plants.length == 1) {
      // Une seule plante: centrer dessus
      _mapController.move(
        LatLng(_plants.first.latitude!, _plants.first.longitude!),
        12,
      );
    } else {
      // Plusieurs plantes: calculer les limites
      final bounds = LatLngBounds.fromPoints(
        _plants.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
      );
      
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  /// Sélectionne une plante et affiche sa preview.
  void _selectPlant(SavedPlant plant) {
    setState(() => _selectedPlant = plant);
  }

  /// Navigue vers les détails de la plante.
  void _openPlantDetails(SavedPlant plant) {
    context.push('/species/${plant.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(
          'Carte des découvertes',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.onPrimary),
        ),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (_plants.isNotEmpty)
            IconButton(
              onPressed: _centerOnPlants,
              icon: const Icon(Icons.center_focus_strong),
              tooltip: 'Centrer sur les plantes',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    _buildMap(),
                    if (_selectedPlant != null) _buildPlantPreview(),
                  ],
                ),
    );
  }

  /// Affiche un état vide si aucune plante n'est localisée.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune plante localisée',
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Scannez des plantes et ajoutez leur localisation pour les voir apparaître sur la carte.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner une plante'),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la carte avec les marqueurs.
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _franceCenter,
        initialZoom: 6,
        onTap: (_, __) {
          // Désélectionner la plante quand on tape ailleurs
          setState(() => _selectedPlant = null);
        },
      ),
      children: [
        // Couche de tuiles OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.biolens.app',
        ),

        // Marqueurs des plantes
        MarkerLayer(
          markers: _plants.map((plant) => _buildPlantMarker(plant)).toList(),
        ),
      ],
    );
  }

  /// Construit un marqueur pour une plante.
  Marker _buildPlantMarker(SavedPlant plant) {
    final isSelected = _selectedPlant?.id == plant.id;
    final imageFile = File(plant.imagePath);

    return Marker(
      point: LatLng(plant.latitude!, plant.longitude!),
      width: isSelected ? 60 : 50,
      height: isSelected ? 60 : 50,
      child: GestureDetector(
        onTap: () => _selectPlant(plant),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white,
              width: isSelected ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: imageFile.existsSync()
                ? Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    width: isSelected ? 60 : 50,
                    height: isSelected ? 60 : 50,
                  )
                : Container(
                    color: AppColors.secondary,
                    child: const Icon(
                      Icons.local_florist,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Construit la preview de la plante sélectionnée.
  Widget _buildPlantPreview() {
    final plant = _selectedPlant!;
    final imageFile = File(plant.imagePath);

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () => _openPlantDetails(plant),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image de la plante
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: imageFile.existsSync()
                      ? Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.secondary,
                          child: const Icon(
                            Icons.local_florist,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plant.commonName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.scientificName,
                      style: AppTypography.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(plant.discoveryDate),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Indicateur pour ouvrir
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formate une date.
  String _formatDate(DateTime date) {
    final months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sept', 'oct', 'nov', 'déc'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
