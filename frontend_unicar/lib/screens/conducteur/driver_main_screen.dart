import 'package:flutter/material.dart';

import 'add_vehicle_screen.dart';
import 'add_trip_screen.dart';
import 'driver_reservations_screen.dart';
import 'my_trips_screen.dart';

class DriverMainScreen extends StatelessWidget {
  const DriverMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Espace conducteur',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Que souhaitez-vous faire ?',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddVehicleScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.directions_car_outlined,
              ),
              label: const Text(
                'Ajouter un véhicule',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddTripScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_road,
              ),
              label: const Text(
                'Publier un trajet',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const MyTripsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.route_outlined,
              ),
              label: const Text(
                'Mes trajets',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const DriverReservationsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.event_note_outlined,
              ),
              label: const Text(
                'Demandes de réservation',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}