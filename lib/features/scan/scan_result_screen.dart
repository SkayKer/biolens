import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import '../../core/models/plant_identification.dart';
import '../../core/models/saved_plant.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/plant_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Écran de résultat après la capture ou sélection d'une image.
///
/// Affiche l'image capturée et permet de lancer l'identification
/// ou de reprendre une nouvelle photo.
class ScanResultScreen extends StatefulWidget {
  /// Chemin vers l'image à analyser
  final String imagePath;

  const ScanResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  /// Indique si l'identification est en cours
  bool _isIdentifying = false;

  /// Organe sélectionné pour l'identification
  String _selectedOrgan = 'leaf';

  /// Coordonnées GPS de la plante
  double? _latitude;
  double? _longitude;

  /// Liste des organes disponibles
  final Map<String, String> _organs = {
    'leaf': 'Feuille',
    'flower': 'Fleur',
    'fruit': 'Fruit',
    'bark': 'Écorce',
  };

  /// Services
  final PlantApiService _apiService = PlantApiService();
  final LocalStorageService _storageService = LocalStorageService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /// Initialise la localisation automatiquement.
  Future<void> _initLocation() async {
    // Essayer d'obtenir la position GPS automatiquement
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
  }

  /// Ouvre l'écran de sélection manuelle de localisation.
  Future<void> _pickLocation() async {
    final result = await context.push<Map<String, double>?>('/location-picker');
    
    if (result != null && mounted) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  /// Lance l'identification de la plante
  Future<void> _identifyPlant() async {
    setState(() => _isIdentifying = true);

    try {
      // 1. Appeler l'API d'identification
      final imageFile = File(widget.imagePath);
      final identifications = await _apiService.identify(
        imageFile,
        organs: [_selectedOrgan],
      );

      if (!mounted) return;

      if (identifications.isEmpty) {
        _showError('Aucune plante n\'a pu être identifiée. Essayez avec une autre photo.');
        return;
      }

      // 2. Afficher les résultats pour sélection
      final selectedPlant = await _showIdentificationResults(identifications);

      if (selectedPlant == null || !mounted) return;

      // 3. Sauvegarder la plante dans l'herbier
      final savedPlant = await _savePlantToHerbier(selectedPlant);

      if (!mounted) return;

      // 4. Naviguer vers l'écran de détails de l'espèce
      // On utilise pushReplacement pour remplacer l'écran actuel (scan result)
      // tout en gardant l'herbier dans la pile de navigation
      context.go('/herbier');
      context.push('/species/${savedPlant.id}');
    } on PlantApiException catch (e) {
      if (mounted) {
        _showError('${e.message}\n${e.details}');
      }
    } catch (e) {
      if (mounted) {
        _showError('Erreur lors de l\'identification: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isIdentifying = false);
      }
    }
  }

  /// Affiche les résultats d'identification pour sélection
  Future<PlantIdentification?> _showIdentificationResults(
    List<PlantIdentification> identifications,
  ) async {
    return showModalBottomSheet<PlantIdentification>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _IdentificationResultsSheet(
        identifications: identifications,
      ),
    );
  }

  /// Sauvegarde la plante identifiée dans l'herbier
  Future<SavedPlant> _savePlantToHerbier(PlantIdentification identification) async {
    // Copier l'image vers le stockage local de l'app
    final imageFile = File(widget.imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(widget.imagePath);
    final savedImagePath = await _apiService.saveImageLocally(
      imageBytes,
      'plant_$timestamp$extension',
    );

    // Créer et sauvegarder la plante avec la localisation
    final plant = SavedPlant.create(
      scientificName: identification.scientificName,
      commonName: identification.displayName,
      imagePath: savedImagePath,
      family: identification.family,
      imageUrl: identification.imageUrl,
      description: identification.description,
      identificationScore: identification.score,
      latitude: _latitude,
      longitude: _longitude,
    );

    final id = await _storageService.savePlant(plant);
    plant.id = id;

    return plant;
  }

  /// Affiche une erreur
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Retourne à l'écran de scan pour reprendre une photo
  void _retakePhoto() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        title: Text(
          'Résultat du scan',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.onPrimary),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // IMAGE CAPTURÉE
          // ═══════════════════════════════════════════════════════════════════
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Impossible de charger l\'image',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // BOUTONS D'ACTION
          // ═══════════════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message d'instruction
                  Text(
                    'Votre photo est prête pour l\'identification',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Sélecteur d'organe
                  _buildOrganSelector(),
                  const SizedBox(height: 16),

                  // Sélecteur de localisation
                  _buildLocationSelector(),
                  const SizedBox(height: 20),

                  // Bouton principal : Identifier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isIdentifying ? null : _identifyPlant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isIdentifying
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Identifier la plante',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bouton secondaire : Reprendre une photo
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isIdentifying ? null : _retakePhoto,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Reprendre une photo',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
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
      ),
    );
  }

  /// Construit le sélecteur d'organe de la plante
  Widget _buildOrganSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qu\'est-ce qui est visible sur la photo ?',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _organs.entries.map((entry) {
            final isSelected = _selectedOrgan == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: _isIdentifying
                  ? null
                  : (selected) {
                      if (selected) {
                        setState(() => _selectedOrgan = entry.key);
                      }
                    },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              ),
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Construit le sélecteur de localisation
  Widget _buildLocationSelector() {
    final hasLocation = _latitude != null && _longitude != null;

    return InkWell(
      onTap: _isIdentifying ? null : _pickLocation,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasLocation ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasLocation 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasLocation ? Icons.location_on : Icons.location_off,
                color: hasLocation ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Localisation',
                    style: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasLocation
                        ? '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                        : 'Appuyez pour ajouter une localisation',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasLocation ? Icons.edit : Icons.add,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BOTTOM SHEET DES RÉSULTATS D'IDENTIFICATION
// =============================================================================

/// Bottom sheet affichant les résultats d'identification
class _IdentificationResultsSheet extends StatelessWidget {
  final List<PlantIdentification> identifications;

  const _IdentificationResultsSheet({
    required this.identifications,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Poignée de glissement
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Titre
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Résultats de l\'identification',
                  style: AppTypography.headlineSmall,
                ),
              ),
              
              // Sous-titre
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sélectionnez la plante correspondante',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Liste des résultats
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: identifications.length,
                  itemBuilder: (context, index) {
                    final plant = identifications[index];
                    return _IdentificationResultCard(
                      identification: plant,
                      onTap: () => Navigator.of(context).pop(plant),
                    );
                  },
                ),
              ),
              
              // Bouton annuler
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Annuler',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Carte d'un résultat d'identification
class _IdentificationResultCard extends StatelessWidget {
  final PlantIdentification identification;
  final VoidCallback onTap;

  const _IdentificationResultCard({
    required this.identification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône ou image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom commun
                    Text(
                      identification.displayName,
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Nom scientifique
                    Text(
                      identification.scientificName,
                      style: AppTypography.bodySmall.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Famille
                    Text(
                      'Famille: ${identification.family}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Score de confiance
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(identification.score),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  identification.scorePercentage,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retourne la couleur en fonction du score
  Color _getScoreColor(double score) {
    if (score >= 0.7) return AppColors.primary;
    if (score >= 0.4) return Colors.orange;
    return AppColors.error;
  }
}
