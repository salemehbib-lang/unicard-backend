import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trajet.dart';
import '../../providers/trajet_provider.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() =>
      _MyTripsScreenState();
}

class _MyTripsScreenState
    extends State<MyTripsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TrajetProvider>()
          .chargerMesTrajets();
    });
  }

  Future<void> _actualiser() async {
    await context
        .read<TrajetProvider>()
        .chargerMesTrajets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes trajets',
        ),
        centerTitle: true,
      ),
      body: Consumer<TrajetProvider>(
        builder: (
          context,
          trajetProvider,
          child,
        ) {
          if (trajetProvider.chargement &&
              trajetProvider.trajets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (trajetProvider.messageErreur != null &&
              trajetProvider.trajets.isEmpty) {
            return _ErreurChargement(
              message:
                  trajetProvider.messageErreur!,
              onReessayer: _actualiser,
            );
          }

          if (trajetProvider.trajets.isEmpty) {
            return RefreshIndicator(
              onRefresh: _actualiser,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Icon(
                    Icons.route_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Aucun trajet publié',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les trajets que vous publierez apparaîtront ici.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _actualiser,
            child: ListView.separated(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  trajetProvider.trajets.length,
              separatorBuilder:
                  (context, index) {
                return const SizedBox(
                  height: 12,
                );
              },
              itemBuilder:
                  (context, index) {
                final trajet =
                    trajetProvider
                        .trajets[index];

                return _CarteTrajet(
                  trajet: trajet,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CarteTrajet
    extends StatelessWidget {
  const _CarteTrajet({
    required this.trajet,
  });

  final Trajet trajet;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${trajet.lieuDepart} → ${trajet.lieuArrivee}',
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                _BadgeStatut(
                  statut: trajet.statut,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _InformationTrajet(
              icon:
                  Icons.calendar_month_outlined,
              texte:
                  trajet.dateDepart,
            ),

            const SizedBox(height: 10),

            _InformationTrajet(
              icon:
                  Icons.access_time,
              texte:
                  trajet.heureDepart,
            ),

            const SizedBox(height: 10),

            _InformationTrajet(
              icon:
                  Icons.event_seat_outlined,
              texte:
                  '${trajet.nombrePlacesDisponibles} place(s) disponible(s)',
            ),

            const SizedBox(height: 10),

            _InformationTrajet(
              icon:
                  Icons.payments_outlined,
              texte:
                  '${trajet.prixParPlace} FCFA par place',
            ),

            if (trajet.description
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                trajet.description,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InformationTrajet
    extends StatelessWidget {
  const _InformationTrajet({
    required this.icon,
    required this.texte,
  });

  final IconData icon;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texte,
          ),
        ),
      ],
    );
  }
}

class _BadgeStatut
    extends StatelessWidget {
  const _BadgeStatut({
    required this.statut,
  });

  final String statut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        _statutLisible(
          statut,
        ),
        style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onPrimaryContainer,
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  String _statutLisible(
    String statut,
  ) {
    switch (statut) {
      case 'publie':
        return 'Publié';

      case 'complet':
        return 'Complet';

      case 'annule':
        return 'Annulé';

      case 'termine':
        return 'Terminé';

      default:
        return statut;
    }
  }
}

class _ErreurChargement
    extends StatelessWidget {
  const _ErreurChargement({
    required this.message,
    required this.onReessayer,
  });

  final String message;
  final Future<void> Function()
      onReessayer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () {
                onReessayer();
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Réessayer',
              ),
            ),
          ],
        ),
      ),
    );
  }
}