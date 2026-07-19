import 'package:flutter/foundation.dart';

import '../models/vehicule.dart';
import '../services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _vehicleService;

  VehicleProvider({
    VehicleService? vehicleService,
  }) : _vehicleService =
            vehicleService ?? VehicleService();

  final List<Vehicle> _vehicules = [];

  bool _chargement = false;
  bool _operationEnCours = false;

  String? _messageErreur;
  String? _messageSucces;

  List<Vehicle> get vehicules =>
      List.unmodifiable(_vehicules);

  List<Vehicle> get vehiculesActifs {
    return _vehicules
        .where((vehicule) => vehicule.estActif)
        .toList(growable: false);
  }

  bool get chargement => _chargement;

  bool get operationEnCours =>
      _operationEnCours;

  String? get messageErreur =>
      _messageErreur;

  String? get messageSucces =>
      _messageSucces;

  bool get possedeVehicule =>
      _vehicules.isNotEmpty;

  bool get possedeVehiculeActif =>
      vehiculesActifs.isNotEmpty;

  Future<void> recupererVehicules({
    bool afficherChargement = true,
  }) async {
    if (afficherChargement) {
      _chargement = true;
    }

    _messageErreur = null;
    _messageSucces = null;
    notifyListeners();

    try {
      final resultat =
          await _vehicleService.recupererVehicules();

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de récupérer les véhicules.';
        return;
      }

      final donnees = resultat['vehicules'];

      if (donnees is! List) {
        _messageErreur =
            'La liste des véhicules est invalide.';
        return;
      }

      final nouveauxVehicules = <Vehicle>[];

      for (final element in donnees) {
        if (element is Map<String, dynamic>) {
          nouveauxVehicules.add(
            Vehicle.fromJson(element),
          );
        } else if (element is Map) {
          nouveauxVehicules.add(
            Vehicle.fromJson(
              Map<String, dynamic>.from(element),
            ),
          );
        }
      }

      _vehicules
        ..clear()
        ..addAll(nouveauxVehicules);

      _trierVehicules();
    } catch (_) {
      _messageErreur =
          'Une erreur est survenue pendant le chargement des véhicules.';
    } finally {
      if (afficherChargement) {
        _chargement = false;
      }

      notifyListeners();
    }
  }

  Future<bool> ajouterVehicule({
    required String marque,
    required String modele,
    required String immatriculation,
    required String couleur,
    required int nombrePlaces,
    required bool estActif,
  }) async {
    if (_operationEnCours) {
      return false;
    }

    _operationEnCours = true;
    _messageErreur = null;
    _messageSucces = null;
    notifyListeners();

    try {
      final resultat =
          await _vehicleService.ajouterVehicule(
        marque: marque,
        modele: modele,
        immatriculation: immatriculation,
        couleur: couleur,
        nombrePlaces: nombrePlaces,
        estActif: estActif,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible d’ajouter le véhicule.';
        return false;
      }

      final donnees = resultat['vehicule'];

      if (donnees is Map<String, dynamic>) {
        _ajouterOuRemplacerVehicule(
          Vehicle.fromJson(donnees),
        );
      } else if (donnees is Map) {
        _ajouterOuRemplacerVehicule(
          Vehicle.fromJson(
            Map<String, dynamic>.from(donnees),
          ),
        );
      } else {
        await recupererVehicules(
          afficherChargement: false,
        );
      }

      _messageSucces =
          resultat['message']?.toString() ??
              'Le véhicule a été ajouté avec succès.';

      return true;
    } catch (_) {
      _messageErreur =
          'Une erreur est survenue pendant l’ajout du véhicule.';
      return false;
    } finally {
      _operationEnCours = false;
      notifyListeners();
    }
  }

  Future<bool> modifierVehicule({
    required int id,
    required String marque,
    required String modele,
    required String immatriculation,
    required String couleur,
    required int nombrePlaces,
    required bool estActif,
  }) async {
    if (_operationEnCours) {
      return false;
    }

    _operationEnCours = true;
    _messageErreur = null;
    _messageSucces = null;
    notifyListeners();

    try {
      final resultat =
          await _vehicleService.modifierVehicule(
        id: id,
        marque: marque,
        modele: modele,
        immatriculation: immatriculation,
        couleur: couleur,
        nombrePlaces: nombrePlaces,
        estActif: estActif,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de modifier le véhicule.';
        return false;
      }

      final donnees = resultat['vehicule'];

      if (donnees is Map<String, dynamic>) {
        _ajouterOuRemplacerVehicule(
          Vehicle.fromJson(donnees),
        );
      } else if (donnees is Map) {
        _ajouterOuRemplacerVehicule(
          Vehicle.fromJson(
            Map<String, dynamic>.from(donnees),
          ),
        );
      } else {
        await recupererVehicules(
          afficherChargement: false,
        );
      }

      _messageSucces =
          resultat['message']?.toString() ??
              'Le véhicule a été modifié avec succès.';

      return true;
    } catch (_) {
      _messageErreur =
          'Une erreur est survenue pendant la modification du véhicule.';
      return false;
    } finally {
      _operationEnCours = false;
      notifyListeners();
    }
  }

  Future<bool> supprimerVehicule({
    required int id,
  }) async {
    if (_operationEnCours) {
      return false;
    }

    _operationEnCours = true;
    _messageErreur = null;
    _messageSucces = null;
    notifyListeners();

    try {
      final resultat =
          await _vehicleService.supprimerVehicule(
        id: id,
      );

      if (resultat['succes'] != true) {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de supprimer le véhicule.';
        return false;
      }

      _vehicules.removeWhere(
        (vehicule) => vehicule.id == id,
      );

      _messageSucces =
          resultat['message']?.toString() ??
              'Le véhicule a été supprimé avec succès.';

      return true;
    } catch (_) {
      _messageErreur =
          'Une erreur est survenue pendant la suppression du véhicule.';
      return false;
    } finally {
      _operationEnCours = false;
      notifyListeners();
    }
  }

  Vehicle? trouverVehiculeParId(int id) {
    for (final vehicule in _vehicules) {
      if (vehicule.id == id) {
        return vehicule;
      }
    }

    return null;
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

  void viderVehicules() {
    _vehicules.clear();
    _messageErreur = null;
    _messageSucces = null;
    _chargement = false;
    _operationEnCours = false;
    notifyListeners();
  }

  void _ajouterOuRemplacerVehicule(
    Vehicle vehicule,
  ) {
    final index = _vehicules.indexWhere(
      (element) => element.id == vehicule.id,
    );

    if (index == -1) {
      _vehicules.add(vehicule);
    } else {
      _vehicules[index] = vehicule;
    }

    _trierVehicules();
  }

  void _trierVehicules() {
    _vehicules.sort((premier, deuxieme) {
      if (premier.estActif != deuxieme.estActif) {
        return premier.estActif ? -1 : 1;
      }

      final comparaisonMarque = premier.marque
          .toLowerCase()
          .compareTo(
            deuxieme.marque.toLowerCase(),
          );

      if (comparaisonMarque != 0) {
        return comparaisonMarque;
      }

      return premier.modele
          .toLowerCase()
          .compareTo(
            deuxieme.modele.toLowerCase(),
          );
    });
  }
}