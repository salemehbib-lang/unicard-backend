import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/admin_utilisateur.dart';
import '../utils/token_storage.dart';

class AdminService {
  Future<Map<String, dynamic>>
      recupererStatistiques() async {
    try {
      final token =
          await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': (
            'Session expirée. '
            'Veuillez vous reconnecter.'
          ),
        };
      }

      final response = await http.get(
        Uri.parse(
          ApiConfig.adminStatistiques,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final donnees = _decoderReponse(
        response.body,
      );

      if (response.statusCode == 200 &&
          donnees is Map<String, dynamic>) {
        return {
          'succes': true,
          'statistiques': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessage(
          donnees,
          'Impossible de récupérer les statistiques.',
        ),
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': (
          'Erreur de connexion au serveur : '
          '$erreur'
        ),
      };
    }
  }

  Future<Map<String, dynamic>>
      recupererUtilisateurs({
    String? role,
    bool? estBloque,
  }) async {
    try {
      final token =
          await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': (
            'Session expirée. '
            'Veuillez vous reconnecter.'
          ),
        };
      }

      final parametres = <String, String>{};

      if (role != null &&
          role.trim().isNotEmpty) {
        parametres['role'] = role.trim();
      }

      if (estBloque != null) {
        parametres['est_bloque'] =
            estBloque.toString();
      }

      final uri = Uri.parse(
        ApiConfig.adminUtilisateurs,
      ).replace(
        queryParameters: parametres.isEmpty
            ? null
            : parametres,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final donnees = _decoderReponse(
        response.body,
      );

      if (response.statusCode == 200) {
        final listeJson =
            _extraireListe(donnees);

        final utilisateurs = listeJson
            .whereType<Map>()
            .map(
              (element) =>
                  AdminUtilisateur.fromJson(
                Map<String, dynamic>.from(
                  element,
                ),
              ),
            )
            .toList();

        return {
          'succes': true,
          'utilisateurs': utilisateurs,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessage(
          donnees,
          'Impossible de récupérer les utilisateurs.',
        ),
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': (
          'Erreur de connexion au serveur : '
          '$erreur'
        ),
      };
    }
  }

  Future<Map<String, dynamic>>
      recupererDetailUtilisateur({
    required int utilisateurId,
  }) async {
    try {
      final token =
          await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': (
            'Session expirée. '
            'Veuillez vous reconnecter.'
          ),
        };
      }

      final response = await http.get(
        Uri.parse(
          ApiConfig.adminDetailUtilisateur(
            utilisateurId,
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final donnees = _decoderReponse(
        response.body,
      );

      if (response.statusCode == 200 &&
          donnees is Map<String, dynamic>) {
        return {
          'succes': true,
          'utilisateur':
              AdminUtilisateur.fromJson(
            donnees,
          ),
        };
      }

      return {
        'succes': false,
        'message': _extraireMessage(
          donnees,
          'Utilisateur introuvable.',
        ),
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': (
          'Erreur de connexion au serveur : '
          '$erreur'
        ),
      };
    }
  }

  Future<Map<String, dynamic>>
      bloquerUtilisateur({
    required int utilisateurId,
  }) async {
    return _modifierBlocage(
      url: ApiConfig.adminBloquerUtilisateur(
        utilisateurId,
      ),
      messageParDefaut: (
        'Impossible de bloquer cet utilisateur.'
      ),
    );
  }

  Future<Map<String, dynamic>>
      debloquerUtilisateur({
    required int utilisateurId,
  }) async {
    return _modifierBlocage(
      url: ApiConfig.adminDebloquerUtilisateur(
        utilisateurId,
      ),
      messageParDefaut: (
        'Impossible de débloquer cet utilisateur.'
      ),
    );
  }

  Future<Map<String, dynamic>>
      _modifierBlocage({
    required String url,
    required String messageParDefaut,
  }) async {
    try {
      final token =
          await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': (
            'Session expirée. '
            'Veuillez vous reconnecter.'
          ),
        };
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      final donnees = _decoderReponse(
        response.body,
      );

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'message': _extraireMessage(
            donnees,
            'Modification effectuée avec succès.',
          ),
          'donnees': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessage(
          donnees,
          messageParDefaut,
        ),
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': (
          'Erreur de connexion au serveur : '
          '$erreur'
        ),
      };
    }
  }

  dynamic _decoderReponse(
    String corps,
  ) {
    if (corps.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(corps);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _extraireListe(
    dynamic donnees,
  ) {
    if (donnees is List) {
      return donnees;
    }

    if (donnees is Map<String, dynamic>) {
      final resultats = donnees['results'];

      if (resultats is List) {
        return resultats;
      }
    }

    return [];
  }

  String _extraireMessage(
    dynamic donnees,
    String messageParDefaut,
  ) {
    if (donnees is Map<String, dynamic>) {
      final message =
          donnees['message'] ??
          donnees['detail'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return messageParDefaut;
  }
}