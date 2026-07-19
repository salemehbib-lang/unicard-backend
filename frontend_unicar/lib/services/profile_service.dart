import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/token_storage.dart';

class ProfileService {
  final String baseUrl;

  ProfileService({
    this.baseUrl = 'http://127.0.0.1:8000/api',
  });

  Future<Map<String, dynamic>> recupererProfil() async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null) {
      return {
        'succes': false,
        'message':
            'Session expirée. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profil/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'profil': data,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(data),
      };
    } catch (_) {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur.',
      };
    }
  }

  Future<Map<String, dynamic>> modifierProfil({
    required String firstName,
    required String lastName,
    required String email,
    required String telephone,
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null) {
      return {
        'succes': false,
        'message':
            'Session expirée. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/profil/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'email': email.trim(),
          'telephone': telephone.trim(),
        }),
      );

      final data = _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'profil': data,
          'message':
              'Profil modifié avec succès.',
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(data),
      };
    } catch (_) {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur.',
      };
    }
  }

  Future<Map<String, dynamic>>
      changerMotDePasse({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
    required String confirmationMotDePasse,
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null) {
      return {
        'succes': false,
        'message':
            'Session expirée. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http.patch(
        Uri.parse(
          '$baseUrl/auth/changer-mot-de-passe/',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ancien_mot_de_passe':
              ancienMotDePasse,
          'nouveau_mot_de_passe':
              nouveauMotDePasse,
          'confirmation_mot_de_passe':
              confirmationMotDePasse,
        }),
      );

      final data = _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'message':
              data is Map<String, dynamic>
                  ? data['message']?.toString() ??
                      'Mot de passe modifié avec succès.'
                  : 'Mot de passe modifié avec succès.',
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(data),
      };
    } catch (_) {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur.',
      };
    }
  }

  dynamic _decoderReponse(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return {
        'detail':
            'La réponse du serveur est invalide.',
      };
    }
  }

  String _extraireMessageErreur(
    dynamic data,
  ) {
    if (data is List && data.isNotEmpty) {
      return _extraireMessageErreur(
        data.first,
      );
    }

    if (data is Map) {
      const champsPrioritaires = [
        'ancien_mot_de_passe',
        'nouveau_mot_de_passe',
        'confirmation_mot_de_passe',
        'email',
        'telephone',
        'non_field_errors',
        'detail',
        'message',
      ];

      for (final champ in champsPrioritaires) {
        if (data.containsKey(champ)) {
          return _extraireMessageErreur(
            data[champ],
          );
        }
      }

      for (final value in data.values) {
        final message =
            _extraireMessageErreur(value);

        if (message !=
            'Une erreur est survenue.') {
          return message;
        }
      }
    }

    if (data is String &&
        data.trim().isNotEmpty) {
      return data;
    }

    return 'Une erreur est survenue.';
  }
}