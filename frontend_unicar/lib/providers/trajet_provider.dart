import 'package:flutter/material.dart';

import '../models/trajet.dart';
import '../services/trajet_service.dart';

class TrajetProvider extends ChangeNotifier {
  TrajetProvider({
    TrajetService? trajetService,
  }) : _trajetService =
            trajetService ?? TrajetService();

  final TrajetService _trajetService;

  final List<Trajet> _trajets = [];

  bool _chargement = false;
  bool _operationEnCours = false;

  String? _messageErreur;
  String? _messageSucces;

  List<Trajet> get trajets {
    return List.unmodifiable(_trajets);
  }

  bool get chargement => _chargement;

  bool get operationEnCours => _operationEnCours;

  String? get messageErreur => _messageErreur;

  String? get messageSucces => _messageSucces;

  bool get aDesTrajets => _trajets.isNotEmpty;

  List<Trajet> get trajetsDisponibles {
    return _trajets
        .where(
          (trajet) => trajet.estDisponible,
        )
        .toList(growable: false);
  }

  Future<void> chargerTrajets() async {
    await rechercherTrajets(
      depart: '',
      arrivee: '',
    );
  }
  Future<void> chargerMesTrajets() async {
  _demarrerChargement();

  try {
    final trajetsRecus =
        await _trajetService.recupererMesTrajets();

    _trajets
      ..clear()
      ..addAll(trajetsRecus);

    _messageErreur = null;
    _trierTrajets();
  } catch (erreur) {
    _trajets.clear();

    _messageErreur = _nettoyerErreur(
      erreur,
      messageParDefaut:
          'Impossible de charger vos trajets.',
    );
  } finally {
    _terminerChargement();
  }
}

