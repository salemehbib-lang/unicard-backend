import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';

class PointRendezVousScreen extends StatefulWidget {
  const PointRendezVousScreen({
    super.key,
    required this.reservation,
  });

  final Reservation reservation;

  @override
  State<PointRendezVousScreen> createState() =>
      _PointRendezVousScreenState();
}

class _PointRendezVousScreenState
    extends State<PointRendezVousScreen> {
  final MapController _mapController = MapController();

  final TextEditingController _adresseController =
      TextEditingController();

  LatLng? _pointSelectionne;

  bool _chargementPosition = false;
  bool _chargementAdresse = false;

  static const LatLng _positionInitiale = LatLng(
    14.7167,
    -17.4677,
  );

  @override
  void initState() {
    super.initState();

    final latitude =
        widget.reservation.latitudeRendezVous;

    final longitude =
        widget.reservation.longitudeRendezVous;

    final adresse =
        widget.reservation.adresseRendezVous?.trim();

    if (latitude != null && longitude != null) {
      _pointSelectionne = LatLng(
        latitude,
        longitude,
      );
    }

    if (adresse != null && adresse.isNotEmpty) {
      _adresseController.text = adresse;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pointSelectionne == null) {
        return;
      }

      _mapController.move(
        _pointSelectionne!,
        16,
      );
    });
  }

  @override
  void dispose() {
    _adresseController.dispose();
    super.dispose();
  }

  Future<String> _recupererAdresseDepuisCoordonnees(
    LatLng point,
  ) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'format': 'jsonv2',
        'lat': point.latitude.toString(),
        'lon': point.longitude.toString(),
        'zoom': '18',
        'addressdetails': '1',
        'accept-language': 'fr',
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return _adresseCoordonnees(point);
      }

      final donnees = jsonDecode(
        response.body,
      );

      if (donnees is Map<String, dynamic>) {
        final adresse = donnees['display_name']
            ?.toString()
            .trim();

        if (adresse != null && adresse.isNotEmpty) {
          return adresse;
        }
      }

      return _adresseCoordonnees(point);
    } catch (_) {
      return _adresseCoordonnees(point);
    }
  }

  String _adresseCoordonnees(
    LatLng point,
  ) {
    return (
      'Position sélectionnée : '
      '${point.latitude.toStringAsFixed(6)}, '
      '${point.longitude.toStringAsFixed(6)}'
    );
  }

  Future<void> _mettreAJourAdresse(
    LatLng point,
  ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _chargementAdresse = true;
      _adresseController.text =
          'Recherche de l’adresse...';
    });

    final adresse =
        await _recupererAdresseDepuisCoordonnees(
      point,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _adresseController.text = adresse;
      _chargementAdresse = false;
    });
  }

  Future<void> _utiliserPositionActuelle() async {
    setState(() {
      _chargementPosition = true;
    });

    try {
      final serviceActive =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceActive) {
        if (!mounted) {
          return;
        }

        _afficherMessage(
          'Veuillez activer le service de localisation.',
        );

        return;
      }

      var permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) {
          return;
        }

        _afficherMessage(
          'L’autorisation de localisation a été refusée.',
        );

        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }

        _afficherMessage(
          'L’autorisation de localisation est refusée '
          'définitivement. Activez-la dans les paramètres.',
        );

        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      final point = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _pointSelectionne = point;
      });

      _mapController.move(
        point,
        16,
      );

      await _mettreAJourAdresse(
        point,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _afficherMessage(
        'Impossible de récupérer votre position.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _chargementPosition = false;
        });
      }
    }
  }

  Future<void> _selectionnerPoint(
    LatLng point,
  ) async {
    setState(() {
      _pointSelectionne = point;
    });

    await _mettreAJourAdresse(
      point,
    );
  }

  Future<void> _enregistrerPoint() async {
    final point = _pointSelectionne;

    final adresse =
        _adresseController.text.trim();

    if (point == null) {
      _afficherMessage(
        'Veuillez sélectionner un point sur la carte.',
      );

      return;
    }

    if (adresse.isEmpty ||
        adresse == 'Recherche de l’adresse...') {
      _afficherMessage(
        'Veuillez attendre la récupération de l’adresse.',
      );

      return;
    }

    final provider =
        context.read<ReservationProvider>();

    final succes =
        await provider.enregistrerPointRendezVous(
      reservationId: widget.reservation.id,
      adresse: adresse,
      latitude: double.parse(
        point.latitude.toStringAsFixed(6),
      ),
      longitude: double.parse(
        point.longitude.toStringAsFixed(6),
      ),
    );

    if (!mounted) {
      return;
    }

    if (!succes) {
      _afficherMessage(
        provider.messageErreur ??
            'Impossible d’enregistrer le point.',
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Point de rendez-vous enregistré avec succès.',
        ),
      ),
    );

    Navigator.of(context).pop(
      true,
    );
  }

  void _afficherMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centreInitial =
        _pointSelectionne ?? _positionInitiale;

    final zoomInitial =
        _pointSelectionne != null ? 16.0 : 12.0;

    return Consumer<ReservationProvider>(
      builder: (
        context,
        reservationProvider,
        child,
      ) {
        final enregistrementEnCours =
            reservationProvider.chargement;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.reservation.pointRendezVousConfirme
                  ? 'Modifier le point de rendez-vous'
                  : 'Point de rendez-vous',
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: centreInitial,
                    initialZoom: zoomInitial,
                    onTap: (
                      tapPosition,
                      point,
                    ) {
                      _selectionnerPoint(
                        point,
                      );
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.frontend_unicar',
                    ),
                    if (_pointSelectionne != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point:
                                _pointSelectionne!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              size: 45,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller:
                          _adresseController,
                      enabled:
                          !_chargementAdresse &&
                          !enregistrementEnCours,
                      decoration: InputDecoration(
                        labelText:
                            'Adresse ou point de repère',
                        hintText:
                            'L’adresse sera remplie automatiquement',
                        border:
                            const OutlineInputBorder(),
                        prefixIcon:
                            const Icon(
                          Icons.location_on_outlined,
                        ),
                        suffixIcon:
                            _chargementAdresse
                                ? const Padding(
                                    padding:
                                        EdgeInsets.all(
                                      12,
                                    ),
                                    child:
                                        SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            _chargementPosition ||
                                    enregistrementEnCours
                                ? null
                                : _utiliserPositionActuelle,
                        icon:
                            _chargementPosition
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                  ),
                        label: Text(
                          _chargementPosition
                              ? 'Localisation...'
                              : 'Utiliser ma position actuelle',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            enregistrementEnCours ||
                                    _chargementAdresse
                                ? null
                                : _enregistrerPoint,
                        icon:
                            enregistrementEnCours
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline,
                                  ),
                        label: Text(
                          enregistrementEnCours
                              ? 'Enregistrement...'
                              : widget.reservation
                                      .pointRendezVousConfirme
                                  ? 'Enregistrer les modifications'
                                  : 'Confirmer le point',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}