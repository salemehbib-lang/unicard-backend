import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() =>
      _MyReservationsScreenState();
}

class _MyReservationsScreenState
    extends State<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ReservationProvider>()
          .chargerReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<ReservationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.chargerReservations,
        child: Builder(
          builder: (context) {
            if (provider.chargement) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.messageErreur != null) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 180),
                  Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: Text(
                        provider.messageErreur!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (provider.reservations.isEmpty) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.event_busy_outlined,
                    size: 65,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Aucune réservation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount:
                  provider.reservations.length,
              itemBuilder: (context, index) {
                final reservation =
                    provider.reservations[index];

                return _ReservationCard(
                  reservation: reservation,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
  });

  final Reservation reservation;

  Future<void> _annulerReservation(
    BuildContext context,
  ) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text('Annuler la réservation'),
          content: Text(
            'Voulez-vous vraiment annuler la réservation '
            '${reservation.lieuDepart} → '
            '${reservation.lieuArrivee} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              child:
                  const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );

    if (confirmation != true ||
        !context.mounted) {
      return;
    }

    final succes = await context
        .read<ReservationProvider>()
        .annulerReservation(
          reservationId: reservation.id,
        );

    if (!context.mounted) {
      return;
    }

    if (succes) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Réservation annulée avec succès.',
          ),
        ),
      );
      return;
    }

    final message = context
            .read<ReservationProvider>()
            .messageErreur ??
        'Impossible d’annuler la réservation.';

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '${reservation.lieuDepart} → '
              '${reservation.lieuArrivee}',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _InformationLine(
              icon:
                  Icons.calendar_today_outlined,
              texte: reservation.dateDepart,
            ),
            const SizedBox(height: 10),
            _InformationLine(
              icon: Icons.access_time,
              texte: reservation.heureDepart,
            ),
            const SizedBox(height: 10),
            _InformationLine(
              icon: Icons.event_seat_outlined,
              texte:
                  '${reservation.nombrePlaces} place(s)',
            ),

            if (reservation
                .informationsConducteurDisponibles) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Informations du conducteur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _InformationLine(
                icon: Icons.person_outline,
                texte:
                    reservation.nomConducteur!,
              ),
              if (reservation
                          .telephoneConducteur !=
                      null &&
                  reservation
                      .telephoneConducteur!
                      .trim()
                      .isNotEmpty) ...[
                const SizedBox(height: 10),
                _InformationLine(
                  icon: Icons.phone_outlined,
                  texte: reservation
                      .telephoneConducteur!,
                ),
              ],
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                _StatutBadge(
                  statut: reservation.statut,
                ),
                if (reservation
                    .peutEtreAnnulee)
                  TextButton.icon(
                    onPressed: () {
                      _annulerReservation(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                    ),
                    label:
                        const Text('Annuler'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationLine extends StatelessWidget {
  const _InformationLine({
    required this.icon,
    required this.texte,
  });

  final IconData icon;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texte,
            style:
                const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class _StatutBadge extends StatelessWidget {
  const _StatutBadge({
    required this.statut,
  });

  final String statut;

  @override
  Widget build(BuildContext context) {
    String libelle;
    Color couleur;

    switch (statut) {
      case 'acceptee':
        libelle = 'Acceptée';
        couleur = Colors.green;
        break;

      case 'refusee':
        libelle = 'Refusée';
        couleur = Colors.red;
        break;

      case 'annulee':
        libelle = 'Annulée';
        couleur = Colors.grey;
        break;

      case 'en_attente':
      default:
        libelle = 'En attente';
        couleur = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            couleur.withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: couleur,
        ),
      ),
      child: Text(
        libelle,
        style: TextStyle(
          color: couleur,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}