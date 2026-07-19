import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';

class DriverReservationsScreen extends StatefulWidget {
  const DriverReservationsScreen({super.key});

  @override
  State<DriverReservationsScreen> createState() =>
      _DriverReservationsScreenState();
}

class _DriverReservationsScreenState
    extends State<DriverReservationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context
          .read<ReservationProvider>()
          .chargerReservations();
    });
  }

  Future<void> _actualiser() async {
    await context
        .read<ReservationProvider>()
        .chargerReservations();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Demandes de réservation',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed:
                provider.chargement ? null : _actualiser,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _actualiser,
        child: _construireContenu(
          context,
          provider,
        ),
      ),
    );
  }

  Widget _construireContenu(
    BuildContext context,
    ReservationProvider provider,
  ) {
    if (provider.chargement &&
        provider.reservations.isEmpty) {
      return const _EtatChargement();
    }

    if (provider.messageErreur != null &&
        provider.reservations.isEmpty) {
      return _EtatErreur(
        message: provider.messageErreur!,
        onReessayer: _actualiser,
      );
    }

    if (provider.reservations.isEmpty) {
      return const _EtatVide();
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        28,
      ),
      itemCount: provider.reservations.length,
      separatorBuilder: (_, _) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        final reservation =
            provider.reservations[index];

        return DriverReservationCard(
          reservation: reservation,
        );
      },
    );
  }
}

class _EtatChargement extends StatelessWidget {
  const _EtatChargement();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _EtatErreur extends StatelessWidget {
  const _EtatErreur({
    required this.message,
    required this.onReessayer,
  });

  final String message;
  final Future<void> Function() onReessayer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.error_outline,
          size: 72,
          color: Theme.of(context)
              .colorScheme
              .error,
        ),
        const SizedBox(height: 18),
        Text(
          'Impossible de charger les réservations',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: onReessayer,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'Réessayer',
            ),
          ),
        ),
      ],
    );
  }
}

