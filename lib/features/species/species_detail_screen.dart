import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/saved_plant.dart';
import '../../core/services/local_storage_service.dart';

/// Écran de détail d'une espèce identifiée.
///
/// Affiche la photo en grand avec une carte glissante contenant les informations.
/// Utilise les couleurs du thème pour s'adapter au mode sombre.
class SpeciesDetailScreen extends StatefulWidget {
  /// ID de la plante dans la base de données
  final String plantId;

  const SpeciesDetailScreen({super.key, required this.plantId});

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  /// Plante chargée depuis la base
  SavedPlant? _plant;

  /// Indique si les données sont en cours de chargement
  bool _isLoading = true;

  /// Indique si la plante est en favori
  bool _isFavorite = false;

  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadPlant();
  }

  /// Charge les données de la plante.
  Future<void> _loadPlant() async {
    try {
      final id = int.tryParse(widget.plantId);
      if (id != null) {
        final plant = await _storageService.getPlantById(id);
        if (mounted) {
          setState(() {
            _plant = plant;
            _isFavorite = plant?.isFavorite ?? false;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Bascule le statut favori.
  Future<void> _toggleFavorite() async {
    if (_plant == null) return;

    setState(() => _isFavorite = !_isFavorite);
    await _storageService.toggleFavorite(_plant!.id);
  }

  /// Partage les informations de la plante.
  Future<void> _sharePlant() async {
    if (_plant == null) return;

    final text =
        '''
🌿 ${_plant!.commonName}
📖 ${_plant!.scientificName}
${_plant!.family != null ? '🏷️ Famille: ${_plant!.family}' : ''}
${_plant!.description ?? ''}

Découvert avec BioLens 🔬
''';

    await Share.share(text, subject: _plant!.commonName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_plant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Plante non trouvée')),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // CONTENU SCROLLABLE
          // ═══════════════════════════════════════════════════════════════════
          CustomScrollView(
            slivers: [
              // ═════════════════════════════════════════════════════════════════
              // SLIVER APP BAR avec image
              // ═════════════════════════════════════════════════════════════════
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                leading: _buildBackButton(),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderImage(colorScheme),
                ),
              ),

              // ═════════════════════════════════════════════════════════════════
              // CARTE D'INFORMATIONS
              // ═════════════════════════════════════════════════════════════════
              SliverToBoxAdapter(child: _buildInfoCard(theme, colorScheme)),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════════
          // BOUTONS D'ACTION FLOTTANTS
          // ═══════════════════════════════════════════════════════════════════
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildActionButtons(colorScheme),
          ),
        ],
      ),
    );
  }

  /// Bouton retour stylisé.
  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Vérifier s'il y a quelque chose à pop, sinon aller à l'herbier
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/herbier');
            }
          },
        ),
      ),
    );
  }

  /// Image d'en-tête.
  Widget _buildHeaderImage(ColorScheme colorScheme) {
    final imagePath = _plant!.imagePath;
    final imageFile = File(imagePath);

    if (imageFile.existsSync()) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Placeholder si l'image n'existe pas
    return Container(
      color: colorScheme.secondary,
      child: Center(
        child: Icon(
          Icons.local_florist,
          size: 80,
          color: colorScheme.onSecondary,
        ),
      ),
    );
  }

  /// Carte d'informations avec coins arrondis en haut.
  Widget _buildInfoCard(ThemeData theme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;

    return Transform.translate(
      offset: const Offset(0, -24), // Chevauche légèrement l'image
      child: Container(
        constraints: const BoxConstraints(minHeight: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═════════════════════════════════════════════════════════════════
              // NOM COMMUN (Headline)
              // ═════════════════════════════════════════════════════════════════
              Text(
                _plant!.commonName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),

              // ═════════════════════════════════════════════════════════════════
              // NOM SCIENTIFIQUE (Italique)
              // ═════════════════════════════════════════════════════════════════
              Text(
                _plant!.scientificName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // ═════════════════════════════════════════════════════════════════
              // SCORE DE FIABILITÉ
              // ═════════════════════════════════════════════════════════════════
              if (_plant!.identificationScore != null)
                _buildScoreBadge(
                  _plant!.identificationScore!,
                  colorScheme,
                  theme,
                ),

              const SizedBox(height: 24),

              // ═════════════════════════════════════════════════════════════════
              // FAMILLE BOTANIQUE
              // ═════════════════════════════════════════════════════════════════
              if (_plant!.family != null) ...[
                _buildInfoRow(
                  Icons.category,
                  'Famille',
                  _plant!.family!,
                  colorScheme,
                  theme,
                ),
                const SizedBox(height: 12),
              ],

              // ═════════════════════════════════════════════════════════════════
              // DATE DE DÉCOUVERTE
              // ═════════════════════════════════════════════════════════════════
              _buildInfoRow(
                Icons.calendar_today,
                'Découvert le',
                _formatDate(_plant!.discoveryDate),
                colorScheme,
                theme,
              ),
              const SizedBox(height: 12),

              // ═════════════════════════════════════════════════════════════════
              // LOCALISATION
              // ═════════════════════════════════════════════════════════════════
              if (_plant!.latitude != null && _plant!.longitude != null)
                _buildInfoRow(
                  Icons.location_on,
                  'Position',
                  '${_plant!.latitude!.toStringAsFixed(4)}, ${_plant!.longitude!.toStringAsFixed(4)}',
                  colorScheme,
                  theme,
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // ═════════════════════════════════════════════════════════════════
              // DESCRIPTION
              // ═════════════════════════════════════════════════════════════════
              Text(
                'Description',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _plant!.description ??
                    'Aucune description disponible pour cette espèce. '
                        'Vous pouvez rechercher plus d\'informations sur Wikipedia ou dans un guide botanique.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              // Espace pour les boutons flottants
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Badge affichant le score de fiabilité.
  Widget _buildScoreBadge(
    double score,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final percentage = (score * 100).toStringAsFixed(0);
    final color = score >= 0.8
        ? colorScheme.primary
        : score >= 0.5
        ? Colors.orange
        : colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            'Fiabilité: $percentage%',
            style: theme.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  /// Ligne d'information avec icône.
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Boutons d'action (favori, partage et suppression).
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton Supprimer
        FloatingActionButton(
          heroTag: 'delete',
          onPressed: _confirmDelete,
          backgroundColor: colorScheme.surface,
          child: Icon(Icons.delete_outline, color: colorScheme.error),
        ),
        const SizedBox(height: 12),
        // Bouton Favori
        FloatingActionButton(
          heroTag: 'favorite',
          onPressed: _toggleFavorite,
          backgroundColor: _isFavorite
              ? colorScheme.error
              : colorScheme.surface,
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.white : colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        // Bouton Partage
        FloatingActionButton(
          heroTag: 'share',
          onPressed: _sharePlant,
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.share, color: colorScheme.onPrimary),
        ),
      ],
    );
  }

  /// Affiche une popup de confirmation avant la suppression.
  Future<void> _confirmDelete() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            Text(
              'Supprimer la plante',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${_plant!.commonName}" de votre herbier ?\n\nCette action est irréversible.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Supprimer',
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deletePlant();
    }
  }

  /// Supprime la plante et retourne à l'herbier.
  Future<void> _deletePlant() async {
    if (_plant == null) return;

    final colorScheme = Theme.of(context).colorScheme;

    try {
      // Supprimer l'image locale si elle existe
      final imageFile = File(_plant!.imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      // Supprimer de la base de données
      await _storageService.deletePlant(_plant!.id);

      if (mounted) {
        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_plant!.commonName} a été supprimé'),
            backgroundColor: colorScheme.primary,
          ),
        );

        // Retourner à l'herbier
        context.go('/herbier');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  /// Formate une date en français.
  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
