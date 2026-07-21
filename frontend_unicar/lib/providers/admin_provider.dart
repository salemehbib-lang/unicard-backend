import 'package:flutter/material.dart';

import '../models/admin_utilisateur.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({
    AdminService? adminService,
  }) : _adminService =
            adminService ?? AdminService();

  final AdminService _adminService;

  bool _chargementStatistiques = false;
  bool _chargementUtilisateurs = false;

  String? _messageErreur;
  String? _messageSucces;

  Map<String, dynamic> _statistiques = {};

  List<AdminUtilisateur> _utilisateurs = [];

  final Set<int> _utilisateursEnModification =
      {};

  bool get chargementStatistiques =>
      _chargementStatistiques;

  bool get chargementUtilisateurs =>
      _chargementUtilisateurs;

  String? get messageErreur =>
      _messageErreur;

  String? get messageSucces =>
      _messageSucces;

  Map<String, dynamic> get statistiques =>
      Map.unmodifiable(_statistiques);

  List<AdminUtilisateur> get utilisateurs =>
      List.unmodifiable(_utilisateurs);

  bool utilisateurEnModification(
    int utilisateurId,
  ) {
    return _utilisateursEnModification.contains(
      utilisateurId,
    );
  }

  Future<bool> chargerStatistiques() async {
    _chargementStatistiques = true;
    _messageErreur = null;

    notifyListeners();

    final resultat =
        await _adminService.recupererStatistiques();

    _chargementStatistiques = false;

    if (resultat['succes'] == true) {
      final donnees = resultat['statistiques'];

      if (donnees is Map<String, dynamic>) {
        _statistiques = donnees;
      } else if (donnees is Map) {
        _statistiques =
            Map<String, dynamic>.from(
          donnees,
        );
      }

      notifyListeners();
      return true;
    }

    _messageErreur = (
      resultat['message'] ??
      'Impossible de charger les statistiques.'
    ).toString();

    notifyListeners();
    return false;
  }

  Future<bool> chargerUtilisateurs({
    String? role,
    bool? estBloque,
  }) async {
    _chargementUtilisateurs = true;
    _messageErreur = null;

    notifyListeners();

    final resultat =
        await _adminService.recupererUtilisateurs(
      role: role,
      estBloque: estBloque,
    );

    _chargementUtilisateurs = false;

    if (resultat['succes'] == true) {
      final donnees = resultat['utilisateurs'];

      if (donnees is List<AdminUtilisateur>) {
        _utilisateurs = donnees;
      } else {
        _utilisateurs = [];
      }

      notifyListeners();
      return true;
    }

    _messageErreur = (
      resultat['message'] ??
      'Impossible de charger les utilisateurs.'
    ).toString();

    notifyListeners();
    return false;
  }

  Future<bool> bloquerUtilisateur({
    required int utilisateurId,
  }) async {
    return _modifierBlocage(
      utilisateurId: utilisateurId,
      bloquer: true,
    );
  }

  Future<bool> debloquerUtilisateur({
    required int utilisateurId,
  }) async {
    return _modifierBlocage(
      utilisateurId: utilisateurId,
      bloquer: false,
    );
  }

  Future<bool> _modifierBlocage({
    required int utilisateurId,
    required bool bloquer,
  }) async {
    if (_utilisateursEnModification.contains(
      utilisateurId,
    )) {
      return false;
    }

    _utilisateursEnModification.add(
      utilisateurId,
    );

    _messageErreur = null;
    _messageSucces = null;

    notifyListeners();

    final resultat = bloquer
        ? await _adminService.bloquerUtilisateur(
            utilisateurId: utilisateurId,
          )
        : await _adminService.debloquerUtilisateur(
            utilisateurId: utilisateurId,
          );

    _utilisateursEnModification.remove(
      utilisateurId,
    );

    if (resultat['succes'] == true) {
      _messageSucces = (
        resultat['message'] ??
        'Modification effectuée avec succès.'
      ).toString();

      _utilisateurs = _utilisateurs.map(
        (utilisateur) {
          if (utilisateur.id ==
              utilisateurId) {
            return utilisateur.copyWith(
              estBloque: bloquer,
            );
          }

          return utilisateur;
        },
      ).toList();

      await chargerStatistiques();

      notifyListeners();
      return true;
    }

    _messageErreur = (
      resultat['message'] ??
      'La modification a échoué.'
    ).toString();

    notifyListeners();
    return false;
  }

  int valeurStatistique(
    String groupe,
    String cle,
  ) {
    final donneesGroupe =
        _statistiques[groupe];

    if (donneesGroupe is Map) {
      final valeur = donneesGroupe[cle];

      if (valeur is int) {
        return valeur;
      }

      return int.tryParse(
            valeur?.toString() ?? '',
          ) ??
          0;
    }

    return 0;
  }

  void effacerMessages() {
    _messageErreur = null;
    _messageSucces = null;

    notifyListeners();
  }
}