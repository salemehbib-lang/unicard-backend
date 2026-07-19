import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../passager/passenger_main_screen.dart';
import '../conducteur/driver_main_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _masquerMotDePasse = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    final succes = await authProvider.connexion(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || !succes) {
      return;
    }

    final role = authProvider.role;

    Widget prochainePage;

    switch (role) {
      case 'conducteur':
        prochainePage = const DriverMainScreen();
        break;

      case 'administrateur':
        prochainePage = const AdminDashboardScreen();
        break;

      case 'passager':
      default:
        prochainePage = const PassengerMainScreen();
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => prochainePage,
      ),
      (route) => false,
    );
  }

  void _ouvrirInscription() {
    Navigator.of(context).pushNamed(
      '/inscription',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 80,
                      color: Colors.green,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'UniCar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Connectez-vous à votre compte',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _usernameController,
                      enabled:
                          !authProvider.chargement,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Nom d'utilisateur",
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (valeur) {
                        if (valeur == null ||
                            valeur.trim().isEmpty) {
                          return "Veuillez saisir votre nom d'utilisateur.";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      enabled:
                          !authProvider.chargement,
                      obscureText:
                          _masquerMotDePasse,
                      textInputAction:
                          TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!authProvider
                            .chargement) {
                          _seConnecter();
                        }
                      },
                      decoration: InputDecoration(
                        labelText:
                            'Mot de passe',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        border:
                            const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed:
                              authProvider.chargement
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
                          ),
                        ),
                      ),
                      validator: (valeur) {
                        if (valeur == null ||
                            valeur.isEmpty) {
                          return 'Veuillez saisir votre mot de passe.';
                        }

                        return null;
                      },
                    ),

                    if (authProvider
                            .messageErreur !=
                        null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          authProvider
                              .messageErreur!,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                            authProvider.chargement
                                ? null
                                : _seConnecter,
                        child:
                            authProvider.chargement
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          3,
                                    ),
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Vous n'avez pas de compte ?",
                        ),
                        TextButton(
                          onPressed:
                              authProvider.chargement
                                  ? null
                                  : _ouvrirInscription,
                          child: const Text(
                            'Inscrivez-vous',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}