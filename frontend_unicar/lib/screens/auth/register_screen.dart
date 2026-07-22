import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _bleuPrincipal = Color(0xFF123A63);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _fond = Color(0xFFF5F7FA);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController =
      TextEditingController();
  final TextEditingController _prenomController =
      TextEditingController();
  final TextEditingController _nomController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _telephoneController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmationController =
      TextEditingController();

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
    final formulaireValide =
        _formKey.currentState?.validate() ?? false;

    if (!formulaireValide) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _chargement = true;
    });

    final resultat = await _authService.inscription(
      username: _usernameController.text.trim(),
      firstName: _prenomController.text.trim(),
      lastName: _nomController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telephoneController.text.trim(),
      role: _role,
      password: _passwordController.text,
      passwordConfirmation: _confirmationController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _chargement = false;
    });

    final bool succes = resultat['succes'] == true;
    final String message =
        resultat['message']?.toString() ??
        'Une erreur est survenue.';

    if (!succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB42318),
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
            Icons.check_circle_rounded,
            size: 54,
            color: Color(0xFF16A34A),
          ),
          title: const Text(
            'Compte créé',
            textAlign: TextAlign.center,
          ),
          content: Text(
            '$message\n\nVous pouvez maintenant vous connecter.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Se connecter'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/connexion',
      (route) => false,
    );
  }

  String? _validerEmail(String? valeur) {
    final String email = valeur?.trim() ?? '';

    if (email.isEmpty) {
      return 'Saisissez votre adresse e-mail.';
    }

    final RegExp formatEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!formatEmail.hasMatch(email)) {
      return 'Saisissez une adresse e-mail valide.';
    }

    return null;
  }

  InputDecoration _decorationChamp({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: _bleuPrincipal,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _bleuPrincipal,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double largeur = MediaQuery.sizeOf(context).width;
    final bool petitEcran = largeur < 380;

    return Scaffold(
      backgroundColor: _fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _construireEntete(),
              Transform.translate(
                offset: const Offset(0, -14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 520,
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 6,
                      shadowColor:
                          Colors.black.withValues(alpha: 0.10),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          18,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Créer un compte',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1D2939),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Rejoignez UniCar en quelques étapes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: _usernameController,
                                enabled: !_chargement,
                                textInputAction:
                                    TextInputAction.next,
                                decoration: _decorationChamp(
                                  label: "Nom d'utilisateur",
                                  icon:
                                      Icons.person_outline_rounded,
                                ),
                                validator: (valeur) {
                                  final String username =
                                      valeur?.trim() ?? '';

                                  if (username.isEmpty) {
                                    return "Saisissez un nom d'utilisateur.";
                                  }

                                  if (username.length < 3) {
                                    return "Le nom d'utilisateur doit contenir au moins 3 caractères.";
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              if (petitEcran)
                                Column(
                                  children: [
                                    TextFormField(
                                      controller:
                                          _prenomController,
                                      enabled: !_chargement,
                                      textInputAction:
                                          TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration:
                                          _decorationChamp(
                                        label: 'Prénom',
                                        icon: Icons
                                            .badge_outlined,
                                      ),
                                      validator: (valeur) {
                                        if (valeur == null ||
                                            valeur
                                                .trim()
                                                .isEmpty) {
                                          return 'Saisissez votre prénom.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      controller: _nomController,
                                      enabled: !_chargement,
                                      textInputAction:
                                          TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration:
                                          _decorationChamp(
                                        label: 'Nom',
                                        icon: Icons
                                            .badge_outlined,
                                      ),
                                      validator: (valeur) {
                                        if (valeur == null ||
                                            valeur
                                                .trim()
                                                .isEmpty) {
                                          return 'Saisissez votre nom.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _prenomController,
                                        enabled: !_chargement,
                                        textInputAction:
                                            TextInputAction.next,
                                        textCapitalization:
                                            TextCapitalization
                                                .words,
                                        decoration:
                                            _decorationChamp(
                                          label: 'Prénom',
                                          icon: Icons
                                              .badge_outlined,
                                        ),
                                        validator: (valeur) {
                                          if (valeur == null ||
                                              valeur
                                                  .trim()
                                                  .isEmpty) {
                                            return 'Saisissez votre prénom.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _nomController,
                                        enabled: !_chargement,
                                        textInputAction:
                                            TextInputAction.next,
                                        textCapitalization:
                                            TextCapitalization
                                                .words,
                                        decoration:
                                            _decorationChamp(
                                          label: 'Nom',
                                          icon: Icons
                                              .badge_outlined,
                                        ),
                                        validator: (valeur) {
                                          if (valeur == null ||
                                              valeur
                                                  .trim()
                                                  .isEmpty) {
                                            return 'Saisissez votre nom.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _emailController,
                                enabled: !_chargement,
                                keyboardType:
                                    TextInputType.emailAddress,
                                textInputAction:
                                    TextInputAction.next,
                                decoration: _decorationChamp(
                                  label: 'Adresse e-mail',
                                  icon: Icons.email_outlined,
                                ),
                                validator: _validerEmail,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _telephoneController,
                                enabled: !_chargement,
                                keyboardType:
                                    TextInputType.phone,
                                textInputAction:
                                    TextInputAction.next,
                                decoration: _decorationChamp(
                                  label: 'Téléphone',
                                  icon: Icons.phone_outlined,
                                ),
                                validator: (valeur) {
                                  final String telephone =
                                      valeur?.trim() ?? '';

                                  if (telephone.isEmpty) {
                                    return 'Saisissez votre numéro de téléphone.';
                                  }

                                  if (telephone.length < 8) {
                                    return 'Le numéro de téléphone est trop court.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              DropdownButtonFormField<String>(
                                initialValue: _role,
                                decoration: _decorationChamp(
                                  label: 'Type de compte',
                                  icon: Icons.groups_outlined,
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
                                    : (valeur) {
                                        if (valeur == null) {
                                          return;
                                        }

                                        setState(() {
                                          _role = valeur;
                                        });
                                      },
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _passwordController,
                                enabled: !_chargement,
                                obscureText: _masquerMotDePasse,
                                textInputAction:
                                    TextInputAction.next,
                                decoration: _decorationChamp(
                                  label: 'Mot de passe',
                                  icon:
                                      Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    onPressed: _chargement
                                        ? null
                                        : () {
                                            setState(() {
                                              _masquerMotDePasse =
                                                  !_masquerMotDePasse;
                                            });
                                          },
                                    icon: Icon(
                                      _masquerMotDePasse
                                          ? Icons
                                              .visibility_outlined
                                          : Icons
                                              .visibility_off_outlined,
                                      color:
                                          const Color(0xFF667085),
                                    ),
                                  ),
                                ),
                                validator: (valeur) {
                                  if (valeur == null ||
                                      valeur.isEmpty) {
                                    return 'Saisissez un mot de passe.';
                                  }

                                  if (valeur.length < 8) {
                                    return 'Le mot de passe doit contenir au moins 8 caractères.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller:
                                    _confirmationController,
                                enabled: !_chargement,
                                obscureText:
                                    _masquerConfirmation,
                                textInputAction:
                                    TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (!_chargement) {
                                    _inscrire();
                                  }
                                },
                                decoration: _decorationChamp(
                                  label:
                                      'Confirmer le mot de passe',
                                  icon: Icons
                                      .verified_user_outlined,
                                  suffixIcon: IconButton(
                                    onPressed: _chargement
                                        ? null
                                        : () {
                                            setState(() {
                                              _masquerConfirmation =
                                                  !_masquerConfirmation;
                                            });
                                          },
                                    icon: Icon(
                                      _masquerConfirmation
                                          ? Icons
                                              .visibility_outlined
                                          : Icons
                                              .visibility_off_outlined,
                                      color:
                                          const Color(0xFF667085),
                                    ),
                                  ),
                                ),
                                validator: (valeur) {
                                  if (valeur == null ||
                                      valeur.isEmpty) {
                                    return 'Confirmez votre mot de passe.';
                                  }

                                  if (valeur !=
                                      _passwordController.text) {
                                    return 'Les mots de passe ne correspondent pas.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      _chargement ? null : _inscrire,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor: _orange,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        _orange.withValues(
                                      alpha: 0.55,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _chargement
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .person_add_alt_1_rounded,
                                              size: 21,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Créer mon compte',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              TextButton(
                                onPressed: _chargement
                                    ? null
                                    : () {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          '/connexion',
                                          (route) => false,
                                        );
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      _bleuPrincipal,
                                ),
                                child: const Text(
                                  'Vous avez déjà un compte ? Connectez-vous',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  14,
                ),
                child: Text(
                  'Voyagez ensemble, économisez davantage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireEntete() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        30,
      ),
      decoration: const BoxDecoration(
        color: _bleuPrincipal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 390,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: double.infinity,
                height: 115,
                child: Image.asset(
                  'assets/images/hilux.jpeg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'UniCar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Votre trajet, notre communauté',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.route_rounded,
                  color: _orange,
                  size: 17,
                ),
                SizedBox(width: 6),
                Text(
                  'Sénégal • Mauritanie',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
