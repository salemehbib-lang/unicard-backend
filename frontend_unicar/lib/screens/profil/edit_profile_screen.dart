import 'package:flutter/material.dart';

import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profil,
  });

  final Map<String, dynamic> profil;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _telephoneController;

  bool _chargement = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.profil['first_name']?.toString() ?? '',
    );

    _lastNameController = TextEditingController(
      text: widget.profil['last_name']?.toString() ?? '',
    );

    _emailController = TextEditingController(
      text: widget.profil['email']?.toString() ?? '',
    );

    _telephoneController = TextEditingController(
      text: widget.profil['telephone']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _modifierProfil() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _chargement = true;
    });

    final resultat = await _profileService.modifierProfil(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      telephone: _telephoneController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _chargement = false;
    });

    final succes = resultat['succes'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultat['message']?.toString() ??
              (succes
                  ? 'Profil modifié avec succès.'
                  : 'Une erreur est survenue.'),
        ),
      ),
    );

    if (succes) {
      Navigator.pop(
        context,
        resultat['profil'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre prénom.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre nom.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Veuillez saisir votre adresse e-mail.';
                    }

                    if (!email.contains('@') || !email.contains('.')) {
                      return 'Veuillez saisir une adresse e-mail valide.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre numéro de téléphone.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _chargement ? null : _modifierProfil,
                    icon: _chargement
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      _chargement
                          ? 'Enregistrement...'
                          : 'Enregistrer les modifications',
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