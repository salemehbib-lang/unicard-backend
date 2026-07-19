import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationProvider extends ChangeNotifier {
  ReservationProvider({
    ReservationService? reservationService,
  }) : _reservationService =
            reservationService ?? ReservationService();

  final ReservationService _reservationService;

  final List<Reservation> _reservations = [];

  bool _chargement = false;
  String? _messageErreur;

  List<Reservation> get reservations =>
      List.unmodifiable(_reservations);

  bool get chargement => _chargement;

  String? get messageErreur => _messageErreur;

  Future<void> chargerReservations() async {
    _demarrerChargement();

    try {
      final reservationsRecues =
          await _reservationService
              .recupererReservations();

      _reservations
        ..clear()
        ..addAll(reservationsRecues);

      _messageErreur = null;
    } catch (erreur) {
      _reservations.clear();

      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            'Impossible de charger les réservations.',
      );
    } finally {
      _terminerChargement();
    }
  }

  Future<bool> creerReservation({
    required int trajetId,
    required int nombrePlaces,
  }) async {
    if (trajetId <= 0) {
      _definirErreur(
        'Le trajet sélectionné est invalide.',
      );

      return false;
    }

    if (nombrePlaces <= 0) {
      _definirErreur(
        'Le nombre de places doit être supérieur à zéro.',
      );

      return false;
    }

    return _executerAction(
      action: () {
        return _reservationService.creerReservation(
          trajetId: trajetId,
          nombrePlaces: nombrePlaces,
        );
      },
      messageErreurParDefaut:
          'La réservation a échoué.',
      rechargerApresSucces: true,
    );
  }

  Future<bool> annulerReservation({
    required int reservationId,
  }) async {
    if (reservationId <= 0) {
      _definirErreur(
        'La réservation sélectionnée est invalide.',
      );

      return false;
    }

    return _executerAction(
      action: () {
        return _reservationService.annulerReservation(
          reservationId: reservationId,
        );
      },
      messageErreurParDefaut:
          'Impossible d’annuler la réservation.',
      rechargerApresSucces: true,
    );
  }

  Future<bool> accepterReservation({
    required int reservationId,
  }) async {
    if (reservationId <= 0) {
      _definirErreur(
        'La réservation sélectionnée est invalide.',
      );

      return false;
    }

    return _executerAction(
      action: () {
        return _reservationService.accepterReservation(
          reservationId: reservationId,
        );
      },
      messageErreurParDefaut:
          'Impossible d’accepter la réservation.',
      rechargerApresSucces: true,
    );
  }

  Future<bool> refuserReservation({
    required int reservationId,
  }) async {
    if (reservationId <= 0) {
      _definirErreur(
        'La réservation sélectionnée est invalide.',
      );

      return false;
    }

    return _executerAction(
      action: () {
        return _reservationService.refuserReservation(
          reservationId: reservationId,
        );
      },
      messageErreurParDefaut:
          'Impossible de refuser la réservation.',
      rechargerApresSucces: true,
    );
  }

  Future<bool> _executerAction({
    required Future<Map<String, dynamic>> Function()
        action,
    required String messageErreurParDefaut,
    bool rechargerApresSucces = false,
  }) async {
    _demarrerChargement();

    try {
      final resultat = await action();

      final succes = resultat['succes'] == true;

      if (!succes) {
        _messageErreur =
            resultat['message']?.toString().trim();

        if (_messageErreur == null ||
            _messageErreur!.isEmpty) {
          _messageErreur =
              messageErreurParDefaut;
        }

        return false;
      }

      _messageErreur = null;

      if (rechargerApresSucces) {
        try {
          final reservationsRecues =
              await _reservationService
                  .recupererReservations();

          _reservations
            ..clear()
            ..addAll(reservationsRecues);
        } catch (erreur) {
          /*
           * L’action principale a réussi.
           * Une erreur de rechargement ne doit donc pas
           * transformer le résultat en échec.
           */
          debugPrint(
            'Impossible de recharger les réservations : '
            '$erreur',
          );
        }
      }

      return true;
    } catch (erreur) {
      _messageErreur = _nettoyerErreur(
        erreur,
        messageParDefaut:
            messageErreurParDefaut,
      );

      return false;
    } finally {
      _terminerChargement();
    }
  }

  void effacerErreur() {
    if (_messageErreur == null) {
      return;
    }

    _messageErreur = null;
    notifyListeners();
  }

  void viderReservations() {
    final avaitDesReservations =
        _reservations.isNotEmpty;

    final avaitUneErreur =
        _messageErreur != null;

    _reservations.clear();
    _messageErreur = null;
    _chargement = false;

    if (avaitDesReservations ||
        avaitUneErreur) {
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

  void _definirErreur(String message) {
    _chargement = false;
    _messageErreur = message;
    notifyListeners();
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