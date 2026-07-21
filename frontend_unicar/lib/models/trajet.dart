class Trajet {
  final int id;
  final String conducteur;
  final String lieuDepart;
  final String lieuArrivee;
  final String dateDepart;
  final String heureDepart;
  final int nombrePlacesDisponibles;
  final String prixParPlace;
  final String description;
  final String statut;
  final String etat;

  const Trajet({
    required this.id,
    required this.conducteur,
    required this.lieuDepart,
    required this.lieuArrivee,
    required this.dateDepart,
    required this.heureDepart,
    required this.nombrePlacesDisponibles,
    required this.prixParPlace,
    required this.description,
    required this.statut,
    required this.etat,
  });

  factory Trajet.fromJson(
    Map<String, dynamic> json,
  ) {
    return Trajet(
      id: _convertirEntier(
        json['id'],
      ),
      conducteur: _convertirConducteur(
        json['conducteur'],
      ),
      lieuDepart:
          json['lieu_depart']?.toString() ?? '',
      lieuArrivee:
          json['lieu_arrivee']?.toString() ?? '',
      dateDepart:
          json['date_depart']?.toString() ?? '',
      heureDepart:
          json['heure_depart']?.toString() ?? '',
      nombrePlacesDisponibles:
          _convertirEntier(
        json['nombre_places_disponibles'],
      ),
      prixParPlace:
          json['prix_par_place']?.toString() ?? '0',
      description:
          json['description']?.toString() ?? '',
      statut:
          json['statut']?.toString() ?? '',
      etat:
          json['etat']?.toString() ??
          'en_attente_depart',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conducteur': conducteur,
      'lieu_depart': lieuDepart,
      'lieu_arrivee': lieuArrivee,
      'date_depart': dateDepart,
      'heure_depart': heureDepart,
      'nombre_places_disponibles':
          nombrePlacesDisponibles,
      'prix_par_place': prixParPlace,
      'description': description,
      'statut': statut,
      'etat': etat,
    };
  }

  Trajet copyWith({
    int? id,
    String? conducteur,
    String? lieuDepart,
    String? lieuArrivee,
    String? dateDepart,
    String? heureDepart,
    int? nombrePlacesDisponibles,
    String? prixParPlace,
    String? description,
    String? statut,
    String? etat,
  }) {
    return Trajet(
      id: id ?? this.id,
      conducteur:
          conducteur ?? this.conducteur,
      lieuDepart:
          lieuDepart ?? this.lieuDepart,
      lieuArrivee:
          lieuArrivee ?? this.lieuArrivee,
      dateDepart:
          dateDepart ?? this.dateDepart,
      heureDepart:
          heureDepart ?? this.heureDepart,
      nombrePlacesDisponibles:
          nombrePlacesDisponibles ??
              this.nombrePlacesDisponibles,
      prixParPlace:
          prixParPlace ?? this.prixParPlace,
      description:
          description ?? this.description,
      statut:
          statut ?? this.statut,
      etat:
          etat ?? this.etat,
    );
  }

  bool get estDisponible {
    final statutNormalise =
        statut.toLowerCase();

    return nombrePlacesDisponibles > 0 &&
        statutNormalise != 'annule' &&
        statutNormalise != 'annulee' &&
        statutNormalise != 'annulé' &&
        statutNormalise != 'annulée' &&
        statutNormalise != 'complet' &&
        statutNormalise != 'termine' &&
        statutNormalise != 'terminé';
  }

  String get trajetFormate {
    return '$lieuDepart → $lieuArrivee';
  }

  String get dateHeureFormatee {
    if (dateDepart.isEmpty &&
        heureDepart.isEmpty) {
      return '';
    }

    if (heureDepart.isEmpty) {
      return dateDepart;
    }

    if (dateDepart.isEmpty) {
      return heureDepart;
    }

    return '$dateDepart à $heureDepart';
  }

  String get etatLisible {
    switch (etat) {
      case 'en_attente_depart':
        return 'En attente du départ';

      case 'chauffeur_en_route':
        return 'Chauffeur en route';

      case 'chauffeur_arrive':
        return 'Chauffeur arrivé';

      case 'en_cours':
        return 'Trajet en cours';

      case 'termine':
        return 'Trajet terminé';

      default:
        return etat;
    }
  }

  String get statutLisible {
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

  static int _convertirEntier(
    dynamic valeur,
  ) {
    if (valeur is int) {
      return valeur;
    }

    if (valeur is double) {
      return valeur.toInt();
    }

    return int.tryParse(
          valeur?.toString() ?? '',
        ) ??
        0;
  }

  static String _convertirConducteur(
    dynamic valeur,
  ) {
    if (valeur == null) {
      return '';
    }

    if (valeur is String) {
      return valeur;
    }

    if (valeur is Map) {
      if (valeur['username'] != null) {
        return valeur['username'].toString();
      }

      if (valeur['nom_complet'] != null) {
        return valeur['nom_complet'].toString();
      }

      if (valeur['first_name'] != null ||
          valeur['last_name'] != null) {
        final prenom =
            valeur['first_name']
                    ?.toString() ??
                '';

        final nom =
            valeur['last_name']
                    ?.toString() ??
                '';

        return '$prenom $nom'.trim();
      }

      if (valeur['id'] != null) {
        return valeur['id'].toString();
      }
    }

    return valeur.toString();
  }

  @override
  String toString() {
    return 'Trajet('
        'id: $id, '
        'conducteur: $conducteur, '
        'depart: $lieuDepart, '
        'arrivee: $lieuArrivee, '
        'date: $dateDepart, '
        'heure: $heureDepart, '
        'places: $nombrePlacesDisponibles, '
        'prix: $prixParPlace, '
        'statut: $statut, '
        'etat: $etat'
        ')';
  }
}