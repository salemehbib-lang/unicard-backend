import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _role;
  String? _username;

  String? get role => _role;
  String? get username => _username;

  bool _chargement = false;
  bool _estConnecte = false;
  String? _messageErreur;

  bool get chargement => _chargement;
  bool get estConnecte => _estConnecte;
  String? get messageErreur => _messageErreur;

  Future<void> verifierConnexion() async {
    _estConnecte = await TokenStorage.estConnecte();
    notifyListeners();
  }

  Future<void> chargerUtilisateurEnregistre() async {
    _role = await TokenStorage.recupererRole();
    _username = await TokenStorage.recupererUsername();

    notifyListeners();
  }

  Future<bool> connexion({
    required String username,
    required String password,
  }) async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    final resultat = await _authService.connexion(
      username: username,
      password: password,
    );

    _chargement = false;

    if (resultat['succes'] == true) {
      _role = resultat['role']?.toString();

      final utilisateur = resultat['utilisateur'];

      if (utilisateur is Map<String, dynamic>) {
        _username = utilisateur['username']?.toString();
      }

      _chargement = false;
      notifyListeners();

      return true;
    }

    _estConnecte = false;
    _messageErreur =
        resultat['message']?.toString() ?? 'Une erreur est survenue.';
    notifyListeners();
    return false;
  }

  Future<void> deconnexion() async {
    await TokenStorage.supprimerSession();
    _estConnecte = false;
    _role = null;
    _username = null;
    _messageErreur = null;

    notifyListeners();
  }

  void effacerErreur() {
    _messageErreur = null;
    notifyListeners();
  }
}
