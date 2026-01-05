import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/saved_plant.dart';
import '../../core/services/local_storage_service.dart';
import 'widgets/plant_tile.dart';

/// Écran Herbier - Grille des plantes sauvegardées.
///
/// Affiche les plantes découvertes dans une grille de 2 colonnes.
/// Utilise les couleurs du thème pour s'adapter au mode sombre.
class HerbierScreen extends StatefulWidget {
  const HerbierScreen({super.key});

  @override
  State<HerbierScreen> createState() => _HerbierScreenState();
}

class _HerbierScreenState extends State<HerbierScreen> {
  /// Liste des plantes
  List<SavedPlant> _plants = [];

  /// Indique si les données sont en cours de chargement
  bool _isLoading = true;

  final LocalStorageService _storageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  /// Charge les plantes depuis la base de données.
  Future<void> _loadPlants() async {
    try {
      await _storageService.initialize();
      final plants = await _storageService.getAllPlants();
      if (mounted) {
        setState(() {
          _plants = plants;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Utiliser la couleur de fond du thème
      appBar: AppBar(
        title: const Text('Mon Herbier'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
          ? _buildEmptyState()
          : _buildPlantsGrid(),
    );
  }

  /// Affiche l'état vide quand il n'y a pas de plantes.
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_florist,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            Text(
              'Votre herbier est vide',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Scannez votre première plante pour commencer votre collection !',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Bouton d'action
            ElevatedButton.icon(
              onPressed: () => context.push('/scan'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner une plante'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la grille de plantes.
  Widget _buildPlantsGrid() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _loadPlants,
      color: colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // ═══════════════════════════════════════════════════════════════════
          // EN-TÊTE: Compteur de plantes
          // ═══════════════════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    '${_plants.length} plante${_plants.length > 1 ? 's' : ''} découverte${_plants.length > 1 ? 's' : ''}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Toggle vue grille/liste (optionnel)
                ],
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // GRILLE DE PLANTES
          // ═══════════════════════════════════════════════════════════════════
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Plus haut que large
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final plant = _plants[index];
                return PlantTile(
                  plant: plant,
                  onTap: () => context.push('/species/${plant.id}'),
                );
              }, childCount: _plants.length),
            ),
          ),

          // Espace en bas pour la nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  /// Affiche les options de filtre.
  void _showFilterOptions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre "Filtrer" en vert (couleur primary)
              Text(
                'Filtrer',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.sort, color: colorScheme.onSurfaceVariant),
                title: Text(
                  'Par date (récent)',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sortByDate(descending: true);
                },
              ),
              ListTile(
                leading: Icon(Icons.sort, color: colorScheme.onSurfaceVariant),
                title: Text(
                  'Par date (ancien)',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _sortByDate(descending: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite, color: colorScheme.error),
                title: Text(
                  'Favoris uniquement',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _filterFavorites();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.clear_all,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  'Tout afficher',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _loadPlants();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Trie par date.
  void _sortByDate({required bool descending}) {
    setState(() {
      _plants.sort(
        (a, b) => descending
            ? b.discoveryDate.compareTo(a.discoveryDate)
            : a.discoveryDate.compareTo(b.discoveryDate),
      );
    });
  }

  /// Filtre les favoris.
  Future<void> _filterFavorites() async {
    final favorites = await _storageService.getFavoritePlants();
    setState(() => _plants = favorites);
  }
}
