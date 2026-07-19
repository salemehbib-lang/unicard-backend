import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _usernameController = TextEditingController();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  String _role = 'passager';

  bool _chargement = false;
  bool _masquerMotDePasse = true;
  bool _masquerConfirmation = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _inscrire() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _chargement = true;
    });

    final resultat = await _authService.inscription(
      username: _usernameController.text,
      firstName: _prenomController.text,
      lastName: _nomController.text,
      email: _emailController.text,
      telephone: _telephoneController.text,
      role: _role,
      password: _passwordController.text,
      passwordConfirmation:
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
          behavior: SnackBarBehavior.floating,
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
            size: 52,
            color: Colors.green,
          ),
          title: const Text(
            'Compte créé',
          ),
          content: Text(
            '$message\n\nVous pouvez maintenant vous connecter.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Se connecter',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  String? _validerEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Saisissez votre adresse e-mail.';
    }

    final formatEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!formatEmail.hasMatch(email)) {
      return 'Saisissez une adresse e-mail valide.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créer un compte',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 72,
                ),
                const SizedBox(height: 12),
                Text(
                  'Rejoignez UniCar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Créez votre compte en quelques étapes.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                TextFormField(
                  controller: _usernameController,
                  textInputAction:
                      TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nom d’utilisateur',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final username =
                        value?.trim() ?? '';

                    if (username.isEmpty) {
                      return 'Saisissez un nom d’utilisateur.';
                    }

                    if (username.length < 3) {
                      return 'Le nom d’utilisateur doit contenir au moins 3 caractères.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _prenomController,
                  textInputAction:
                      TextInputAction.next,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Saisissez votre prénom.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _nomController,
                  textInputAction:
                      TextInputAction.next,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Saisissez votre nom.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: _validerEmail,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _telephoneController,
                  keyboardType:
                      TextInputType.phone,
                  textInputAction:
                      TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final telephone =
                        value?.trim() ?? '';

                    if (telephone.isEmpty) {
                      return 'Saisissez votre numéro de téléphone.';
                    }

                    if (telephone.length < 8) {
                      return 'Le numéro de téléphone est trop court.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'Type de compte',
                    prefixIcon: Icon(
                      Icons.groups_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'passager',
                      child: Text('Passager'),
                    ),
                    DropdownMenuItem(
                      value: 'conducteur',
                      child: Text('Conducteur'),
                    ),
                  ],
                  onChanged: _chargement
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _role = value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText:
                      _masquerMotDePasse,
                  textInputAction:
                      TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _masquerMotDePasse =
                              !_masquerMotDePasse;
                        });
                      },
                      icon: Icon(
                        _masquerMotDePasse
                            ? Icons.visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Saisissez un mot de passe.';
                    }

                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères.';
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
                      _inscrire();
                    }
                  },
                  decoration: InputDecoration(
                    labelText:
                        'Confirmer le mot de passe',
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
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Confirmez votre mot de passe.';
                    }

                    if (value !=
                        _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed:
                        _chargement ? null : _inscrire,
                    icon: _chargement
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.person_add_outlined,
                          ),
                    label: Text(
                      _chargement
                          ? 'Création du compte...'
                          : 'Créer mon compte',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
  onPressed: _chargement
      ? null
      : () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/connexion',
            (route) => false,
          );
        },
  child: const Text(
    'Vous avez déjà un compte ? Connectez-vous',
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