  Future<void> rechercherTrajets({
    required String depart,
    required String arrivee,
  }) async {
    _demarrerChargement();

    try {
      final trajetsRecus =
          await _trajetService.rechercherTrajets(
        depart: depart,
        arrivee: arrivee,
      );

      _trajets
        ..clear()
        ..addAll(trajetsRecus);

      _messageErreur = null;
      _trierTrajets();
    } catch (erreur) {
      _trajets.clear();

      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            'Impossible de charger les trajets.',
      );
    } finally {
      _terminerChargement();
    }
  }

  Future<void> actualiserTrajets({
    String depart = '',
    String arrivee = '',
  }) async {
    await rechercherTrajets(
      depart: depart,
      arrivee: arrivee,
    );
  }

  Future<bool> creerTrajet({
    required int vehiculeId,
    required String lieuDepart,
    required String lieuArrivee,
    required DateTime dateDepart,
    required String heureDepart,
    required int nombrePlacesDisponibles,
    required double prixParPlace,
    String description = '',
  }) async {
    if (_operationEnCours) {
      return false;
    }

    _demarrerOperation();

    try {
      final resultat =
          await _trajetService.creerTrajet(
        vehiculeId: vehiculeId,
        lieuDepart: lieuDepart,
        lieuArrivee: lieuArrivee,
        dateDepart: dateDepart,
        heureDepart: heureDepart,
        nombrePlacesDisponibles:
            nombrePlacesDisponibles,
        prixParPlace: prixParPlace,
        description: description,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de créer le trajet.';

        return false;
      }

      final trajetCree = _convertirTrajet(
        resultat['trajet'],
      );

      if (trajetCree != null) {
        _ajouterOuRemplacerTrajet(
          trajetCree,
        );
      }

      _messageSucces =
          resultat['message']?.toString() ??
              'Le trajet a été créé avec succès.';

      return true;
    } catch (erreur) {
      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            'Impossible de créer le trajet.',
      );

      return false;
    } finally {
      _terminerOperation();
    }
  }

  Future<bool> modifierTrajet({
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
    if (_operationEnCours) {
      return false;
    }

    _demarrerOperation();

    try {
      final resultat =
          await _trajetService.modifierTrajet(
        trajetId: trajetId,
        vehiculeId: vehiculeId,
        lieuDepart: lieuDepart,
        lieuArrivee: lieuArrivee,
        dateDepart: dateDepart,
        heureDepart: heureDepart,
        nombrePlacesDisponibles:
            nombrePlacesDisponibles,
        prixParPlace: prixParPlace,
        description: description,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de modifier le trajet.';

        return false;
      }

      final trajetModifie = _convertirTrajet(
        resultat['trajet'],
      );

      if (trajetModifie != null) {
        _ajouterOuRemplacerTrajet(
          trajetModifie,
        );
      }

      _messageSucces =
          resultat['message']?.toString() ??
              'Le trajet a été modifié avec succès.';

      return true;
    } catch (erreur) {
      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            'Impossible de modifier le trajet.',
      );

      return false;
    } finally {
      _terminerOperation();
    }
  }

  Future<bool> supprimerTrajet({
    required int trajetId,
  }) async {
    if (_operationEnCours) {
      return false;
    }

    _demarrerOperation();

    try {
      final resultat =
          await _trajetService.supprimerTrajet(
        trajetId: trajetId,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de supprimer le trajet.';

        return false;
      }

      _trajets.removeWhere(
        (trajet) => trajet.id == trajetId,
      );

      _messageSucces =
          resultat['message']?.toString() ??
              'Le trajet a été supprimé avec succès.';

      return true;
    } catch (erreur) {
      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            'Impossible de supprimer le trajet.',
      );

      return false;
    } finally {
      _terminerOperation();
    }
  }

  Future<bool> changerEtatTrajet({
    required int trajetId,
    required String nouvelEtat,
  }) async {
    if (_operationEnCours) {
      return false;
    }

    _demarrerOperation();

    try {
      final resultat =
          await _trajetService.changerEtatTrajet(
        trajetId: trajetId,
        nouvelEtat: nouvelEtat,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de modifier l’état du trajet.';

        return false;
      }

      _messageSucces =
          resultat['message']?.toString() ??
              'L’état du trajet a été modifié avec succès.';

      return true;
    } catch (erreur) {
      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            'Impossible de modifier l’état du trajet.',
      );

      return false;
    } finally {
      _terminerOperation();
    }
  }

  Future<bool> annulerTrajet({
    required int trajetId,
  }) async {
    if (_operationEnCours) {
      return false;
    }

    _demarrerOperation();

    try {
      final resultat =
          await _trajetService.annulerTrajet(
        trajetId: trajetId,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible d’annuler le trajet.';

        return false;
      }

      _messageSucces =
          resultat['message']?.toString() ??
              'Le trajet a été annulé avec succès.';

      return true;
    } catch (erreur) {
      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            'Impossible d’annuler le trajet.',
      );

      return false;
    } finally {
      _terminerOperation();
    }
  }

  Trajet? trouverTrajetParId(
    int trajetId,
  ) {
    if (trajetId <= 0) {
      return null;
    }

    for (final trajet in _trajets) {
      if (trajet.id == trajetId) {
        return trajet;
      }
    }

    return null;
  }

  void effacerErreur() {
    if (_messageErreur == null) {
      return;
    }

    _messageErreur = null;
    notifyListeners();
  }

  void effacerSucces() {
    if (_messageSucces == null) {
      return;
    }

    _messageSucces = null;
    notifyListeners();
  }

  void effacerMessages() {
    if (_messageErreur == null &&
        _messageSucces == null) {
      return;
    }

    _messageErreur = null;
    _messageSucces = null;
    notifyListeners();
  }

  void viderTrajets() {
    final doitNotifier =
        _trajets.isNotEmpty ||
        _messageErreur != null ||
        _messageSucces != null ||
        _chargement ||
        _operationEnCours;

    _trajets.clear();
    _messageErreur = null;
    _messageSucces = null;
    _chargement = false;
    _operationEnCours = false;

    if (doitNotifier) {
      notifyListeners();
    }
  }

  void _demarrerChargement() {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();
  }

  void _terminerChargement() {
    _chargement = false;
    notifyListeners();
  }

  void _demarrerOperation() {
    _operationEnCours = true;
    _messageErreur = null;
    _messageSucces = null;
    notifyListeners();
  }

  void _terminerOperation() {
    _operationEnCours = false;
    notifyListeners();
  }

  Trajet? _convertirTrajet(
    dynamic donnees,
  ) {
    if (donnees is Map<String, dynamic>) {
      return Trajet.fromJson(donnees);
    }

    if (donnees is Map) {
      return Trajet.fromJson(
        Map<String, dynamic>.from(donnees),
      );
    }

    return null;
  }

  void _ajouterOuRemplacerTrajet(
    Trajet trajet,
  ) {
    final index = _trajets.indexWhere(
      (element) => element.id == trajet.id,
    );

    if (index == -1) {
      _trajets.add(trajet);
    } else {
      _trajets[index] = trajet;
    }

    _trierTrajets();
  }

  void _trierTrajets() {
    _trajets.sort(
      (premier, deuxieme) {
        final comparaisonDate =
            premier.dateDepart.compareTo(
          deuxieme.dateDepart,
        );

        if (comparaisonDate != 0) {
          return comparaisonDate;
        }

        return premier.heureDepart.compareTo(
          deuxieme.heureDepart,
        );
      },
    );
  }

  String _nettoyerErreur(
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
}