class _EtatVide extends StatelessWidget {
  const _EtatVide();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 90),
        Icon(
          Icons.inbox_outlined,
          size: 82,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
        const SizedBox(height: 18),
        Text(
          'Aucune demande',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Les demandes de réservation reçues '
          'pour vos trajets apparaîtront ici.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Tirez la page vers le bas pour actualiser.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }
}

class DriverReservationCard
    extends StatefulWidget {
  const DriverReservationCard({
    super.key,
    required this.reservation,
  });

  final Reservation reservation;

  @override
  State<DriverReservationCard> createState() =>
      _DriverReservationCardState();
}

class _DriverReservationCardState
    extends State<DriverReservationCard> {
  bool _traitement = false;

  Reservation get reservation =>
      widget.reservation;

  Future<bool> _demanderConfirmation({
    required String titre,
    required String message,
    required String texteConfirmation,
    required bool actionDangereuse,
  }) async {
    final resultat = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(titre),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Annuler',
              ),
            ),
            FilledButton(
              style: actionDangereuse
                  ? FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context)
                              .colorScheme
                              .error,
                      foregroundColor:
                          Theme.of(context)
                              .colorScheme
                              .onError,
                    )
                  : null,
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                texteConfirmation,
              ),
            ),
          ],
        );
      },
    );

    return resultat == true;
  }

  Future<void> _accepter() async {
    if (_traitement) {
      return;
    }

    final confirmation =
        await _demanderConfirmation(
      titre: 'Accepter la réservation',
      message:
          'Voulez-vous accepter cette demande de '
          '${reservation.nombrePlaces} place(s) pour le trajet '
          '${reservation.lieuDepart} → '
          '${reservation.lieuArrivee} ?',
      texteConfirmation: 'Accepter',
      actionDangereuse: false,
    );

    if (!confirmation || !mounted) {
      return;
    }

    setState(() {
      _traitement = true;
    });

    final provider =
        context.read<ReservationProvider>();

    final succes =
        await provider.accepterReservation(
      reservationId: reservation.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _traitement = false;
    });

    _afficherResultat(
      succes: succes,
      messageSucces:
          'La réservation a été acceptée.',
      messageErreur:
          provider.messageErreur,
    );
  }

  Future<void> _refuser() async {
    if (_traitement) {
      return;
    }

    final confirmation =
        await _demanderConfirmation(
      titre: 'Refuser la réservation',
      message:
          'Voulez-vous vraiment refuser cette demande '
          'pour le trajet ${reservation.lieuDepart} → '
          '${reservation.lieuArrivee} ?',
      texteConfirmation: 'Refuser',
      actionDangereuse: true,
    );

    if (!confirmation || !mounted) {
      return;
    }

    setState(() {
      _traitement = true;
    });

    final provider =
        context.read<ReservationProvider>();

    final succes =
        await provider.refuserReservation(
      reservationId: reservation.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _traitement = false;
    });

    _afficherResultat(
      succes: succes,
      messageSucces:
          'La réservation a été refusée.',
      messageErreur:
          provider.messageErreur,
    );
  }

  void _afficherResultat({
    required bool succes,
    required String messageSucces,
    String? messageErreur,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            succes
                ? messageSucces
                : messageErreur ??
                    'Une erreur est survenue.',
          ),
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: succes
              ? Colors.green
              : Theme.of(context)
                  .colorScheme
                  .error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final estEnAttente =
        reservation.statut == 'en_attente';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                  child: Icon(
                    Icons.route_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${reservation.lieuDepart} → '
                    '${reservation.lieuArrivee}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InformationReservation(
              icone:
                  Icons.calendar_today_outlined,
              texte: reservation.dateDepart,
            ),
            const SizedBox(height: 10),
            _InformationReservation(
              icone: Icons.access_time_outlined,
              texte: reservation.heureDepart,
            ),
            const SizedBox(height: 10),
            _InformationReservation(
              icone: Icons.event_seat_outlined,
              texte:
                  '${reservation.nombrePlaces} place(s)',
            ),
            const SizedBox(height: 16),
            DriverStatusBadge(
              statut: reservation.statut,
            ),
            if (estEnAttente) ...[
              const SizedBox(height: 20),
              if (_traitement)
                const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed: _refuser,
                        icon: const Icon(
                          Icons.close,
                        ),
                        label: const Text(
                          'Refuser',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          FilledButton.icon(
                        onPressed: _accepter,
                        icon: const Icon(
                          Icons.check,
                        ),
                        label: const Text(
                          'Accepter',
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InformationReservation
    extends StatelessWidget {
  const _InformationReservation({
    required this.icone,
    required this.texte,
  });

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icone,
          size: 19,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texte,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ),
      ],
    );
  }
}

class DriverStatusBadge
    extends StatelessWidget {
  const DriverStatusBadge({
    super.key,
    required this.statut,
  });

  final String statut;

  @override
  Widget build(BuildContext context) {
    final informations =
        _obtenirInformationsStatut();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: informations.couleur
            .withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: informations.couleur,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            informations.icone,
            size: 16,
            color: informations.couleur,
          ),
          const SizedBox(width: 6),
          Text(
            informations.libelle,
            style: TextStyle(
              color: informations.couleur,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  _InformationsStatut
      _obtenirInformationsStatut() {
    switch (statut.toLowerCase()) {
      case 'acceptee':
      case 'acceptée':
        return const _InformationsStatut(
          libelle: 'Acceptée',
          couleur: Colors.green,
          icone: Icons.check_circle_outline,
        );

      case 'refusee':
      case 'refusée':
        return const _InformationsStatut(
          libelle: 'Refusée',
          couleur: Colors.red,
          icone: Icons.cancel_outlined,
        );

      case 'annulee':
      case 'annulée':
        return const _InformationsStatut(
          libelle: 'Annulée',
          couleur: Colors.grey,
          icone: Icons.block_outlined,
        );

      case 'en_attente':
      default:
        return const _InformationsStatut(
          libelle: 'En attente',
          couleur: Colors.orange,
          icone: Icons.schedule_outlined,
        );
    }
  }
}

class _InformationsStatut {
  const _InformationsStatut({
    required this.libelle,
    required this.couleur,
    required this.icone,
  });

  final String libelle;
  final Color couleur;
  final IconData icone;
}