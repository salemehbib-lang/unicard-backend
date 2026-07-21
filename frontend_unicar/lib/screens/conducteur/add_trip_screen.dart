import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vehicule.dart';
import '../../providers/trajet_provider.dart';
import '../../providers/vehicule_provider.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() =>
      _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombrePlacesController =
      TextEditingController();

  final _prixController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final List<String> _villes = const [
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Nouakchott',
    'Rosso',
  ];

  int? _vehiculeSelectionneId;

  String? _villeDepart;
  String? _villeArrivee;

  DateTime? _dateDepart;
  TimeOfDay? _heureDepart;

  bool _vehiculesCharges = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_vehiculesCharges) {
      _vehiculesCharges = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<VehicleProvider>()
            .recupererVehicules();
      });
    }
  }

  @override
  void dispose() {
    _nombrePlacesController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectionnerDate() async {
    final maintenant = DateTime.now();

    final dateChoisie = await showDatePicker(
      context: context,
      initialDate: _dateDepart ?? maintenant,
      firstDate: DateTime(
        maintenant.year,
        maintenant.month,
        maintenant.day,
      ),
      lastDate: DateTime(
        maintenant.year + 2,
      ),
      helpText: 'Choisir la date de départ',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (dateChoisie == null || !mounted) {
      return;
    }

    setState(() {
      _dateDepart = dateChoisie;
    });
  }

  Future<void> _selectionnerHeure() async {
    final heureChoisie = await showTimePicker(
      context: context,
      initialTime: _heureDepart ?? TimeOfDay.now(),
      helpText: 'Choisir l’heure de départ',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (heureChoisie == null || !mounted) {
      return;
    }

    setState(() {
      _heureDepart = heureChoisie;
    });
  }

  String _formaterDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');

    return '$jour/$mois/${date.year}';
  }

  String _formaterHeurePourApi(
    TimeOfDay heure,
  ) {
    final heures =
        heure.hour.toString().padLeft(2, '0');

    final minutes =
        heure.minute.toString().padLeft(2, '0');

    return '$heures:$minutes:00';
  }

  Future<void> _publierTrajet() async {
    FocusScope.of(context).unfocus();

    final formulaireValide =
        _formKey.currentState?.validate() ?? false;

    if (!formulaireValide) {
      return;
    }

    if (_vehiculeSelectionneId == null) {
      _afficherMessage(
        'Veuillez sélectionner un véhicule.',
        estErreur: true,
      );
      return;
    }

    if (_dateDepart == null) {
      _afficherMessage(
        'Veuillez sélectionner une date de départ.',
        estErreur: true,
      );
      return;
    }

    if (_heureDepart == null) {
      _afficherMessage(
        'Veuillez sélectionner une heure de départ.',
        estErreur: true,
      );
      return;
    }

    if (_villeDepart == _villeArrivee) {
      _afficherMessage(
        'La ville de départ et la ville d’arrivée doivent être différentes.',
        estErreur: true,
      );
      return;
    }

    final nombrePlaces = int.tryParse(
      _nombrePlacesController.text.trim(),
    );

    final prix = double.tryParse(
      _prixController.text
          .trim()
          .replaceAll(',', '.'),
    );

    if (nombrePlaces == null ||
        nombrePlaces <= 0) {
      _afficherMessage(
        'Le nombre de places est invalide.',
        estErreur: true,
      );
      return;
    }

    if (prix == null || prix <= 0) {
      _afficherMessage(
        'Le prix par place est invalide.',
        estErreur: true,
      );
      return;
    }

    final trajetProvider =
        context.read<TrajetProvider>();

    final succes =
        await trajetProvider.creerTrajet(
      vehiculeId: _vehiculeSelectionneId!,
      lieuDepart: _villeDepart!,
      lieuArrivee: _villeArrivee!,
      dateDepart: _dateDepart!,
      heureDepart:
          _formaterHeurePourApi(_heureDepart!),
      nombrePlacesDisponibles: nombrePlaces,
      prixParPlace: prix,
      description:
          _descriptionController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (!succes) {
      _afficherMessage(
        trajetProvider.messageErreur ??
            'Impossible de publier le trajet.',
        estErreur: true,
      );
      return;
    }

    _afficherMessage(
      trajetProvider.messageSucces ??
          'Le trajet a été publié avec succès.',
    );

    await Future<void>.delayed(
      const Duration(milliseconds: 500),
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Publier un trajet',
        ),
      ),
      body: Consumer2<
          VehicleProvider,
          TrajetProvider>(
        builder: (
          context,
          vehicleProvider,
          trajetProvider,
          child,
        ) {
          if (vehicleProvider.chargement) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (vehicleProvider.messageErreur != null &&
              vehicleProvider.vehicules.isEmpty) {
            return _construireErreurVehicules(
              vehicleProvider,
            );
          }

          final vehiculesActifs =
              vehicleProvider.vehiculesActifs;

          if (vehiculesActifs.isEmpty) {
            return _construireAbsenceVehicule();
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Informations du trajet',
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Renseignez les informations nécessaires pour proposer votre trajet.',
                      style:
                          theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    _construireChoixVehicule(
                      vehiculesActifs,
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _villeDepart,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Ville de départ',
                        prefixIcon: Icon(
                          Icons.trip_origin,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      items: _villes.map((ville) {
                        return DropdownMenuItem<
                            String>(
                          value: ville,
                          child: Text(ville),
                        );
                      }).toList(),
                      onChanged:
                          trajetProvider.operationEnCours
                              ? null
                              : (valeur) {
                                  setState(() {
                                    _villeDepart =
                                        valeur;

                                    if (_villeArrivee ==
                                        valeur) {
                                      _villeArrivee =
                                          null;
                                    }
                                  });
                                },
                      validator: (valeur) {
                        if (valeur == null ||
                            valeur.isEmpty) {
                          return 'Choisissez la ville de départ.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: _villeArrivee,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Ville d’arrivée',
                        prefixIcon: Icon(
                          Icons
                              .location_on_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      items: _villes
                          .where(
                            (ville) =>
                                ville != _villeDepart,
                          )
                          .map((ville) {
                        return DropdownMenuItem<
                            String>(
                          value: ville,
                          child: Text(ville),
                        );
                      }).toList(),
                      onChanged:
                          trajetProvider.operationEnCours
                              ? null
                              : (valeur) {
                                  setState(() {
                                    _villeArrivee =
                                        valeur;
                                  });
                                },
                      validator: (valeur) {
                        if (valeur == null ||
                            valeur.isEmpty) {
                          return 'Choisissez la ville d’arrivée.';
                        }

                        if (valeur == _villeDepart) {
                          return 'La ville d’arrivée doit être différente.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child:
                              _construireChampDate(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child:
                              _construireChampHeure(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _nombrePlacesController,
                      enabled: !trajetProvider
                          .operationEnCours,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Nombre de places',
                        prefixIcon: Icon(
                          Icons.event_seat_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (valeur) {
                        final nombre = int.tryParse(
                          valeur?.trim() ?? '',
                        );

                        if (nombre == null ||
                            nombre <= 0) {
                          return 'Entrez un nombre valide.';
                        }

                        if (nombre > 20) {
                          return 'Le nombre de places est trop élevé.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _prixController,
                      enabled: !trajetProvider
                          .operationEnCours,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Prix par place',
                        hintText: 'Exemple : 3000',
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                        ),
                        suffixText: 'FCFA',
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (valeur) {
                        final prix =
                            double.tryParse(
                          (valeur ?? '')
                              .trim()
                              .replaceAll(',', '.'),
                        );

                        if (prix == null ||
                            prix <= 0) {
                          return 'Entrez un prix valide.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                          _descriptionController,
                      enabled: !trajetProvider
                          .operationEnCours,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 500,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Description facultative',
                        hintText:
                            'Ajoutez un point de rendez-vous ou une précision.',
                        prefixIcon: Icon(
                          Icons.description_outlined,
                        ),
                        alignLabelWithHint: true,
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: trajetProvider
                                .operationEnCours
                            ? null
                            : _publierTrajet,
                        icon: trajetProvider
                                .operationEnCours
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.add_road,
                              ),
                        label: Text(
                          trajetProvider
                                  .operationEnCours
                              ? 'Publication...'
                              : 'Publier le trajet',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _construireChoixVehicule(
    List<Vehicle> vehicules,
  ) {
    return DropdownButtonFormField<int>(
      initialValue: _vehiculeSelectionneId,
      decoration: const InputDecoration(
        labelText: 'Véhicule',
        prefixIcon: Icon(
          Icons.directions_car_outlined,
        ),
        border: OutlineInputBorder(),
      ),
      items: vehicules.map((vehicule) {
        return DropdownMenuItem<int>(
          value: vehicule.id,
          child: Text(
            '${vehicule.nomComplet} — ${vehicule.immatriculation}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (valeur) {
        setState(() {
          _vehiculeSelectionneId = valeur;
        });
      },
      validator: (valeur) {
        if (valeur == null) {
          return 'Choisissez un véhicule.';
        }

        return null;
      },
    );
  }

  Widget _construireChampDate() {
    return InkWell(
      onTap: _selectionnerDate,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
          ),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _dateDepart == null
              ? 'Choisir'
              : _formaterDate(_dateDepart!),
        ),
      ),
    );
  }

  Widget _construireChampHeure() {
    return InkWell(
      onTap: _selectionnerHeure,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Heure',
          prefixIcon: Icon(
            Icons.access_time,
          ),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _heureDepart == null
              ? 'Choisir'
              : _heureDepart!.format(context),
        ),
      ),
    );
  }

  Widget _construireErreurVehicules(
    VehicleProvider provider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              provider.messageErreur ??
                  'Impossible de charger les véhicules.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                provider.recupererVehicules();
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

  Widget _construireAbsenceVehicule() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_crash_outlined,
              size: 70,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun véhicule actif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous devez ajouter ou activer un véhicule avant de publier un trajet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back,
              ),
              label: const Text(
                'Retour aux véhicules',
              ),
            ),
          ],
        ),
      ),
    );
  }
}