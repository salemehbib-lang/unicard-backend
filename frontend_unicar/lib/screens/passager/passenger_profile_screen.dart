import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../profil/edit_profile_screen.dart';
import '../profil/change_password_screen.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() =>
      _PassengerProfileScreenState();
}

class _PassengerProfileScreenState
    extends State<PassengerProfileScreen> {
  final ProfileService _profileService = ProfileService();

  Map<String, dynamic>? _profil;
  bool _chargement = true;
  String? _messageErreur;

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    setState(() {
      _chargement = true;
      _messageErreur = null;
    });

    final resultat =
        await _profileService.recupererProfil();

    if (!mounted) {
      return;
    }

    setState(() {
      _chargement = false;

      if (resultat['succes'] == true) {
        _profil =
            Map<String, dynamic>.from(
          resultat['profil'],
        );
      } else {
        _messageErreur =
            resultat['message']?.toString() ??
                'Impossible de charger le profil.';
      }
    });
  }

  Future<void> _ouvrirModificationProfil() async {
    if (_profil == null) {
      return;
    }

    final profilModifie =
        await Navigator.of(context).push<
            Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          profil: _profil!,
        ),
      ),
    );

    if (!mounted || profilModifie == null) {
      return;
    }

    setState(() {
      _profil = profilModifie;
    });
  }

  String _valeurProfil(
    String cle, {
    String valeurParDefaut = 'Non renseigné',
  }) {
    final valeur = _profil?[cle]?.toString().trim();

    if (valeur == null || valeur.isEmpty) {
      return valeurParDefaut;
    }

    return valeur;
  }

  String _nomComplet() {
    final prenom = _valeurProfil(
      'first_name',
      valeurParDefaut: '',
    );

    final nom = _valeurProfil(
      'last_name',
      valeurParDefaut: '',
    );

    final nomComplet =
        '$prenom $nom'.trim();

    if (nomComplet.isNotEmpty) {
      return nomComplet;
    }

    return _valeurProfil(
      'username',
      valeurParDefaut: 'Utilisateur',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            onPressed:
                _profil == null
                    ? null
                    : _ouvrirModificationProfil,
            tooltip: 'Modifier le profil',
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ],
      ),
      body: _construireContenu(
        authProvider,
      ),
    );
  }

  Widget _construireContenu(
    AuthProvider authProvider,
  ) {
    if (_chargement) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_messageErreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                _messageErreur!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _chargerProfil,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _chargerProfil,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 48,
            child: Icon(
              Icons.person,
              size: 52,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nomComplet(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '@${_valeurProfil(
              'username',
              valeurParDefaut:
                  authProvider.username ??
                      'utilisateur',
            )}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Passager',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.email_outlined,
                  ),
                  title: const Text('E-mail'),
                  subtitle: Text(
                    _valeurProfil('email'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.phone_outlined,
                  ),
                  title: const Text('Téléphone'),
                  subtitle: Text(
                    _valeurProfil('telephone'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),
                  title: const Text(
                    'Modifier mes informations',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap:
                      _ouvrirModificationProfil,
                ),
                const Divider(height: 1),
                ListTile(
  leading: const Icon(
    Icons.lock_outline,
  ),
  title: const Text(
    'Changer le mot de passe',
  ),
  trailing: const Icon(
    Icons.chevron_right,
  ),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  },
),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                  ),
                  title: const Text(
                    'Se déconnecter',
                  ),
                  onTap: () async {
                    await context
                        .read<AuthProvider>()
                        .deconnexion();

                    if (!mounted) {
                      return;
                    }

                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(
                      '/connexion',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}