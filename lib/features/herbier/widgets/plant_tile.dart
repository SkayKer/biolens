import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/models/saved_plant.dart';

/// Tuile représentant une plante dans la grille de l'herbier.
///
/// Affiche l'image avec un dégradé et le nom en overlay.
/// Utilise les couleurs du thème pour s'adapter au mode sombre.
class PlantTile extends StatelessWidget {
  /// Données de la plante
  final SavedPlant plant;

  /// Callback au tap
  final VoidCallback? onTap;

  const PlantTile({super.key, required this.plant, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ═══════════════════════════════════════════════════════════════
              // IMAGE DE FOND
              // ═══════════════════════════════════════════════════════════════
              _buildImage(colorScheme),

              // ═══════════════════════════════════════════════════════════════
              // DÉGRADÉ OVERLAY
              // ═══════════════════════════════════════════════════════════════
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════════════════
              // BADGE FAVORI
              // ═══════════════════════════════════════════════════════════════
              if (plant.isFavorite)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: colorScheme.error,
                      size: 16,
                    ),
                  ),
                ),

              // ═══════════════════════════════════════════════════════════════
              // INFORMATIONS TEXTE
              // ═══════════════════════════════════════════════════════════════
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nom commun
                    Text(
                      plant.commonName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Nom scientifique
                    Text(
                      plant.scientificName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'image de la plante.
  Widget _buildImage(ColorScheme colorScheme) {
    final imageFile = File(plant.imagePath);

    if (imageFile.existsSync()) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(colorScheme),
      );
    }

    return _buildPlaceholder(colorScheme);
  }

  /// Placeholder si l'image n'est pas disponible.
  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.secondary,
      child: Center(
        child: Icon(
          Icons.local_florist,
          size: 48,
          color: colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
