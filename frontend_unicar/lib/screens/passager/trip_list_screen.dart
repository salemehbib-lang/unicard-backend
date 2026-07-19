import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trajet.dart';
import '../../providers/trajet_provider.dart';
import 'trip_detail_screen.dart';

class TripListScreen extends StatelessWidget {
  const TripListScreen({
    super.key,
    required this.depart,
    required this.arrivee,
  });

  final String depart;
  final String arrivee;

  @override
  Widget build(BuildContext context) {
    final trajetProvider = context.watch<TrajetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trajets disponibles'),
      ),
      body: Builder(
        builder: (context) {
          if (trajetProvider.chargement) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (trajetProvider.messageErreur != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      trajetProvider.messageErreur!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (trajetProvider.trajets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 70,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun trajet disponible',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$depart → $arrivee',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trajetProvider.trajets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final trajet = trajetProvider.trajets[index];

              return _TrajetCard(trajet: trajet);
            },
          );
        },
      ),
    );
  }
}

class _TrajetCard extends StatelessWidget {
  const _TrajetCard({
    required this.trajet,
  });

  final Trajet trajet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TripDetailScreen(
        trajet: trajet,
      ),
    ),
  );
},
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${trajet.lieuDepart} → ${trajet.lieuArrivee}',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 19),
                  const SizedBox(width: 8),
                  Text(trajet.dateDepart),
                  const SizedBox(width: 18),
                  const Icon(Icons.access_time, size: 19),
                  const SizedBox(width: 8),
                  Text(trajet.heureDepart),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.event_seat_outlined, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    '${trajet.nombrePlacesDisponibles} place(s)',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    '${trajet.prixParPlace} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}