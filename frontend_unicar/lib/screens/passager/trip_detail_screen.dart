import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trajet.dart';
import '../../providers/reservation_provider.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({
    super.key,
    required this.trajet,
  });

  final Trajet trajet;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  int _nombrePlaces = 1;

  Future<void> _reserver() async {
    final reservationProvider = context.read<ReservationProvider>();

    reservationProvider.effacerErreur();

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la réservation'),
          content: Text(
            'Voulez-vous réserver $_nombrePlaces place(s) pour le trajet '
            '${widget.trajet.lieuDepart} → '
            '${widget.trajet.lieuArrivee} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmation != true || !mounted) {
      return;
    }

    final succes = await reservationProvider.creerReservation(
      trajetId: widget.trajet.id,
      nombrePlaces: _nombrePlaces,
    );

    if (!mounted) {
      return;
    }

    if (succes) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline,
              size: 55,
              color: Colors.green,
            ),
            title: const Text('Réservation envoyée'),
            content: const Text(
              'Votre réservation a été enregistrée. '
              'Elle est maintenant en attente de la réponse du conducteur.',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('D’accord'),
              ),
            ],
          );
        },
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reservationProvider.messageErreur ??
              'La réservation a échoué.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trajet = widget.trajet;
    final reservationProvider = context.watch<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du trajet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          size: 60,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '${trajet.lieuDepart} → ${trajet.lieuArrivee}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _DetailLigne(
                  icone: Icons.person_outline,
                  titre: 'Conducteur',
                  valeur: trajet.conducteur.isEmpty
                      ? 'Non renseigné'
                      : trajet.conducteur,
                ),
                _DetailLigne(
                  icone: Icons.calendar_today_outlined,
                  titre: 'Date de départ',
                  valeur: trajet.dateDepart,
                ),
                _DetailLigne(
                  icone: Icons.access_time,
                  titre: 'Heure de départ',
                  valeur: trajet.heureDepart,
                ),
                _DetailLigne(
                  icone: Icons.event_seat_outlined,
                  titre: 'Places disponibles',
                  valeur: '${trajet.nombrePlacesDisponibles}',
                ),
                _DetailLigne(
                  icone: Icons.payments_outlined,
                  titre: 'Prix par place',
                  valeur: '${trajet.prixParPlace} FCFA',
                ),
                _DetailLigne(
                  icone: Icons.info_outline,
                  titre: 'Statut',
                  valeur: trajet.statut,
                ),
                if (trajet.description.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(trajet.description),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                const Text(
                  'Nombre de places à réserver',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _nombrePlaces > 1
                              ? () {
                                  setState(() {
                                    _nombrePlaces--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          child: Text(
                            '$_nombrePlaces',
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _nombrePlaces <
                                  trajet.nombrePlacesDisponibles
                              ? () {
                                  setState(() {
                                    _nombrePlaces++;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Prix total : '
                  '${_calculerPrixTotal(trajet.prixParPlace)} FCFA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: trajet.nombrePlacesDisponibles > 0 &&
                            !reservationProvider.chargement
                        ? _reserver
                        : null,
                    icon: reservationProvider.chargement
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.event_available),
                    label: Text(
                      reservationProvider.chargement
                          ? 'Réservation en cours...'
                          : 'Réserver ce trajet',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculerPrixTotal(String prix) {
    final prixParPlace =
        double.tryParse(prix.replaceAll(',', '.')) ?? 0;

    final total = prixParPlace * _nombrePlaces;

    if (total == total.roundToDouble()) {
      return total.toInt().toString();
    }

    return total.toStringAsFixed(2);
  }
}

class _DetailLigne extends StatelessWidget {
  const _DetailLigne({
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  final IconData icone;
  final String titre;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icone),
        title: Text(titre),
        subtitle: Text(
          valeur,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}