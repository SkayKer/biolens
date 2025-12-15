import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../models/plant_identification.dart';

/// Service d'identification de plantes via l'API PlantNet.
/// 
/// Gère le redimensionnement des images et l'appel à l'API.
class PlantApiService {
  /// URL de base de l'API PlantNet
  static const String _baseUrl = 'https://my-api.plantnet.org/v2/identify/all';

  /// Clé API PlantNet
  /// TODO: Remplacer par votre clé API PlantNet
  static const String _apiKey = 'YOUR_PLANTNET_API_KEY';

  /// Taille maximale de l'image en pixels
  static const int _maxImageSize = 1024;

  /// Instance singleton
  static final PlantApiService _instance = PlantApiService._internal();
  factory PlantApiService() => _instance;
  PlantApiService._internal();

  /// Identifie une plante à partir d'une image.
  /// 
  /// [imageFile] : Le fichier image à analyser.
  /// [organs] : Les organes visibles sur l'image (leaf, flower, fruit, bark).
  /// 
  /// Retourne une liste d'identifications possibles triées par score.
  Future<List<PlantIdentification>> identify(
    File imageFile, {
    List<String> organs = const ['leaf'],
  }) async {
    try {
      // 1. Redimensionner l'image
      final resizedImage = await _resizeImage(imageFile);
      
      // 2. Préparer la requête multipart
      final uri = Uri.parse('$_baseUrl?api-key=$_apiKey');
      final request = http.MultipartRequest('POST', uri);
      
      // Ajouter l'image
      request.files.add(
        http.MultipartFile.fromBytes(
          'images',
          resizedImage,
          filename: 'plant.jpg',
        ),
      );
      
      // Ajouter les organes
      for (final organ in organs) {
        request.fields['organs'] = organ;
      }
      
      // 3. Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return PlantIdentification.fromPlantNetResponse(jsonData);
      } else {
        throw PlantApiException(
          'Erreur API: ${response.statusCode}',
          response.body,
        );
      }
    } catch (e) {
      if (e is PlantApiException) rethrow;
      throw PlantApiException('Erreur lors de l\'identification', e.toString());
    }
  }

  /// Redimensionne une image pour économiser la bande passante.
  /// 
  /// L'image est redimensionnée à un maximum de [_maxImageSize] pixels
  /// sur son plus grand côté tout en conservant le ratio.
  Future<Uint8List> _resizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw PlantApiException('Impossible de décoder l\'image', '');
    }
    
    // Calculer les nouvelles dimensions
    int newWidth, newHeight;
    if (image.width > image.height) {
      if (image.width <= _maxImageSize) {
        return bytes; // Pas besoin de redimensionner
      }
      newWidth = _maxImageSize;
      newHeight = (image.height * _maxImageSize / image.width).round();
    } else {
      if (image.height <= _maxImageSize) {
        return bytes; // Pas besoin de redimensionner
      }
      newHeight = _maxImageSize;
      newWidth = (image.width * _maxImageSize / image.height).round();
    }
    
    // Redimensionner
    final resized = img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
    
    // Encoder en JPEG avec qualité 85%
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }

  /// Sauvegarde une image localement et retourne le chemin.
  Future<String> saveImageLocally(Uint8List imageBytes, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final plantsDir = Directory('${directory.path}/plants');
    
    if (!await plantsDir.exists()) {
      await plantsDir.create(recursive: true);
    }
    
    final file = File('${plantsDir.path}/$filename');
    await file.writeAsBytes(imageBytes);
    
    return file.path;
  }
}

/// Exception personnalisée pour les erreurs de l'API.
class PlantApiException implements Exception {
  final String message;
  final String details;

  PlantApiException(this.message, this.details);

  @override
  String toString() => 'PlantApiException: $message\nDétails: $details';
}
