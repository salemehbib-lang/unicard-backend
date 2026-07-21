import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().chargerNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.chargement && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.messageErreur != null &&
              provider.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 55),
                    const SizedBox(height: 12),
                    Text(provider.messageErreur!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.chargerNotifications();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.chargerNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.notifications_none, size: 65),
                  SizedBox(height: 12),
                  Center(child: Text('Aucune notification.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.chargerNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];

                final id = notification['id'];
                final titre =
                    notification['titre']?.toString() ?? 'Notification';
                final message = notification['message']?.toString() ?? '';
                final type = notification['type']?.toString() ?? '';
                final lue = notification['est_lue'] == true;
                final dateCreation =
                    notification['date_creation']?.toString() ?? '';

                return _NotificationCard(
                  titre: titre,
                  message: message,
                  heure: _formaterDate(dateCreation),
                  icon: _choisirIcone(type),
                  lue: lue,
                  onTap: id is int && !lue
                      ? () async {
                          final succes = await provider.marquerCommeLue(id);

                          if (!context.mounted) {
                            return;
                          }

                          if (!succes) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.messageErreur ??
                                      'Impossible de lire la notification.',
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _choisirIcone(String type) {
    switch (type) {
      case 'reservation_en_attente':
        return Icons.schedule;

      case 'reservation_acceptee':
        return Icons.check_circle_outline;

      case 'reservation_refusee':
        return Icons.cancel_outlined;

      case 'chauffeur_en_route':
        return Icons.directions_car_outlined;

      case 'chauffeur_arrive':
        return Icons.location_on_outlined;

      case 'trajet_commence':
        return Icons.route_outlined;

      case 'trajet_termine':
        return Icons.flag_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  String _formaterDate(String date) {
    if (date.isEmpty) {
      return '';
    }

    final dateTime = DateTime.tryParse(date);

    if (dateTime == null) {
      return '';
    }

    final dateLocale = dateTime.toLocal();
    final maintenant = DateTime.now();

    final memeJour =
        dateLocale.year == maintenant.year &&
        dateLocale.month == maintenant.month &&
        dateLocale.day == maintenant.day;

    if (memeJour) {
      final heure = dateLocale.hour.toString().padLeft(2, '0');
      final minute = dateLocale.minute.toString().padLeft(2, '0');

      return '$heure:$minute';
    }

    final jour = dateLocale.day.toString().padLeft(2, '0');
    final mois = dateLocale.month.toString().padLeft(2, '0');

    return '$jour/$mois/${dateLocale.year}';
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.titre,
    required this.message,
    required this.heure,
    required this.lue,
    this.onTap,
  });

  final IconData icon;
  final String titre;
  final String message;
  final String heure;
  final bool lue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: lue ? 1 : 3,
      child: ListTile(
        onTap: onTap,
        tileColor: lue
            ? Colors.white
            : Theme.of(context).colorScheme.primaryContainer,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          titre,
          style: TextStyle(
            fontWeight: lue ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(message),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(heure, style: const TextStyle(fontSize: 12)),
            if (!lue) ...[
              const SizedBox(height: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
