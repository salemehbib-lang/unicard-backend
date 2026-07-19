import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationCard(
            icon: Icons.schedule,
            titre: 'Réservation en attente',
            message:
                'Votre demande de réservation est en attente de validation.',
            heure: 'Maintenant',
          ),
          SizedBox(height: 12),
          _NotificationCard(
            icon: Icons.check_circle_outline,
            titre: 'Réservation acceptée',
            message:
                'Le conducteur a accepté votre réservation.',
            heure: 'Aujourd’hui',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.titre,
    required this.message,
    required this.heure,
  });

  final IconData icon;
  final String titre;
  final String message;
  final String heure;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          titre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(message),
        ),
        trailing: Text(
          heure,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}