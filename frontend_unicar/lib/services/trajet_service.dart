import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/trajet.dart';
import '../utils/token_storage.dart';

class TrajetService {
  static const Duration _delaiMaximum =
      Duration(seconds: 20);

  Future<List<Trajet>> rechercherTrajets({
    required String depart,
    required String arrivee,
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    final lieuDepart = depart.trim();
    final lieuArrivee = arrivee.trim();

    final uri = Uri.parse(
      ApiConfig.trajets,
    ).replace(
      queryParameters: {
        if (lieuDepart.isNotEmpty)
          'lieu_depart': lieuDepart,
        if (lieuArrivee.isNotEmpty)
          'lieu_arrivee': lieuArrivee,
      },
    );

    try {
      final response = await http
          .get(
            uri,
            headers: _construireEntetes(
              token: token,
            ),
          )
          .timeout(_delaiMaximum);

      final donnees =
          _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return _convertirListeTrajets(
          donnees,
        );
      }

      throw Exception(
        _extraireMessageErreur(
          donnees,
          codeStatut: response.statusCode,
          messageParDefaut:
              'Impossible de récupérer les trajets.',
        ),
      );
    } on http.ClientException {
      throw Exception(
        'Impossible de contacter le serveur Django.',
      );
    } on FormatException {
      throw Exception(
        'La réponse du serveur est invalide.',
      );
    } catch (erreur) {
      throw Exception(
        _nettoyerMessageErreur(
          erreur,
          messageParDefaut:
              'Impossible de récupérer les trajets.',
        ),
      );
    }
  }

  Future<List<Trajet>> recupererTrajets() async {
    return rechercherTrajets(
      depart: '',
      arrivee: '',
    );
  }

