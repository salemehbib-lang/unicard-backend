import 'package:flutter/material.dart';

import '../../models/vehicule.dart';
import '../../services/vehicle_service.dart';
import 'add_vehicle_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() {
    return _VehiclesScreenState();
  }
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleService _service = VehicleService();

  bool _chargement = true;
  List<Vehicle> _vehicules = [];

  @override
  void initState() {
    super.initState();
    _chargerVehicules();
  }

  Future<void> _chargerVehicules() async {
    if (mounted) {
      setState(() {
        _chargement = true;
      });
    }

    final resultat = await _service.recupererVehicules();

    if (!mounted) {
      return;
    }

    if (resultat['succes'] == true) {
      final donnees = resultat['vehicules'];

      final liste = donnees is List
          ? donnees
              .map(
                (element) => Vehicle.fromJson(
                  Map<String, dynamic>.from(element as Map),
                ),
              )
              .toList()
          : <Vehicle>[];

      setState(() {
        _vehicules = liste;
        _chargement = false;
      });
    } else {
      setState(() {
        _chargement = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultat['message']?.toString() ??
                'Impossible de récupérer les véhicules.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _ouvrirAjoutVehicule() async {
    final vehiculeAjoute =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AddVehicleScreen(),
      ),
    );

    if (vehiculeAjoute == true) {
      await _chargerVehicules();
    }
  }

  Color _couleurEtat(bool actif) {
    return actif ? Colors.green : Colors.red;
  }

  String _texteEtat(bool actif) {
    return actif ? 'Actif' : 'Inactif';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes véhicules'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirAjoutVehicule,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: RefreshIndicator(
        onRefresh: _chargerVehicules,
        child: _construireContenu(),
      ),
    );
  }

  Widget _construireContenu() {
    if (_chargement) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_vehicules.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Aucun véhicule enregistré.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Appuyez sur le bouton Ajouter pour enregistrer un véhicule.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _vehicules.length,
      itemBuilder: (context, index) {
        final vehicule = _vehicules[index];

        return _construireCarteVehicule(vehicule);
      },
    );
  }

  Widget _construireCarteVehicule(Vehicle vehicule) {
    final couleurEtat = _couleurEtat(vehicule.estActif);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 26,
              child: Icon(
                Icons.directions_car,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicule.marque} ${vehicule.modele}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Immatriculation : ${vehicule.immatriculation}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Couleur : ${vehicule.couleur}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nombre de places : ${vehicule.nombrePlaces}',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: couleurEtat.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: couleurEtat,
                      ),
                    ),
                    child: Text(
                      _texteEtat(vehicule.estActif),
                      style: TextStyle(
                        color: couleurEtat,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (valeur) {
                if (valeur == 'modifier') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La modification sera ajoutée ensuite.',
                      ),
                    ),
                  );
                }

                if (valeur == 'supprimer') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La suppression sera ajoutée ensuite.',
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<String>(
                    value: 'modifier',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'supprimer',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}