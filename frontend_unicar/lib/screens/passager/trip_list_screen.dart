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

  static const Color _bleuPrincipal = Color(0xFF123A63);
  static const Color _bleuClair = Color(0xFFEAF3FC);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _fond = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    final trajetProvider = context.watch<TrajetProvider>();

    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: _bleuPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trajets disponibles',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _construireEntete(),

          Expanded(
            child: Builder(
              builder: (context) {
                if (trajetProvider.chargement) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _bleuPrincipal,
                    ),
                  );
                }

                if (trajetProvider.messageErreur != null) {
                  return _construireErreur(
                    context,
                    trajetProvider.messageErreur!,
                  );
                }

                if (trajetProvider.trajets.isEmpty) {
                  return _construireAucunTrajet();
                }

                return RefreshIndicator(
                  color: _bleuPrincipal,
                  onRefresh: () async {
                    await context
                        .read<TrajetProvider>()
                        .rechercherTrajets(
                          depart: depart,
                          arrivee: arrivee,
                        );
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      28,
                    ),
                    itemCount: trajetProvider.trajets.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final trajet =
                          trajetProvider.trajets[index];

                      return _TrajetCard(
                        trajet: trajet,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireEntete() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        color: _bleuPrincipal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre recherche',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.trip_origin_rounded,
                color: _orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  depart,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white70,
                ),
              ),
              const Icon(
                Icons.location_on_rounded,
                color: _orange,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  arrivee,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construireErreur(
    BuildContext context,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFECACA),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 58,
                color: Color(0xFFB42318),
              ),
              const SizedBox(height: 14),
              const Text(
                'Une erreur est survenue',
                style: TextStyle(
                  color: Color(0xFF1D2939),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () async {
                  await context
                      .read<TrajetProvider>()
                      .rechercherTrajets(
                        depart: depart,
                        arrivee: arrivee,
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _bleuPrincipal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireAucunTrajet() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFEAECF0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: _bleuClair,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  size: 44,
                  color: _bleuPrincipal,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Aucun trajet disponible',
                style: TextStyle(
                  color: Color(0xFF1D2939),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$depart → $arrivee',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Vous pouvez revenir plus tard ou modifier votre recherche.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrajetCard extends StatelessWidget {
  const _TrajetCard({
    required this.trajet,
  });

  final Trajet trajet;

  static const Color _bleuPrincipal = Color(0xFF123A63);
  static const Color _bleuClair = Color(0xFFEAF3FC);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFEAECF0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _bleuClair,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      color: _bleuPrincipal,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${trajet.lieuDepart} → ${trajet.lieuArrivee}',
                          style: const TextStyle(
                            color: Color(0xFF1D2939),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Trajet disponible',
                          style: TextStyle(
                            color: Color(0xFF12B76A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF98A2B3),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                height: 1,
                color: const Color(0xFFF2F4F7),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _InformationTrajet(
                      icon: Icons.calendar_today_outlined,
                      titre: 'Date',
                      valeur: trajet.dateDepart,
                    ),
                  ),
                  Expanded(
                    child: _InformationTrajet(
                      icon: Icons.access_time_rounded,
                      titre: 'Heure',
                      valeur: trajet.heureDepart,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _InformationTrajet(
                      icon: Icons.event_seat_outlined,
                      titre: 'Places',
                      valeur:
                          '${trajet.nombrePlacesDisponibles}',
                    ),
                  ),
                  Expanded(
                    child: _InformationTrajet(
                      icon: Icons.payments_outlined,
                      titre: 'Prix',
                      valeur: '${trajet.prixParPlace} FCFA',
                      valeurEnEvidence: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripDetailScreen(
                          trajet: trajet,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _bleuPrincipal,
                    side: const BorderSide(
                      color: _bleuPrincipal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 20,
                  ),
                  label: const Text(
                    'Voir les détails',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationTrajet extends StatelessWidget {
  const _InformationTrajet({
    required this.icon,
    required this.titre,
    required this.valeur,
    this.valeurEnEvidence = false,
  });

  final IconData icon;
  final String titre;
  final String valeur;
  final bool valeurEnEvidence;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF667085),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: const TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                valeur,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valeurEnEvidence
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF344054),
                  fontSize: 14,
                  fontWeight: valeurEnEvidence
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}