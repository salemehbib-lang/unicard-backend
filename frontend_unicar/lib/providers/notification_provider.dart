import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<dynamic> _notifications = [];
  bool _chargement = false;
  String? _messageErreur;

  List<dynamic> get notifications => _notifications;

  bool get chargement => _chargement;

  String? get messageErreur => _messageErreur;

  Future<void> chargerNotifications() async {
    _chargement = true;
    _messageErreur = null;
    notifyListeners();

    final resultat = await _notificationService.recupererNotifications();

    if (resultat['succes'] == true) {
      _notifications = List<dynamic>.from(resultat['notifications'] ?? []);
    } else {
      _notifications = [];

      _messageErreur =
          resultat['message']?.toString() ??
          'Impossible de charger les notifications.';
    }

    _chargement = false;
    notifyListeners();
  }

  Future<bool> marquerCommeLue(int notificationId) async {
    final resultat = await _notificationService.marquerCommeLue(notificationId);

    if (resultat['succes'] == true) {
      final index = _notifications.indexWhere(
        (notification) => notification['id'] == notificationId,
      );

      if (index != -1) {
        final notificationActuelle = Map<String, dynamic>.from(
          _notifications[index],
        );

        notificationActuelle['est_lue'] = true;
        _notifications[index] = notificationActuelle;

        notifyListeners();
      }

      return true;
    }

    _messageErreur =
        resultat['message']?.toString() ??
        'Impossible de lire la notification.';

    notifyListeners();

    return false;
  }

  void viderNotifications() {
    _notifications = [];
    _messageErreur = null;
    notifyListeners();
  }
}
