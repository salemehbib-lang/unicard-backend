class AdminUtilisateur {
  const AdminUtilisateur({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.role,
    required this.roleAffiche,
    required this.estBloque,
    required this.estActif,
    required this.dateInscription,
    required this.derniereConnexion,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String telephone;
  final String role;
  final String roleAffiche;
  final bool estBloque;
  final bool estActif;
  final DateTime? dateInscription;
  final DateTime? derniereConnexion;

  factory AdminUtilisateur.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminUtilisateur(
      id: _convertirEntier(
        json['id'],
      ),
      username: (
        json['username'] ?? ''
      ).toString(),
      firstName: (
        json['first_name'] ?? ''
      ).toString(),
      lastName: (
        json['last_name'] ?? ''
      ).toString(),
      email: (
        json['email'] ?? ''
      ).toString(),
      telephone: (
        json['telephone'] ?? ''
      ).toString(),
      role: (
        json['role'] ?? ''
      ).toString(),
      roleAffiche: (
        json['role_affiche'] ??
        json['role'] ??
        ''
      ).toString(),
      estBloque: _convertirBooleen(
        json['est_bloque'],
      ),
      estActif: _convertirBooleen(
        json['is_active'],
        valeurParDefaut: true,
      ),
      dateInscription: _convertirDate(
        json['date_joined'],
      ),
      derniereConnexion: _convertirDate(
        json['last_login'],
      ),
    );
  }

  AdminUtilisateur copyWith({
    int? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? telephone,
    String? role,
    String? roleAffiche,
    bool? estBloque,
    bool? estActif,
    DateTime? dateInscription,
    DateTime? derniereConnexion,
  }) {
    return AdminUtilisateur(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      roleAffiche:
          roleAffiche ?? this.roleAffiche,
      estBloque:
          estBloque ?? this.estBloque,
      estActif:
          estActif ?? this.estActif,
      dateInscription:
          dateInscription ??
          this.dateInscription,
      derniereConnexion:
          derniereConnexion ??
          this.derniereConnexion,
    );
  }

  String get nomComplet {
    final nom = '$firstName $lastName'.trim();

    if (nom.isNotEmpty) {
      return nom;
    }

    return username;
  }

  String get statutAffiche {
    return estBloque
        ? 'Bloqué'
        : 'Actif';
  }

  static int _convertirEntier(
    dynamic valeur,
  ) {
    if (valeur is int) {
      return valeur;
    }

    return int.tryParse(
          valeur?.toString() ?? '',
        ) ??
        0;
  }

  static bool _convertirBooleen(
    dynamic valeur, {
    bool valeurParDefaut = false,
  }) {
    if (valeur is bool) {
      return valeur;
    }

    final valeurNormalisee = valeur
        ?.toString()
        .toLowerCase()
        .trim();

    if (valeurNormalisee == 'true' ||
        valeurNormalisee == '1') {
      return true;
    }

    if (valeurNormalisee == 'false' ||
        valeurNormalisee == '0') {
      return false;
    }

    return valeurParDefaut;
  }

  static DateTime? _convertirDate(
    dynamic valeur,
  ) {
    if (valeur == null) {
      return null;
    }

    final texte = valeur.toString();

    if (texte.isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      texte,
    );
  }
}