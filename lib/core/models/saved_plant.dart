import 'package:isar/isar.dart';

part 'saved_plant.g.dart';

/// Modèle de plante sauvegardée dans l'herbier local.
/// 
/// Utilise Isar pour la persistance des données.
@collection
class SavedPlant {
  /// Identifiant unique auto-généré
  Id id = Isar.autoIncrement;

  /// Nom scientifique (latin) de la plante
  late String scientificName;

  /// Nom commun de la plante
  late String commonName;

  /// Famille botanique
  String? family;

  /// Chemin local vers l'image de la plante
  late String imagePath;

  /// URL de l'image depuis l'API (si disponible)
  String? imageUrl;

  /// Description de la plante
  String? description;

  /// Score de fiabilité de l'identification (0.0 - 1.0)
  double? identificationScore;

  /// Date de découverte/scan
  @Index()
  late DateTime discoveryDate;

  /// Latitude GPS de la découverte
  double? latitude;

  /// Longitude GPS de la découverte
  double? longitude;

  /// Indique si la plante est en favoris
  @Index()
  bool isFavorite = false;

  /// Constructeur par défaut
  SavedPlant();

  /// Constructeur avec paramètres
  SavedPlant.create({
    required this.scientificName,
    required this.commonName,
    required this.imagePath,
    this.family,
    this.imageUrl,
    this.description,
    this.identificationScore,
    this.latitude,
    this.longitude,
    this.isFavorite = false,
  }) : discoveryDate = DateTime.now();

  @override
  String toString() {
    return 'SavedPlant(id: $id, commonName: $commonName, scientificName: $scientificName)';
  }
}
