import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/token_storage.dart';

class AuthService {
  Future<Map<String, dynamic>> connexion({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.connexion),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
        }),
      );

      final donnees = _decoderReponse(response.body);

      if (response.statusCode == 200) {
        final utilisateurBrut = donnees['utilisateur'];

        if (utilisateurBrut == null || utilisateurBrut is! Map) {
          return {
            'succes': false,
            'message':
                'Les informations de l’utilisateur sont absentes.',
          };
        }

        final utilisateur =
            Map<String, dynamic>.from(utilisateurBrut);

        final accessToken =
            donnees['access']?.toString() ?? '';

        final refreshToken =
            donnees['refresh']?.toString() ?? '';

        if (accessToken.isEmpty || refreshToken.isEmpty) {
          return {
            'succes': false,
            'message':
                'Les jetons de connexion sont absents.',
          };
        }

        final idUtilisateur =
            _convertirEntier(utilisateur['id']);

        final role =
            utilisateur['role']?.toString().trim() ?? '';

        if (idUtilisateur == null) {
          return {
            'succes': false,
            'message':
                'L’identifiant de l’utilisateur est invalide.',
          };
        }

        if (role.isEmpty) {
          return {
            'succes': false,
            'message':
                'Le rôle de l’utilisateur est absent dans la réponse du serveur.',
          };
        }

        debugPrint(
          'Utilisateur reçu du backend : $utilisateur',
        );

        debugPrint(
          'Rôle reçu du backend : $role',
        );

        await TokenStorage.enregistrerTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        await TokenStorage.enregistrerUtilisateur(
          id: idUtilisateur,
          username:
              utilisateur['username']?.toString() ?? '',
          email:
              utilisateur['email']?.toString() ?? '',
          telephone:
              utilisateur['telephone']?.toString() ?? '',
          role: role,
        );

        return {
          'succes': true,
          'message': 'Connexion réussie.',
          'utilisateur': utilisateur,
          'role': role,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          messageParDefaut:
              'Nom d’utilisateur ou mot de passe incorrect.',
        ),
      };
    } catch (erreur) {
      debugPrint(
        'Erreur pendant la connexion : $erreur',
      );

      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur Django.',
      };
    }
  }

  Future<Map<String, dynamic>> inscription({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String telephone,
    required String role,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final roleNettoye =
          role.trim().toLowerCase();

      if (roleNettoye != 'passager' &&
          roleNettoye != 'conducteur') {
        return {
          'succes': false,
          'message':
              'Le rôle sélectionné est invalide.',
        };
      }

      debugPrint(
        'Rôle envoyé pendant l’inscription : $roleNettoye',
      );

      final response = await http.post(
        Uri.parse(ApiConfig.inscription),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username.trim(),
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'email': email.trim(),
          'telephone': telephone.trim(),
          'role': roleNettoye,
          'password': password,
          'password_confirmation':
              passwordConfirmation,
        }),
      );

      final donnees = _decoderReponse(response.body);

      if (response.statusCode == 201) {
        return {
          'succes': true,
          'message':
              'Votre compte a été créé avec succès.',
          'utilisateur': donnees,
          'role':
              donnees['role']?.toString() ??
              roleNettoye,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          messageParDefaut:
              'Impossible de créer le compte.',
        ),
      };
    } catch (erreur) {
      debugPrint(
        'Erreur pendant l’inscription : $erreur',
      );

      return {
        'succes': false,
        'message':
            'Impossible de contacter le serveur Django.',
      };
    }
  }

  Future<void> deconnexion() async {
    await TokenStorage.supprimerSession();
  }

  Map<String, dynamic> _decoderReponse(
    String corps,
  ) {
    if (corps.trim().isEmpty) {
      return {};
    }

    try {
      final resultat = jsonDecode(corps);

      if (resultat is Map<String, dynamic>) {
        return resultat;
      }

      if (resultat is Map) {
        return Map<String, dynamic>.from(
          resultat,
        );
      }

      return {
        'detail': resultat.toString(),
      };
    } catch (_) {
      return {
        'detail':
            'La réponse du serveur est invalide.',
      };
    }
  }

  int? _convertirEntier(dynamic valeur) {
    if (valeur is int) {
      return valeur;
    }

    return int.tryParse(
      valeur?.toString() ?? '',
    );
  }

  String _extraireMessageErreur(
    Map<String, dynamic> donnees, {
    required String messageParDefaut,
  }) {
    if (donnees['detail'] != null) {
      return donnees['detail'].toString();
    }

    final erreurs = <String>[];

    donnees.forEach((champ, valeur) {
      final nomChamp =
          _nomChampLisible(champ);

      if (valeur is List) {
        for (final erreur in valeur) {
          erreurs.add(
            '$nomChamp : ${erreur.toString()}',
          );
        }
      } else if (valeur is Map) {
        valeur.forEach(
          (sousChamp, sousValeur) {
            if (sousValeur is List) {
              for (final erreur
                  in sousValeur) {
                erreurs.add(
                  '${_nomChampLisible(sousChamp.toString())} : '
                  '${erreur.toString()}',
                );
              }
            } else {
              erreurs.add(
                '${_nomChampLisible(sousChamp.toString())} : '
                '${sousValeur.toString()}',
              );
            }
          },
        );
      } else if (valeur != null) {
        erreurs.add(
          '$nomChamp : ${valeur.toString()}',
        );
      }
    });

    if (erreurs.isEmpty) {
      return messageParDefaut;
    }

    return erreurs.join('\n');
  }

  String _nomChampLisible(
    String champ,
  ) {
    switch (champ) {
      case 'username':
        return 'Nom d’utilisateur';

      case 'first_name':
        return 'Prénom';

      case 'last_name':
        return 'Nom';

      case 'email':
        return 'Adresse e-mail';

      case 'telephone':
        return 'Téléphone';

      case 'role':
        return 'Rôle';

      case 'password':
        return 'Mot de passe';

      case 'password_confirmation':
        return 'Confirmation du mot de passe';

      case 'non_field_errors':
        return 'Erreur';

      default:
        return champ;
    }
  }
}