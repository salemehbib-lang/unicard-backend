import 'package:flutter/material.dart';

import '../../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState
    extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _marqueController =
      TextEditingController();
  final _modeleController =
      TextEditingController();
  final _immatriculationController =
      TextEditingController();
  final _couleurController =
      TextEditingController();
  final _nombrePlacesController =
      TextEditingController();

  final VehicleService _vehicleService =
      VehicleService();

  bool _estActif = true;
  bool _chargement = false;

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _immatriculationController.dispose();
    _couleurController.dispose();
    _nombrePlacesController.dispose();
    super.dispose();
  }

  Future<void> _ajouterVehicule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _chargement = true;
    });

    final resultat =
        await _vehicleService.ajouterVehicule(
      marque: _marqueController.text,
      modele: _modeleController.text,
      immatriculation:
          _immatriculationController.text,
      couleur: _couleurController.text,
      nombrePlaces: int.parse(
        _nombrePlacesController.text.trim(),
      ),
      estActif: _estActif,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _chargement = false;
    });

    final message =
        resultat['message']?.toString() ??
            'Une erreur est survenue.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            resultat['succes'] == true
                ? Colors.green
                : Colors.red,
      ),
    );

    if (resultat['succes'] == true) {
      Navigator.of(context).pop(true);
    }
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un véhicule',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.directions_car,
                  size: 80,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _marqueController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: _decoration(
                    label: 'Marque',
                    hint: 'Exemple : Toyota',
                    icon: Icons.directions_car,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Veuillez saisir la marque.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _modeleController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: _decoration(
                    label: 'Modèle',
                    hint: 'Exemple : Corolla',
                    icon: Icons.car_repair,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Veuillez saisir le modèle.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _immatriculationController,
                  textCapitalization:
                      TextCapitalization.characters,
                  decoration: _decoration(
                    label: 'Immatriculation',
                    hint: 'Exemple : AB-123-CD',
                    icon: Icons.pin,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Veuillez saisir l’immatriculation.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _couleurController,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: _decoration(
                    label: 'Couleur',
                    hint: 'Exemple : Noir',
                    icon: Icons.palette_outlined,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Veuillez saisir la couleur.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _nombrePlacesController,
                  keyboardType: TextInputType.number,
                  decoration: _decoration(
                    label: 'Nombre de places',
                    hint: 'Entre 2 et 20',
                    icon: Icons.event_seat,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Veuillez saisir le nombre de places.';
                    }

                    final nombre =
                        int.tryParse(value.trim());

                    if (nombre == null) {
                      return 'Veuillez saisir un nombre valide.';
                    }

                    if (nombre < 2) {
                      return 'Le véhicule doit avoir au moins deux places.';
                    }

                    if (nombre > 20) {
                      return 'Le nombre de places ne peut pas dépasser 20.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Véhicule actif',
                  ),
                  subtitle: Text(
                    _estActif
                        ? 'Le véhicule peut être utilisé pour publier un trajet.'
                        : 'Le véhicule ne pourra pas être utilisé.',
                  ),
                  value: _estActif,
                  onChanged: _chargement
                      ? null
                      : (value) {
                          setState(() {
                            _estActif = value;
                          });
                        },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _chargement
                        ? null
                        : _ajouterVehicule,
                    icon: _chargement
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _chargement
                          ? 'Enregistrement...'
                          : 'Enregistrer le véhicule',
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
}