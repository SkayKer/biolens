/// Résultat d'identification d'une plante via l'API.
/// 
/// Contient les informations retournées par PlantNet ou autre API d'identification.
class PlantIdentification {
  /// Nom scientifique (latin) de la plante
  final String scientificName;

  /// Liste des noms communs dans différentes langues
  final List<String> commonNames;

  /// Score de fiabilité de l'identification (0.0 - 1.0)
  final double score;

  /// Famille botanique
  final String family;

  /// Genre botanique
  final String? genus;

  /// URL de l'image de référence
  final String? imageUrl;

  /// Description de la plante (si disponible)
  final String? description;

  const PlantIdentification({
    required this.scientificName,
    required this.commonNames,
    required this.score,
    required this.family,
    this.genus,
    this.imageUrl,
    this.description,
  });

  /// Retourne le premier nom commun ou le nom scientifique si aucun n'est disponible
  String get displayName => commonNames.isNotEmpty ? commonNames.first : scientificName;

  /// Retourne le score en pourcentage
  String get scorePercentage => '${(score * 100).toStringAsFixed(1)}%';

  /// Crée une instance depuis le JSON de l'API PlantNet
  factory PlantIdentification.fromPlantNetJson(Map<String, dynamic> json) {
    final species = json['species'] as Map<String, dynamic>;
    final commonNamesMap = species['commonNames'] as List<dynamic>? ?? [];
    
    return PlantIdentification(
      scientificName: species['scientificNameWithoutAuthor'] as String? ?? 
                      species['scientificName'] as String? ?? 
                      'Inconnu',
      commonNames: commonNamesMap.map((e) => e.toString()).toList(),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      family: (species['family'] as Map<String, dynamic>?)?['scientificName'] as String? ?? 'Inconnue',
      genus: (species['genus'] as Map<String, dynamic>?)?['scientificName'] as String?,
      imageUrl: null, // À récupérer séparément si nécessaire
    );
  }

  /// Crée une liste d'identifications depuis la réponse complète de PlantNet
  static List<PlantIdentification> fromPlantNetResponse(Map<String, dynamic> response) {
    final results = response['results'] as List<dynamic>? ?? [];
    return results
        .map((r) => PlantIdentification.fromPlantNetJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() {
    return 'PlantIdentification(scientificName: $scientificName, score: $scorePercentage)';
  }
}
