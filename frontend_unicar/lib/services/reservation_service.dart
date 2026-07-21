import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/reservation.dart';
import '../utils/token_storage.dart';

class ReservationService {
  Future<Map<String, dynamic>> creerReservation({
    required int trajetId,
    required int nombrePlaces,
  }) async {
    final token = await TokenStorage.recupererAccessToken();

    if (token == null || token.isEmpty) {
      return {
        'succes': false,
        'message': 'Votre session a expiré. Veuillez vous reconnecter.',
      };
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.reservations),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'trajet': trajetId,
          'nombre_places': nombrePlaces,
        }),
      );

      dynamic donnees;

      try {
        donnees = jsonDecode(response.body);
      } catch (_) {
        donnees = null;
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          'succes': true,
          'message': 'Réservation envoyée avec succès.',
          'reservation': donnees,
        };
      }

      return {
        'succes': false,
        'message': _extraireMessageErreur(
          donnees,
          response.statusCode,
        ),
      };
    } catch (_) {
      return {
        'succes': false,
        'message': 'Impossible de contacter le serveur Django.',
      };
    }
  }

Future<List<Reservation>> recupererReservations() async {
  final token =
      await TokenStorage.recupererAccessToken();

  if (token == null || token.trim().isEmpty) {
    throw Exception(
      'Votre session a expiré. Veuillez vous reconnecter.',
    );
  }

  final uri = Uri.parse(
    ApiConfig.reservations,
  );

  try {
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.trim()}',
      },
    );

    debugPrint(
  'URL RESERVATIONS : $uri',
);

  debugPrint(
  'CODE RESERVATIONS : ${response.statusCode}',
);
  debugPrint(
  'REPONSE RESERVATIONS : ${response.body}',
);
    dynamic donnees;

    if (response.body.trim().isNotEmpty) {
      try {
        donnees = jsonDecode(
          response.body,
        );
      } catch (_) {
        throw Exception(
          'Le serveur a retourné une réponse invalide.',
        );
      }
    }

    if (response.statusCode == 200) {
      List<dynamic> listeBrute;

      if (donnees is List) {
        listeBrute = donnees;
      } else if (donnees is Map &&
          donnees['results'] is List) {
        listeBrute =
            donnees['results'] as List<dynamic>;
      } else if (donnees is Map &&
          donnees['reservations'] is List) {
        listeBrute =
            donnees['reservations']
                as List<dynamic>;
      } else {
        return [];
      }

      return listeBrute.map((element) {
        return Reservation.fromJson(
          Map<String, dynamic>.from(
            element as Map,
          ),
        );
      }).toList();
    }

    if (response.statusCode == 401) {
      String message =
          'Votre session a expiré. Veuillez vous reconnecter.';

      if (donnees is Map &&
          donnees['detail'] != null) {
        message =
            donnees['detail'].toString();
      }

      throw Exception(message);
    }

    throw Exception(
      _extraireMessageErreur(
        donnees,
        response.statusCode,
      ),
    );
  } catch (erreur) {
    throw Exception(
      erreur
          .toString()
          .replaceFirst(
            'Exception: ',
            '',
          ),
    );
  }
}
  Future<Map<String, dynamic>> annulerReservation({
  required int reservationId,
}) async {
  final token = await TokenStorage.recupererAccessToken();

  if (token == null || token.isEmpty) {
    return {
      'succes': false,
      'message': 'Votre session a expiré. Veuillez vous reconnecter.',
    };
  }

  final url =
      '${ApiConfig.reservations}$reservationId/annuler/';

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    dynamic donnees;

    try {
      donnees = jsonDecode(response.body);
    } catch (_) {
      donnees = null;
    }

    if (response.statusCode == 200) {
      return {
        'succes': true,
        'message': 'Réservation annulée avec succès.',
        'reservation': donnees,
      };
    }

    return {
      'succes': false,
      'message': _extraireMessageErreur(
        donnees,
        response.statusCode,
      ),
    };
  } catch (_) {
    return {
      'succes': false,
      'message': 'Impossible de contacter le serveur Django.',
    };
  }
}
Future<Map<String, dynamic>> accepterReservation({
  required int reservationId,
}) async {
  final token = await TokenStorage.recupererAccessToken();

  if (token == null || token.isEmpty) {
    return {
      'succes': false,
      'message': 'Votre session a expiré. Veuillez vous reconnecter.',
    };
  }

  final url =
      '${ApiConfig.reservations}$reservationId/accepter/';

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    dynamic donnees;

    try {
      donnees = jsonDecode(response.body);
    } catch (_) {
      donnees = null;
    }

    if (response.statusCode == 200) {
      return {
        'succes': true,
        'message': 'Réservation acceptée avec succès.',
        'reservation': donnees,
      };
    }

    return {
      'succes': false,
      'message': _extraireMessageErreur(
        donnees,
        response.statusCode,
      ),
    };
  } catch (_) {
    return {
      'succes': false,
      'message': 'Impossible de contacter le serveur Django.',
    };
  }
}
Future<Map<String, dynamic>> refuserReservation({
  required int reservationId,
}) async {
  final token = await TokenStorage.recupererAccessToken();

  if (token == null || token.isEmpty) {
    return {
      'succes': false,
      'message': 'Votre session a expiré. Veuillez vous reconnecter.',
    };
  }

  final url =
      '${ApiConfig.reservations}$reservationId/refuser/';

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    dynamic donnees;

    try {
      donnees = jsonDecode(response.body);
    } catch (_) {
      donnees = null;
    }

    if (response.statusCode == 200) {
      return {
        'succes': true,
        'message': 'Réservation refusée.',
        'reservation': donnees,
      };
    }

    return {
      'succes': false,
      'message': _extraireMessageErreur(
        donnees,
        response.statusCode,
      ),
    };
  } catch (_) {
    return {
      'succes': false,
      'message': 'Impossible de contacter le serveur Django.',
    };
  }
}

  String _extraireMessageErreur(
    dynamic donnees,
    int codeStatut,
  ) {
    if (donnees is Map<String, dynamic>) {
      if (donnees['detail'] != null) {
        return donnees['detail'].toString();
      }

      if (donnees['message'] != null) {
        return donnees['message'].toString();
      }

      if (donnees['non_field_errors'] is List &&
          (donnees['non_field_errors'] as List).isNotEmpty) {
        return (donnees['non_field_errors'] as List)
            .first
            .toString();
      }

      for (final valeur in donnees.values) {
        if (valeur is List && valeur.isNotEmpty) {
          return valeur.first.toString();
        }

        if (valeur is String && valeur.isNotEmpty) {
          return valeur;
        }
      }
    }

    return 'La réservation a échoué. Code : $codeStatut';
  }
}