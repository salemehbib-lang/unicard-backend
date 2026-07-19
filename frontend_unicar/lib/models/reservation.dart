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
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final trajetDetails =
        json['trajet_details'] is Map<String, dynamic>
            ? json['trajet_details'] as Map<String, dynamic>
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
    );
  }
}