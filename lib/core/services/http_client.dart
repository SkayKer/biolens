import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Client HTTP personnalisé avec gestion des certificats SSL.
class CustomHttpClient {
  static http.Client? _client;

  /// Obtient un client HTTP avec contournement SSL pour le développement.
  /// 
  /// ⚠️ ATTENTION : Ne pas utiliser en production !
  static http.Client get client {
    if (_client != null) return _client!;

    // Créer un HttpClient avec contournement SSL
    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // En développement, accepter tous les certificats
        // ⚠️ ATTENTION : Ne jamais faire ça en production !
        return true;
      };

    _client = IOClient(ioClient);
    return _client!;
  }

  /// Ferme le client HTTP.
  static void close() {
    _client?.close();
    _client = null;
  }
}