  Future<Map<String, dynamic>> creerTrajet({
    required int vehiculeId,
    required String lieuDepart,
    required String lieuArrivee,
    required DateTime dateDepart,
    required String heureDepart,
    required int nombrePlacesDisponibles,
    required double prixParPlace,
    String description = '',
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null || token.trim().isEmpty) {
      return {
        'succes': false,
        'message':
            'Votre session a expiré. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.trajets),
            headers: _construireEntetes(
              token: token,
            ),
            body: jsonEncode({
              'vehicule': vehiculeId,
              'lieu_depart': lieuDepart.trim(),
              'lieu_arrivee': lieuArrivee.trim(),
              'date_depart':
                  _formaterDate(dateDepart),
              'heure_depart': heureDepart.trim(),
              'nombre_places_disponibles':
                  nombrePlacesDisponibles,
              'prix_par_place': prixParPlace,
              'description': description.trim(),
            }),
          )
          .timeout(_delaiMaximum);

      final donnees =
          _decoderReponse(response.body);

      if (response.statusCode == 201) {
        return {
          'succes': true,
          'message':
              'Le trajet a été créé avec succès.',
          'trajet': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          codeStatut: response.statusCode,
          messageParDefaut:
              'Impossible de créer le trajet.',
        ),
      };
    } on http.ClientException {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur Django.',
      };
    } on FormatException {
      return {
        'succes': false,
        'message':
            'La réponse du serveur est invalide.',
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': _nettoyerMessageErreur(
          erreur,
          messageParDefaut:
              'Impossible de créer le trajet.',
        ),
      };
    }
  }
  Future<List<Trajet>> recupererMesTrajets() async {
  final token =
      await TokenStorage.recupererAccessToken();

  if (token == null || token.trim().isEmpty) {
    throw Exception(
      'Votre session a expiré. Veuillez vous reconnecter.',
    );
  }

  try {
    final response = await http
        .get(
          Uri.parse(ApiConfig.mesTrajets),
          headers: _construireEntetes(
            token: token,
          ),
        )
        .timeout(_delaiMaximum);

    final donnees =
        _decoderReponse(response.body);

    if (response.statusCode == 200) {
      return _convertirListeTrajets(
        donnees,
      );
    }

    throw Exception(
      _extraireMessageErreur(
        donnees,
        codeStatut: response.statusCode,
        messageParDefaut:
            'Impossible de récupérer vos trajets.',
      ),
    );
  } on http.ClientException {
    throw Exception(
      'Impossible de contacter le serveur Django.',
    );
  } on FormatException {
    throw Exception(
      'La réponse du serveur est invalide.',
    );
  } catch (erreur) {
    throw Exception(
      _nettoyerMessageErreur(
        erreur,
        messageParDefaut:
            'Impossible de récupérer vos trajets.',
      ),
    );
  }
}

  Future<Map<String, dynamic>> modifierTrajet({
    required int trajetId,
    int? vehiculeId,
    String? lieuDepart,
    String? lieuArrivee,
    DateTime? dateDepart,
    String? heureDepart,
    int? nombrePlacesDisponibles,
    double? prixParPlace,
    String? description,
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null || token.trim().isEmpty) {
      return {
        'succes': false,
        'message':
            'Votre session a expiré. Veuillez vous reconnecter.',
      };
    }

    final corps = <String, dynamic>{};

    if (vehiculeId != null) {
      corps['vehicule'] = vehiculeId;
    }

    if (lieuDepart != null) {
      corps['lieu_depart'] =
          lieuDepart.trim();
    }

    if (lieuArrivee != null) {
      corps['lieu_arrivee'] =
          lieuArrivee.trim();
    }

    if (dateDepart != null) {
      corps['date_depart'] =
          _formaterDate(dateDepart);
    }

    if (heureDepart != null) {
      corps['heure_depart'] =
          heureDepart.trim();
    }

    if (nombrePlacesDisponibles != null) {
      corps['nombre_places_disponibles'] =
          nombrePlacesDisponibles;
    }

    if (prixParPlace != null) {
      corps['prix_par_place'] =
          prixParPlace;
    }

    if (description != null) {
      corps['description'] =
          description.trim();
    }

    if (corps.isEmpty) {
      return {
        'succes': false,
        'message':
            'Aucune modification n’a été fournie.',
      };
    }

    try {
      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.trajets}$trajetId/',
            ),
            headers: _construireEntetes(
              token: token,
            ),
            body: jsonEncode(corps),
          )
          .timeout(_delaiMaximum);

      final donnees =
          _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'message':
              'Le trajet a été modifié avec succès.',
          'trajet': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          codeStatut: response.statusCode,
          messageParDefaut:
              'Impossible de modifier le trajet.',
        ),
      };
    } on http.ClientException {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur Django.',
      };
    } on FormatException {
      return {
        'succes': false,
        'message':
            'La réponse du serveur est invalide.',
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': _nettoyerMessageErreur(
          erreur,
          messageParDefaut:
              'Impossible de modifier le trajet.',
        ),
      };
    }
  }

  Future<Map<String, dynamic>> supprimerTrajet({
    required int trajetId,
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null || token.trim().isEmpty) {
      return {
        'succes': false,
        'message':
            'Votre session a expiré. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http
          .delete(
            Uri.parse(
              '${ApiConfig.trajets}$trajetId/',
            ),
            headers: _construireEntetes(
              token: token,
            ),
          )
          .timeout(_delaiMaximum);

      if (response.statusCode == 204) {
        return {
          'succes': true,
          'message':
              'Le trajet a été supprimé avec succès.',
        };
      }

      final donnees =
          _decoderReponse(response.body);

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          codeStatut: response.statusCode,
          messageParDefaut:
              'Impossible de supprimer le trajet.',
        ),
      };
    } on http.ClientException {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur Django.',
      };
    } on FormatException {
      return {
        'succes': false,
        'message':
            'La réponse du serveur est invalide.',
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': _nettoyerMessageErreur(
          erreur,
          messageParDefaut:
              'Impossible de supprimer le trajet.',
        ),
      };
    }
  }

  Future<Map<String, dynamic>>
      changerEtatTrajet({
    required int trajetId,
    required String nouvelEtat,
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null || token.trim().isEmpty) {
      return {
        'succes': false,
        'message':
            'Votre session a expiré. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.trajets}$trajetId/etat/',
            ),
            headers: _construireEntetes(
              token: token,
            ),
            body: jsonEncode({
              'etat': nouvelEtat.trim(),
            }),
          )
          .timeout(_delaiMaximum);

      final donnees =
          _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'message': donnees is Map &&
                  donnees['message'] != null
              ? donnees['message'].toString()
              : 'L’état du trajet a été modifié avec succès.',
          'donnees': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          codeStatut: response.statusCode,
          messageParDefaut:
              'Impossible de modifier l’état du trajet.',
        ),
      };
    } on http.ClientException {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur Django.',
      };
    } on FormatException {
      return {
        'succes': false,
        'message':
            'La réponse du serveur est invalide.',
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': _nettoyerMessageErreur(
          erreur,
          messageParDefaut:
              'Impossible de modifier l’état du trajet.',
        ),
      };
    }
  }

  Future<Map<String, dynamic>>
      annulerTrajet({
    required int trajetId,
  }) async {
    final token =
        await TokenStorage.recupererAccessToken();

    if (token == null || token.trim().isEmpty) {
      return {
        'succes': false,
        'message':
            'Votre session a expiré. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http
          .patch(
            Uri.parse(
              '${ApiConfig.trajets}$trajetId/annuler/',
            ),
            headers: _construireEntetes(
              token: token,
            ),
            body: jsonEncode({}),
          )
          .timeout(_delaiMaximum);

      final donnees =
          _decoderReponse(response.body);

      if (response.statusCode == 200) {
        return {
          'succes': true,
          'message': donnees is Map &&
                  donnees['message'] != null
              ? donnees['message'].toString()
              : 'Le trajet a été annulé avec succès.',
          'donnees': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          codeStatut: response.statusCode,
          messageParDefaut:
              'Impossible d’annuler le trajet.',
        ),
      };
    } on http.ClientException {
      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur Django.',
      };
    } on FormatException {
      return {
        'succes': false,
        'message':
            'La réponse du serveur est invalide.',
      };
    } catch (erreur) {
      return {
        'succes': false,
        'message': _nettoyerMessageErreur(
          erreur,
          messageParDefaut:
              'Impossible d’annuler le trajet.',
        ),
      };
    }
  }

  Map<String, String> _construireEntetes({
    String? token,
  }) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null &&
          token.trim().isNotEmpty)
        'Authorization':
            'Bearer ${token.trim()}',
    };
  }

  dynamic _decoderReponse(
    String corps,
  ) {
    if (corps.trim().isEmpty) {
      return null;
    }

    return jsonDecode(corps);
  }

  List<Trajet> _convertirListeTrajets(
    dynamic donnees,
  ) {
    List<dynamic> listeBrute;

    if (donnees is List) {
      listeBrute = donnees;
    } else if (donnees is Map &&
        donnees['results'] is List) {
      listeBrute =
          donnees['results'] as List<dynamic>;
    } else {
      return [];
    }

    final trajets = <Trajet>[];

    for (final element in listeBrute) {
      if (element is Map) {
        final trajetJson =
            Map<String, dynamic>.from(
          element,
        );

        trajets.add(
          Trajet.fromJson(trajetJson),
        );
      }
    }

    return trajets;
  }

  String _formaterDate(
    DateTime date,
  ) {
    final annee =
        date.year.toString().padLeft(4, '0');

    final mois =
        date.month.toString().padLeft(2, '0');

    final jour =
        date.day.toString().padLeft(2, '0');

    return '$annee-$mois-$jour';
  }

  String _nettoyerMessageErreur(
    Object erreur, {
    required String messageParDefaut,
  }) {
    final message = erreur
        .toString()
        .replaceFirst('Exception: ', '')
        .trim();

    if (message.isEmpty) {
      return messageParDefaut;
    }

    return message;
  }

  String _extraireMessageErreur(
    dynamic donnees, {
    required int codeStatut,
    required String messageParDefaut,
  }) {
    if (donnees is Map) {
      if (donnees['detail'] != null) {
        return donnees['detail'].toString();
      }

      if (donnees['message'] != null) {
        return donnees['message'].toString();
      }

      if (donnees['non_field_errors']
          is List) {
        final erreurs =
            donnees['non_field_errors']
                as List;

        if (erreurs.isNotEmpty) {
          return erreurs.first.toString();
        }
      }

      final erreurs = <String>[];

      for (final entree
          in donnees.entries) {
        final nomChamp = _nomChampLisible(
          entree.key.toString(),
        );

        final valeur = entree.value;

        if (valeur is List) {
          for (final erreur in valeur) {
            erreurs.add(
              '$nomChamp : ${erreur.toString()}',
            );
          }
        } else if (valeur != null &&
            valeur.toString().trim().isNotEmpty) {
          erreurs.add(
            '$nomChamp : ${valeur.toString()}',
          );
        }
      }

      if (erreurs.isNotEmpty) {
        return erreurs.join('\n');
      }
    }

    switch (codeStatut) {
      case 400:
        return messageParDefaut;

      case 401:
        return 'Votre session a expiré. Veuillez vous reconnecter.';

      case 403:
        return 'Vous n’avez pas l’autorisation d’effectuer cette action.';

      case 404:
        return 'Le trajet demandé est introuvable.';

      case 500:
        return 'Une erreur interne est survenue sur le serveur.';

      default:
        return '$messageParDefaut Code : $codeStatut';
    }
  }

  String _nomChampLisible(
    String champ,
  ) {
    switch (champ) {
      case 'vehicule':
        return 'Véhicule';

      case 'lieu_depart':
        return 'Lieu de départ';

      case 'lieu_arrivee':
        return 'Lieu d’arrivée';

      case 'date_depart':
        return 'Date de départ';

      case 'heure_depart':
        return 'Heure de départ';

      case 'nombre_places_disponibles':
        return 'Nombre de places';

      case 'prix_par_place':
        return 'Prix par place';

      case 'description':
        return 'Description';

      case 'etat':
        return 'État du trajet';

      case 'statut':
        return 'Statut du trajet';

      default:
        return champ;
    }
  }
}