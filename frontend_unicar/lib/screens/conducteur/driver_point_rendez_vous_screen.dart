import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/link.dart';

import '../../models/reservation.dart';

class DriverPointRendezVousScreen
    extends StatelessWidget {
  const DriverPointRendezVousScreen({
    super.key,
    required this.reservation,
  });

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final latitude =
        reservation.latitudeRendezVous;

    final longitude =
        reservation.longitudeRendezVous;

    if (latitude == null ||
        longitude == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Point de rendez-vous',
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Les coordonnées du point de rendez-vous '
              'ne sont pas disponibles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    final point = LatLng(
      latitude,
      longitude,
    );

    final itineraireUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$latitude,$longitude'
      '&travelmode=driving',
    );

    final adresse =
        reservation.adresseRendezVous
                ?.trim() ??
            '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Point de rendez-vous',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.frontend_unicar',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 55,
                      height: 55,
                      child: const Icon(
                        Icons.location_pin,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                18,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Point choisi par le passager',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  _InformationRendezVous(
                    icone:
                        Icons.person_outline,
                    titre: 'Passager',
                    valeur:
                        reservation.nomPassager ??
                            'Passager',
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _InformationRendezVous(
                    icone:
                        Icons.location_on_outlined,
                    titre: 'Adresse',
                    valeur: adresse.isNotEmpty
                        ? adresse
                        : 'Adresse non précisée',
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _InformationRendezVous(
                    icone:
                        Icons.my_location_outlined,
                    titre: 'Coordonnées',
                    valeur:
                        '${latitude.toStringAsFixed(6)}, '
                        '${longitude.toStringAsFixed(6)}',
                  ),
                  const SizedBox(
                    height: 18,
                  ),

                  Link(
                    uri: itineraireUri,
                    target: LinkTarget.blank,
                    builder: (
                      BuildContext context,
                      FollowLink? ouvrirLien,
                    ) {
                      return SizedBox(
                        width: double.infinity,
                        child:
                            FilledButton.icon(
                          onPressed:
                              ouvrirLien,
                          icon: const Icon(
                            Icons
                                .navigation_outlined,
                          ),
                          label: const Text(
                            'Ouvrir l’itinéraire',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child:
                        OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                      label: const Text(
                        'Retour aux réservations',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationRendezVous
    extends StatelessWidget {
  const _InformationRendezVous({
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  final IconData icone;
  final String titre;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icone,
          size: 22,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                valeur,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}