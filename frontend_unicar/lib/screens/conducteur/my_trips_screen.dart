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
  final Set<int> _trajetsEnModification = {};

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

  Future<void> _changerEtat(
    Trajet trajet,
    String nouvelEtat,
  ) async {
    if (_trajetsEnModification.contains(trajet.id)) {
      return;
    }

    final confirmation =
        await _demanderConfirmation(
      trajet: trajet,
      nouvelEtat: nouvelEtat,
    );

    if (!confirmation || !mounted) {
      return;
    }

    setState(() {
      _trajetsEnModification.add(
        trajet.id,
      );
    });

    final trajetProvider =
        context.read<TrajetProvider>();

    try {
      final succes =
          await trajetProvider.changerEtatTrajet(
        trajetId: trajet.id,
        nouvelEtat: nouvelEtat,
      );

      /*
       * On recharge toujours les trajets.
       * Ainsi, Flutter reste synchronisé avec Django,
       * même si la première requête a été acceptée
       * mais qu'une deuxième réponse a produit une erreur.
       */
      await trajetProvider.chargerMesTrajets();

      if (!mounted) {
        return;
      }

      if (!succes) {
        _afficherMessage(
          trajetProvider.messageErreur ??
              'Impossible de modifier l’état du trajet.',
          estErreur: true,
        );
        return;
      }

      _afficherMessage(
        trajetProvider.messageSucces ??
            'L’état du trajet a été modifié.',
      );
    } catch (erreur) {
      if (!mounted) {
        return;
      }

      _afficherMessage(
        erreur
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
        estErreur: true,
      );

      await trajetProvider.chargerMesTrajets();
    } finally {
      if (mounted) {
        setState(() {
          _trajetsEnModification.remove(
            trajet.id,
          );
        });
      }
    }
  }

  Future<void> _annulerTrajet(
    Trajet trajet,
  ) async {
    if (_trajetsEnModification.contains(trajet.id)) {
      return;
    }

    final confirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Annuler le trajet',
          ),
          content: Text(
            'Voulez-vous vraiment annuler le trajet '
            '${trajet.lieuDepart} → ${trajet.lieuArrivee} ?\n\n'
            'Les passagers concernés seront informés.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Retour',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Annuler le trajet',
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true || !mounted) {
      return;
    }

    setState(() {
      _trajetsEnModification.add(
        trajet.id,
      );
    });

    final trajetProvider =
        context.read<TrajetProvider>();

    try {
      final succes =
          await trajetProvider.annulerTrajet(
        trajetId: trajet.id,
      );

      await trajetProvider.chargerMesTrajets();

      if (!mounted) {
        return;
      }

      if (!succes) {
        _afficherMessage(
          trajetProvider.messageErreur ??
              'Impossible d’annuler le trajet.',
          estErreur: true,
        );
        return;
      }

      _afficherMessage(
        trajetProvider.messageSucces ??
            'Le trajet a été annulé avec succès.',
      );
    } catch (erreur) {
      if (!mounted) {
        return;
      }

      _afficherMessage(
        erreur
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
        estErreur: true,
      );

      await trajetProvider.chargerMesTrajets();
    } finally {
      if (mounted) {
        setState(() {
          _trajetsEnModification.remove(
            trajet.id,
          );
        });
      }
    }
  }

  Future<bool> _demanderConfirmation({
    required Trajet trajet,
    required String nouvelEtat,
  }) async {
    final action =
        _libelleAction(nouvelEtat);

    final resultat = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirmer l’action',
          ),
          content: Text(
            'Voulez-vous vraiment indiquer '
            '« $action » pour le trajet '
            '${trajet.lieuDepart} → '
            '${trajet.lieuArrivee} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Annuler',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Confirmer',
              ),
            ),
          ],
        );
      },
    );

    return resultat ?? false;
  }

  void _afficherMessage(
    String message, {
    bool estErreur = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              estErreur ? Colors.red : Colors.green,
        ),
      );
  }

  static String _libelleAction(
    String nouvelEtat,
  ) {
    switch (nouvelEtat) {
      case 'chauffeur_en_route':
        return 'Chauffeur en route';

      case 'chauffeur_arrive':
        return 'Chauffeur arrivé';

      case 'en_cours':
        return 'Trajet commencé';

      case 'termine':
        return 'Trajet terminé';

      default:
        return nouvelEtat;
    }
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
                  estEnModification:
                      _trajetsEnModification
                          .contains(trajet.id),
                  onChangerEtat: (
                    nouvelEtat,
                  ) {
                    _changerEtat(
                      trajet,
                      nouvelEtat,
                    );
                  },
                  onAnnulerTrajet: () {
                    _annulerTrajet(
                      trajet,
                    );
                  },
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
    required this.estEnModification,
    required this.onChangerEtat,
    required this.onAnnulerTrajet,
  });

  final Trajet trajet;
  final bool estEnModification;

  final void Function(
    String nouvelEtat,
  ) onChangerEtat;

  final VoidCallback onAnnulerTrajet;

  @override
  Widget build(BuildContext context) {
    final prochainEtat =
        _prochainEtat(
      trajet.etat,
    );

    final statutNormalise =
        trajet.statut.toLowerCase();

    final etatNormalise =
        trajet.etat.toLowerCase();

    final trajetAnnule =
        statutNormalise == 'annule' ||
            statutNormalise == 'annulee' ||
            statutNormalise == 'annulé' ||
            statutNormalise == 'annulée';

    final trajetTermine =
        statutNormalise == 'termine' ||
            statutNormalise == 'terminé' ||
            etatNormalise == 'termine' ||
            etatNormalise == 'terminé';

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
                    '${trajet.lieuDepart} → '
                    '${trajet.lieuArrivee}',
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
                  '${trajet.nombrePlacesDisponibles} '
                  'place(s) disponible(s)',
            ),

            const SizedBox(height: 10),

            _InformationTrajet(
              icon:
                  Icons.payments_outlined,
              texte:
                  '${trajet.prixParPlace} '
                  'FCFA par place',
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

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 21,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                const SizedBox(width: 10),
                const Text(
                  'État : ',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    trajet.etatLisible,
                  ),
                ),
              ],
            ),

            if (!trajetAnnule &&
                !trajetTermine &&
                prochainEtat != null) ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed:
                      estEnModification
                          ? null
                          : () {
                              onChangerEtat(
                                prochainEtat,
                              );
                            },
                  icon: estEnModification
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _iconeAction(
                            prochainEtat,
                          ),
                        ),
                  label: Text(
                    estEnModification
                        ? 'Modification...'
                        : _libelleBouton(
                            prochainEtat,
                          ),
                  ),
                ),
              ),
            ],

            if (!trajetAnnule &&
                !trajetTermine) ...[
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed:
                      estEnModification
                          ? null
                          : onAnnulerTrajet,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  icon: estEnModification
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.cancel_outlined,
                        ),
                  label: Text(
                    estEnModification
                        ? 'Annulation...'
                        : 'Annuler le trajet',
                  ),
                ),
              ),
            ],

            if (trajetAnnule) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ce trajet a été annulé.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (trajetTermine) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ce trajet est terminé.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight:
                            FontWeight.w600,
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

  static String? _prochainEtat(
    String etatActuel,
  ) {
    switch (etatActuel) {
      case 'en_attente_depart':
        return 'chauffeur_en_route';

      case 'chauffeur_en_route':
        return 'chauffeur_arrive';

      case 'chauffeur_arrive':
        return 'en_cours';

      case 'en_cours':
        return 'termine';

      case 'termine':
        return null;

      default:
        return null;
    }
  }

  static String _libelleBouton(
    String etat,
  ) {
    switch (etat) {
      case 'chauffeur_en_route':
        return 'Je suis en route';

      case 'chauffeur_arrive':
        return 'Je suis arrivé';

      case 'en_cours':
        return 'Commencer le trajet';

      case 'termine':
        return 'Terminer le trajet';

      default:
        return 'Changer l’état';
    }
  }

  static IconData _iconeAction(
    String etat,
  ) {
    switch (etat) {
      case 'chauffeur_en_route':
        return Icons.directions_car;

      case 'chauffeur_arrive':
        return Icons.location_on_outlined;

      case 'en_cours':
        return Icons.play_arrow;

      case 'termine':
        return Icons.check_circle_outline;

      default:
        return Icons.sync;
    }
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