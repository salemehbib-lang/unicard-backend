import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    return 'http://10.0.2.2:8000/api';
  }

  // AUTHENTIFICATION

  static String get connexion =>
      '$baseUrl/auth/connexion/';

  static String get inscription =>
      '$baseUrl/auth/inscription/';

  static String get profil =>
      '$baseUrl/auth/profil/';

  static String get refreshToken =>
      '$baseUrl/auth/token/refresh/';

  // TRAJETS

  static String get trajets =>
      '$baseUrl/trajets/';

  static String get mesTrajets =>
      '$baseUrl/mes-trajets/';

  // RÉSERVATIONS

  static String get reservations =>
      '$baseUrl/reservations/';

  // VÉHICULES

  static String get vehicules =>
      '$baseUrl/vehicules/';

  // NOTIFICATIONS

  static String get notifications =>
      '$baseUrl/notifications/';

  // ADMINISTRATION

  static String get adminUtilisateurs =>
      '$baseUrl/admin/utilisateurs/';

  static String get adminStatistiques =>
      '$baseUrl/admin/statistiques/';

  static String adminDetailUtilisateur(
    int utilisateurId,
  ) {
    return '$adminUtilisateurs$utilisateurId/';
  }

  static String adminBloquerUtilisateur(
    int utilisateurId,
  ) {
    return '$adminUtilisateurs$utilisateurId/bloquer/';
  }

  static String adminDebloquerUtilisateur(
    int utilisateurId,
  ) {
    return '$adminUtilisateurs$utilisateurId/debloquer/';
  }
}