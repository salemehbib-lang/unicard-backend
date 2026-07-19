class ApiConfig {
  static const String baseUrl =
      'http://127.0.0.1:8000/api';

  static const String connexion =
      '$baseUrl/auth/connexion/';

  static const String inscription =
      '$baseUrl/auth/inscription/';

  static const String profil =
      '$baseUrl/auth/profil/';

  static const String refreshToken =
      '$baseUrl/auth/token/refresh/';

  static const String trajets =
      '$baseUrl/trajets/';

  static const String reservations =
      '$baseUrl/reservations/';

  static const String vehicules =
      '$baseUrl/vehicules/';
  static const String mesTrajets =
    '$baseUrl/mes-trajets/';
}