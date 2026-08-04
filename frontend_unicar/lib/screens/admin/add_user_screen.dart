import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() =>
      _AddUserScreenState();
}

class _AddUserScreenState
    extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController =
      TextEditingController();

  final _firstNameController =
      TextEditingController();

  final _lastNameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _telephoneController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _passwordConfirmationController =
      TextEditingController();

  String _role = 'passager';

  bool _masquerMotDePasse = true;
  bool _masquerConfirmation = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();

    super.dispose();
  }

  Future<void> _ajouterUtilisateur() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider =
        context.read<AdminProvider>();

    final succes =
        await provider.ajouterUtilisateur(
      username: _usernameController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      telephone: _telephoneController.text,
      role: _role,
      password: _passwordController.text,
      passwordConfirmation:
          _passwordConfirmationController.text,
    );

    if (!mounted) {
      return;
    }

    if (succes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            provider.messageSucces ??
                'Utilisateur ajouté avec succès.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          provider.messageErreur ??
              'Impossible d’ajouter l’utilisateur.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<AdminProvider>();

    final chargement =
        provider.ajoutUtilisateurEnCours;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Ajouter un utilisateur',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.05,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        backgroundColor:
                            Color(0xFFE3F2FD),
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: 38,
                          color: Color(0xFF1565C0),
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Nouvel utilisateur',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Renseignez les informations du nouveau compte.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextFormField(
                        controller:
                            _usernameController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            _decorationChamp(
                          label:
                              'Nom d’utilisateur',
                          icone:
                              Icons.person_outline,
                        ),
                        validator: (valeur) {
                          if (valeur == null ||
                              valeur.trim().isEmpty) {
                            return 'Veuillez saisir le nom d’utilisateur.';
                          }

                          if (valeur.trim().length < 3) {
                            return 'Le nom d’utilisateur doit contenir au moins 3 caractères.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller:
                            _firstNameController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            _decorationChamp(
                          label: 'Prénom',
                          icone:
                              Icons.badge_outlined,
                        ),
                        validator: (valeur) {
                          if (valeur == null ||
                              valeur.trim().isEmpty) {
                            return 'Veuillez saisir le prénom.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller:
                            _lastNameController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            _decorationChamp(
                          label: 'Nom',
                          icone:
                              Icons.badge_outlined,
                        ),
                        validator: (valeur) {
                          if (valeur == null ||
                              valeur.trim().isEmpty) {
                            return 'Veuillez saisir le nom.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller:
                            _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            _decorationChamp(
                          label: 'Adresse e-mail',
                          icone:
                              Icons.email_outlined,
                        ),
                        validator: (valeur) {
                          final email =
                              valeur?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Veuillez saisir l’adresse e-mail.';
                          }

                          if (!email.contains('@') ||
                              !email.contains('.')) {
                            return 'Veuillez saisir une adresse e-mail valide.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller:
                            _telephoneController,
                        keyboardType:
                            TextInputType.phone,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            _decorationChamp(
                          label: 'Téléphone',
                          icone:
                              Icons.phone_outlined,
                        ),
                        validator: (valeur) {
                          if (valeur == null ||
                              valeur.trim().isEmpty) {
                            return 'Veuillez saisir le numéro de téléphone.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        decoration:
                            _decorationChamp(
                          label: 'Rôle',
                          icone:
                              Icons.manage_accounts_outlined,
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
                          DropdownMenuItem(
                            value: 'administrateur',
                            child:
                                Text('Administrateur'),
                          ),
                        ],
                        onChanged: chargement
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

                      const SizedBox(height: 15),

                      TextFormField(
                        controller:
                            _passwordController,
                        obscureText:
                            _masquerMotDePasse,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            _decorationChamp(
                          label: 'Mot de passe',
                          icone:
                              Icons.lock_outline,
                        ).copyWith(
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
                        validator: (valeur) {
                          if (valeur == null ||
                              valeur.isEmpty) {
                            return 'Veuillez saisir le mot de passe.';
                          }

                          if (valeur.length < 8) {
                            return 'Le mot de passe doit contenir au moins 8 caractères.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      TextFormField(
                        controller:
                            _passwordConfirmationController,
                        obscureText:
                            _masquerConfirmation,
                        textInputAction:
                            TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!chargement) {
                            _ajouterUtilisateur();
                          }
                        },
                        decoration:
                            _decorationChamp(
                          label:
                              'Confirmation du mot de passe',
                          icone:
                              Icons.lock_reset_outlined,
                        ).copyWith(
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
                        validator: (valeur) {
                          if (valeur == null ||
                              valeur.isEmpty) {
                            return 'Veuillez confirmer le mot de passe.';
                          }

                          if (valeur !=
                              _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas.';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: chargement
                      ? null
                      : _ajouterUtilisateur,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1565C0),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  icon: chargement
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.person_add_alt_1,
                        ),
                  label: Text(
                    chargement
                        ? 'Ajout en cours...'
                        : 'Ajouter l’utilisateur',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: chargement
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decorationChamp({
    required String label,
    required IconData icone,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icone),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF1565C0),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }
}