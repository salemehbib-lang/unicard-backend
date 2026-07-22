class Reservation {
  final int id;
  final int trajetId;

  final String lieuDepart;
  final String lieuArrivee;
  final String dateDepart;
  final String heureDepart;

  final int nombrePlaces;
  final String statut;
  final String dateReservation;

  // Informations conducteur
  final String? nomConducteur;
  final String? telephoneConducteur;

  // Informations passager
  final String? nomPassager;
  final String? telephonePassager;

  const Reservation({
    required this.id,
    required this.trajetId,
    required this.lieuDepart,
    required this.lieuArrivee,
    required this.dateDepart,
    required this.heureDepart,
    required this.nombrePlaces,
    required this.statut,
    required this.dateReservation,
    this.nomConducteur,
    this.telephoneConducteur,
    this.nomPassager,
    this.telephonePassager,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final trajetDetails =
        json['trajet_details'] is Map<String, dynamic>
            ? json['trajet_details'] as Map<String, dynamic>
            : <String, dynamic>{};

    final conducteurDetails =
        json['conducteur_details'] is Map<String, dynamic>
            ? json['conducteur_details'] as Map<String, dynamic>
            : <String, dynamic>{};

    final passagerDetails =
        json['passager_details'] is Map<String, dynamic>
            ? json['passager_details'] as Map<String, dynamic>
            : <String, dynamic>{};

    return Reservation(
      id: int.tryParse(json['id'].toString()) ?? 0,
      trajetId: int.tryParse(json['trajet'].toString()) ?? 0,

      lieuDepart:
          trajetDetails['lieu_depart']?.toString() ??
          json['lieu_depart']?.toString() ??
          '',

      lieuArrivee:
          trajetDetails['lieu_arrivee']?.toString() ??
          json['lieu_arrivee']?.toString() ??
          '',

      dateDepart:
          trajetDetails['date_depart']?.toString() ??
          json['date_depart']?.toString() ??
          '',

      heureDepart:
          trajetDetails['heure_depart']?.toString() ??
          json['heure_depart']?.toString() ??
          '',

      nombrePlaces:
          int.tryParse(json['nombre_places'].toString()) ?? 0,

      statut: json['statut']?.toString() ?? '',

      dateReservation:
          json['date_reservation']?.toString() ?? '',

      nomConducteur:
          conducteurDetails['nom_complet']?.toString(),

      telephoneConducteur:
          conducteurDetails['telephone']?.toString(),

      nomPassager:
          passagerDetails['nom_complet']?.toString(),

      telephonePassager:
          passagerDetails['telephone']?.toString(),
    );
  }

  bool get estAcceptee => statut == 'acceptee';

  bool get peutEtreAnnulee =>
      statut == 'en_attente' ||
      statut == 'acceptee';

  bool get informationsConducteurDisponibles {
    return estAcceptee &&
        nomConducteur != null &&
        nomConducteur!.trim().isNotEmpty;
  }

  bool get informationsPassagerDisponibles {
    return nomPassager != null &&
        nomPassager!.trim().isNotEmpty;
  }
}