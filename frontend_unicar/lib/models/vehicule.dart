class Vehicle {
  final int id;
  final String proprietaire;
  final String marque;
  final String modele;
  final String immatriculation;
  final String couleur;
  final int nombrePlaces;
  final bool estActif;
  final DateTime? dateCreation;

  const Vehicle({
    required this.id,
    required this.proprietaire,
    required this.marque,
    required this.modele,
    required this.immatriculation,
    required this.couleur,
    required this.nombrePlaces,
    required this.estActif,
    this.dateCreation,
  });

  factory Vehicle.fromJson(
    Map<String, dynamic> json,
  ) {
    return Vehicle(
      id: _convertirEntier(json['id']),
      proprietaire:
          json['proprietaire']?.toString() ?? '',
      marque: json['marque']?.toString() ?? '',
      modele: json['modele']?.toString() ?? '',
      immatriculation:
          json['immatriculation']?.toString() ?? '',
      couleur: json['couleur']?.toString() ?? '',
      nombrePlaces:
          _convertirEntier(json['nombre_places']),
      estActif: _convertirBooleen(
        json['est_actif'],
      ),
      dateCreation: _convertirDate(
        json['date_creation'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proprietaire': proprietaire,
      'marque': marque,
      'modele': modele,
      'immatriculation': immatriculation,
      'couleur': couleur,
      'nombre_places': nombrePlaces,
      'est_actif': estActif,
      'date_creation':
          dateCreation?.toIso8601String(),
    };
  }

  String get nomComplet {
    return '$marque $modele'.trim();
  }

  Vehicle copyWith({
    int? id,
    String? proprietaire,
    String? marque,
    String? modele,
    String? immatriculation,
    String? couleur,
    int? nombrePlaces,
    bool? estActif,
    DateTime? dateCreation,
  }) {
    return Vehicle(
      id: id ?? this.id,
      proprietaire:
          proprietaire ?? this.proprietaire,
      marque: marque ?? this.marque,
      modele: modele ?? this.modele,
      immatriculation:
          immatriculation ?? this.immatriculation,
      couleur: couleur ?? this.couleur,
      nombrePlaces:
          nombrePlaces ?? this.nombrePlaces,
      estActif: estActif ?? this.estActif,
      dateCreation:
          dateCreation ?? this.dateCreation,
    );
  }

  static int _convertirEntier(dynamic valeur) {
    if (valeur is int) {
      return valeur;
    }

    return int.tryParse(
          valeur?.toString() ?? '',
        ) ??
        0;
  }

  static bool _convertirBooleen(
    dynamic valeur,
  ) {
    if (valeur is bool) {
      return valeur;
    }

    final texte =
        valeur?.toString().toLowerCase();

    return texte == 'true' ||
        texte == '1';
  }

  static DateTime? _convertirDate(
    dynamic valeur,
  ) {
    if (valeur == null) {
      return null;
    }

    return DateTime.tryParse(
      valeur.toString(),
    );
  }
}