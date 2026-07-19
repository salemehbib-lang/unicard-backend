import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  final _ancienController = TextEditingController();
  final _nouveauController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _chargement = false;
  bool _masquerAncien = true;
  bool _masquerNouveau = true;
  bool _masquerConfirmation = true;

  @override
  void dispose() {
    _ancienController.dispose();
    _nouveauController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _changerMotDePasse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _chargement = true;
    });

    final resultat =
        await _profileService.changerMotDePasse(
      ancienMotDePasse: _ancienController.text,
      nouveauMotDePasse: _nouveauController.text,
      confirmationMotDePasse:
          _confirmationController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _chargement = false;
    });

    final succes = resultat['succes'] == true;

    final message =
        resultat['message']?.toString() ??
            'Une erreur est survenue.';

    if (!succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 50,
          ),
          title: const Text(
            'Mot de passe modifié',
          ),
          content: Text(
            message,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Se reconnecter',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    await context.read<AuthProvider>().deconnexion();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/connexion',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Changer le mot de passe',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.lock_reset,
                  size: 72,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Après la modification, vous devrez vous reconnecter.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _ancienController,
                  obscureText: _masquerAncien,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Ancien mot de passe',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _masquerAncien =
                              !_masquerAncien;
                        });
                      },
                      icon: Icon(
                        _masquerAncien
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Saisissez votre ancien mot de passe.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _nouveauController,
                  obscureText: _masquerNouveau,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: const Icon(
                      Icons.password_outlined,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _masquerNouveau =
                              !_masquerNouveau;
                        });
                      },
                      icon: Icon(
                        _masquerNouveau
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Saisissez un nouveau mot de passe.';
                    }

                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères.';
                    }

                    if (value ==
                        _ancienController.text) {
                      return 'Le nouveau mot de passe doit être différent.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      _confirmationController,
                  obscureText:
                      _masquerConfirmation,
                  textInputAction:
                      TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_chargement) {
                      _changerMotDePasse();
                    }
                  },
                  decoration: InputDecoration(
                    labelText:
                        'Confirmer le nouveau mot de passe',
                    prefixIcon: const Icon(
                      Icons.verified_user_outlined,
                    ),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _masquerConfirmation =
                              !_masquerConfirmation;
                        });
                      },
                      icon: Icon(
                        _masquerConfirmation
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Confirmez le nouveau mot de passe.';
                    }

                    if (value !=
                        _nouveauController.text) {
                      return 'Les mots de passe ne correspondent pas.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _chargement
                        ? null
                        : _changerMotDePasse,
                    icon: _chargement
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.lock_reset,
                          ),
                    label: Text(
                      _chargement
                          ? 'Modification...'
                          : 'Modifier le mot de passe',
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