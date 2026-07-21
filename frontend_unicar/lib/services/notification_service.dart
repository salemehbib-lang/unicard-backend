import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/token_storage.dart';

class NotificationService {
  Future<Map<String, dynamic>> recupererNotifications() async {
    try {
      final token = await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.notifications),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      dynamic donnees;

      try {
        donnees = jsonDecode(response.body);
      } catch (_) {
        donnees = null;
      }

      if (response.statusCode == 200) {
        if (donnees is List) {
          return {'succes': true, 'notifications': donnees};
        }

        if (donnees is Map<String, dynamic>) {
          final resultats = donnees['results'];

          return {
            'succes': true,
            'notifications': resultats is List ? resultats : [],
          };
        }
      }

      return {
        'succes': false,
        'message': donnees is Map<String, dynamic>
            ? donnees['detail']?.toString() ??
                  donnees['message']?.toString() ??
                  'Impossible de récupérer les notifications.'
            : 'Impossible de récupérer les notifications.',
      };
    } catch (e) {
      return {
        'succes': false,
        'message': 'Erreur de connexion au serveur : $e',
      };
    }
  }

 Future<Map<String, dynamic>> marquerCommeLue(
  int notificationId,
) async {
  try {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null || token.isEmpty) {
      return {
        'succes': false,
        'message':
            'Session expirée. Veuillez vous reconnecter.',
      };
    }

    final url =
        '${ApiConfig.notifications}$notificationId/';

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'lue': true,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return {
        'succes': true,
        'message': 'Notification marquée comme lue.',
      };
    }

    return {
      'succes': false,
      'message':
          'Impossible de modifier la notification '
          '(code ${response.statusCode}) : ${response.body}',
    };
  } catch (e) {
    return {
      'succes': false,
      'message':
          'Erreur de connexion au serveur : $e',
    };
  }
}
}
