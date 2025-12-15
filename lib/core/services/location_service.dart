import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Résultat d'une recherche d'adresse.
class AddressResult {
  final String label;
  final double latitude;
  final double longitude;
  final String? city;
  final String? postcode;

  const AddressResult({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.city,
    this.postcode,
  });

  factory AddressResult.fromGeoJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    return AddressResult(
      label: properties['label'] as String? ?? 'Adresse inconnue',
      longitude: (coordinates[0] as num).toDouble(),
      latitude: (coordinates[1] as num).toDouble(),
      city: properties['city'] as String?,
      postcode: properties['postcode'] as String?,
    );
  }

  @override
  String toString() => label;
}

/// Position GPS simple.
class GpsPosition {
  final double latitude;
  final double longitude;

  const GpsPosition({
    required this.latitude,
    required this.longitude,
  });
}

/// Service de localisation.
/// 
/// Gère la récupération de la position GPS et la recherche d'adresses
/// via l'API adresse.data.gouv.fr.
class LocationService {
  /// Instance singleton
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// URL de l'API adresse.data.gouv.fr
  static const String _addressApiUrl = 'https://api-adresse.data.gouv.fr/search';

  /// Vérifie si le service de localisation est disponible et autorisé.
  Future<bool> isLocationAvailable() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Demande la permission de localisation.
  Future<bool> requestLocationPermission() async {
    // Vérifier si le service de localisation est activé
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Service de localisation désactivé');
      return false;
    }

    // Vérifier les permissions actuelles
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Permission de localisation refusée');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Permission de localisation refusée définitivement');
      return false;
    }

    return true;
  }

  /// Récupère la position GPS actuelle.
  /// 
  /// Retourne null si la localisation n'est pas disponible ou refusée.
  Future<GpsPosition?> getCurrentPosition() async {
    try {
      // Demander la permission
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return GpsPosition(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la position: $e');
      return null;
    }
  }

  /// Recherche des adresses correspondant à une requête.
  /// 
  /// Utilise l'API adresse.data.gouv.fr pour la France.
  Future<List<AddressResult>> searchAddress(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final uri = Uri.parse('$_addressApiUrl?q=${Uri.encodeComponent(query)}&limit=10');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];

        return features
            .map((f) => AddressResult.fromGeoJson(f as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('Erreur API adresse: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Erreur lors de la recherche d\'adresse: $e');
      return [];
    }
  }

  /// Obtient l'adresse à partir de coordonnées (reverse geocoding).
  Future<AddressResult?> reverseGeocode(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        'https://api-adresse.data.gouv.fr/reverse?lat=$latitude&lon=$longitude',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];

        if (features.isNotEmpty) {
          return AddressResult.fromGeoJson(features.first as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors du reverse geocoding: $e');
      return null;
    }
  }
}
