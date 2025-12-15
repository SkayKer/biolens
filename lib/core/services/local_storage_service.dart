import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/saved_plant.dart';

/// Service de stockage local utilisant Isar.
/// 
/// Gère la persistance des plantes sauvegardées dans l'herbier.
class LocalStorageService {
  /// Instance Isar
  late Isar _isar;

  /// Indique si le service est initialisé
  bool _isInitialized = false;

  /// Instance singleton
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Initialise la base de données Isar.
  /// 
  /// Doit être appelé au démarrage de l'application.
  Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [SavedPlantSchema],
      directory: dir.path,
    );
    _isInitialized = true;
  }

  /// Vérifie que le service est initialisé.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('LocalStorageService n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OPÉRATIONS CRUD
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sauvegarde une plante dans l'herbier.
  Future<int> savePlant(SavedPlant plant) async {
    _ensureInitialized();
    return _isar.writeTxn(() => _isar.savedPlants.put(plant));
  }

  /// Récupère toutes les plantes de l'herbier.
  Future<List<SavedPlant>> getAllPlants() async {
    _ensureInitialized();
    return _isar.savedPlants.where().sortByDiscoveryDateDesc().findAll();
  }

  /// Récupère une plante par son ID.
  Future<SavedPlant?> getPlantById(int id) async {
    _ensureInitialized();
    return _isar.savedPlants.get(id);
  }

  /// Récupère les plantes favorites.
  Future<List<SavedPlant>> getFavoritePlants() async {
    _ensureInitialized();
    return _isar.savedPlants
        .filter()
        .isFavoriteEqualTo(true)
        .sortByDiscoveryDateDesc()
        .findAll();
  }

  /// Met à jour le statut favori d'une plante.
  Future<void> toggleFavorite(int id) async {
    _ensureInitialized();
    await _isar.writeTxn(() async {
      final plant = await _isar.savedPlants.get(id);
      if (plant != null) {
        plant.isFavorite = !plant.isFavorite;
        await _isar.savedPlants.put(plant);
      }
    });
  }

  /// Supprime une plante de l'herbier.
  Future<bool> deletePlant(int id) async {
    _ensureInitialized();
    return _isar.writeTxn(() => _isar.savedPlants.delete(id));
  }

  /// Supprime toutes les plantes de l'herbier.
  Future<void> deleteAllPlants() async {
    _ensureInitialized();
    await _isar.writeTxn(() => _isar.savedPlants.clear());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATISTIQUES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Retourne le nombre total de plantes dans l'herbier.
  Future<int> getPlantCount() async {
    _ensureInitialized();
    return _isar.savedPlants.count();
  }

  /// Retourne la dernière plante découverte.
  Future<SavedPlant?> getLastDiscovery() async {
    _ensureInitialized();
    return _isar.savedPlants.where().sortByDiscoveryDateDesc().findFirst();
  }

  /// Retourne les plantes avec coordonnées GPS pour la carte.
  Future<List<SavedPlant>> getPlantsWithLocation() async {
    _ensureInitialized();
    return _isar.savedPlants
        .filter()
        .latitudeIsNotNull()
        .and()
        .longitudeIsNotNull()
        .findAll();
  }

  /// Stream des plantes pour les mises à jour en temps réel.
  Stream<List<SavedPlant>> watchAllPlants() {
    _ensureInitialized();
    return _isar.savedPlants.where().sortByDiscoveryDateDesc().watch(fireImmediately: true);
  }

  /// Ferme la base de données.
  Future<void> close() async {
    if (_isInitialized) {
      await _isar.close();
      _isInitialized = false;
    }
  }
}
