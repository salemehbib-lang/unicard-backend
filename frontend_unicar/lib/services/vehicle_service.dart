import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/token_storage.dart';

class VehicleService {
  Future<Map<String, dynamic>> recupererVehicules() async {
    try {
      final token = await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConfig.vehicules),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final donnees = _decoderReponse(response.body);

      if (response.statusCode == 200) {
        if (donnees is List) {
          return {
            'succes': true,
            'vehicules': donnees,
          };
        }

        if (donnees is Map<String, dynamic> &&
            donnees['results'] is List) {
          return {
            'succes': true,
            'vehicules': donnees['results'],
          };
        }

        return {
          'succes': false,
          'message': 'La liste des véhicules est invalide.',
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          messageParDefaut:
              'Impossible de récupérer les véhicules.',
        ),
      };
    } catch (_) {
      return {
        'succes': false,
        'message': 'Impossible de contacter le serveur Django.',
      };
    }
  }

  Future<Map<String, dynamic>> ajouterVehicule({
    required String marque,
    required String modele,
    required String immatriculation,
    required String couleur,
    required int nombrePlaces,
    required bool estActif,
  }) async {
    try {
      final token = await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConfig.vehicules),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'marque': marque.trim(),
          'modele': modele.trim(),
          'immatriculation': immatriculation.trim(),
          'couleur': couleur.trim(),
          'nombre_places': nombrePlaces,
          'est_actif': estActif,
        }),
      );

      final donnees = _decoderReponse(response.body);

      if (response.statusCode == 201) {
        return {
          'succes': true,
          'message': 'Le véhicule a été ajouté avec succès.',
          'vehicule': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          messageParDefaut:
              'Impossible d’ajouter le véhicule.',
        ),
      };
    } catch (_) {
      return {
        'succes': false,
        'message': 'Impossible de contacter le serveur Django.',
      };
    }
  }

  Future<Map<String, dynamic>> modifierVehicule({
    required int id,
    required String marque,
    required String modele,
    required String immatriculation,
    required String couleur,
    required int nombrePlaces,
    required bool estActif,
  }) async {
    try {
      final token = await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      final response = await http.patch(
        Uri.parse('${ApiConfig.vehicules}$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'marque': marque.trim(),
          'modele': modele.trim(),
          'immatriculation': immatriculation.trim(),
          'couleur': couleur.trim(),
          'nombre_places': nombrePlaces,
          'est_actif': estActif,
        }),
      );

      final donnees = _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'message': 'Le véhicule a été modifié avec succès.',
          'vehicule': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          messageParDefaut:
              'Impossible de modifier le véhicule.',
        ),
      };
    } catch (_) {
      return {
        'succes': false,
        'message': 'Impossible de contacter le serveur Django.',
      };
    }
  }

  Future<Map<String, dynamic>> supprimerVehicule({
    required int id,
  }) async {
    try {
      final token = await TokenStorage.recupererAccessToken();

      if (token == null || token.isEmpty) {
        return {
          'succes': false,
          'message': 'Session expirée. Veuillez vous reconnecter.',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.vehicules}$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        return {
          'succes': true,
          'message': 'Le véhicule a été supprimé avec succès.',
        };
      }

      final donnees = _decoderReponse(response.body);

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          messageParDefaut:
              'Impossible de supprimer le véhicule.',
        ),
      };
    } catch (_) {
      return {
        'succes': false,
        'message': 'Impossible de contacter le serveur Django.',
      };
    }
  }

  dynamic _decoderReponse(String corps) {
    if (corps.trim().isEmpty) {
      return {};
    }

    try {
      return jsonDecode(corps);
    } catch (_) {
      return {
        'detail': 'La réponse du serveur est invalide.',
      };
    }
  }

  String _extraireMessageErreur(
    dynamic donnees, {
    required String messageParDefaut,
  }) {
    if (donnees is Map<String, dynamic>) {
      if (donnees['detail'] != null) {
        return donnees['detail'].toString();
      }

      final erreurs = <String>[];

      donnees.forEach((champ, valeur) {
        final nomChamp = _nomChampLisible(champ);

        if (valeur is List) {
          for (final erreur in valeur) {
            erreurs.add(
              '$nomChamp : ${erreur.toString()}',
            );
          }
        } else if (valeur != null) {
          erreurs.add(
            '$nomChamp : ${valeur.toString()}',
          );
        }
      });

      if (erreurs.isNotEmpty) {
        return erreurs.join('\n');
      }
    }

    return messageParDefaut;
  }

  String _nomChampLisible(String champ) {
    switch (champ) {
      case 'marque':
        return 'Marque';
      case 'modele':
        return 'Modèle';
      case 'immatriculation':
        return 'Immatriculation';
      case 'couleur':
        return 'Couleur';
      case 'nombre_places':
        return 'Nombre de places';
      case 'est_actif':
        return 'État';
      default:
        return champ;
    }
  }
}