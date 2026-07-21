class ApiConfig {
  static const String baseUrl =
      'http://127.0.0.1:8000/api';

  // AUTHENTIFICATION

  static const String connexion =
      '$baseUrl/auth/connexion/';

  static const String inscription =
      '$baseUrl/auth/inscription/';

  static const String profil =
      '$baseUrl/auth/profil/';

  static const String refreshToken =
      '$baseUrl/auth/token/refresh/';

  // TRAJETS

  static const String trajets =
      '$baseUrl/trajets/';

  static const String mesTrajets =
      '$baseUrl/mes-trajets/';

  // RÉSERVATIONS

  static const String reservations =
      '$baseUrl/reservations/';

  // VÉHICULES

  static const String vehicules =
      '$baseUrl/vehicules/';

  // NOTIFICATIONS

  static const String notifications =
      '$baseUrl/notifications/';

  // ADMINISTRATION

  static const String adminUtilisateurs =
      '$baseUrl/admin/utilisateurs/';

  static const String adminStatistiques =
      '$baseUrl/admin/statistiques/';

  static String adminDetailUtilisateur(
    int utilisateurId,
  ) {
    return (
      '$adminUtilisateurs'
      '$utilisateurId/'
    );
  }

  static String adminBloquerUtilisateur(
    int utilisateurId,
  ) {
    return (
      '$adminUtilisateurs'
      '$utilisateurId/bloquer/'
    );
  }

  static String adminDebloquerUtilisateur(
    int utilisateurId,
  ) {
    return (
      '$adminUtilisateurs'
      '$utilisateurId/debloquer/'
    );
  }
}