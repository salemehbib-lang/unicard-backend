import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _cleAccessToken = 'access_token';
  static const String _cleRefreshToken = 'refresh_token';

  static const String _cleUtilisateurId = 'utilisateur_id';
  static const String _cleUsername = 'username';
  static const String _cleEmail = 'email';
  static const String _cleTelephone = 'telephone';
  static const String _cleRole = 'role';

  static Future<void> enregistrerTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _cleAccessToken,
      accessToken,
    );

    await preferences.setString(
      _cleRefreshToken,
      refreshToken,
    );
  }

  static Future<void> enregistrerUtilisateur({
    required int id,
    required String username,
    required String email,
    required String telephone,
    required String role,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt(
      _cleUtilisateurId,
      id,
    );

    await preferences.setString(
      _cleUsername,
      username,
    );

    await preferences.setString(
      _cleEmail,
      email,
    );

    await preferences.setString(
      _cleTelephone,
      telephone,
    );

    await preferences.setString(
      _cleRole,
      role,
    );
  }

  static Future<String?> recupererAccessToken() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_cleAccessToken);
  }

  static Future<String?> recupererRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_cleRefreshToken);
  }

  static Future<int?> recupererUtilisateurId() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getInt(_cleUtilisateurId);
  }

  static Future<String?> recupererUsername() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_cleUsername);
  }

  static Future<String?> recupererEmail() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_cleEmail);
  }

  static Future<String?> recupererTelephone() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_cleTelephone);
  }

  static Future<String?> recupererRole() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getString(_cleRole);
  }

  static Future<bool> estConnecte() async {
    final token = await recupererAccessToken();

    return token != null && token.isNotEmpty;
  }

  static Future<void> supprimerSession() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_cleAccessToken);
    await preferences.remove(_cleRefreshToken);

    await preferences.remove(_cleUtilisateurId);
    await preferences.remove(_cleUsername);
    await preferences.remove(_cleEmail);
    await preferences.remove(_cleTelephone);
    await preferences.remove(_cleRole);
  }
}