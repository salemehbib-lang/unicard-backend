import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../conducteur/driver_main_screen.dart';
import '../passager/passenger_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _bleuPrincipal = Color(0xFF123A63);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _fond = Color(0xFFF5F7FA);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  bool _masquerMotDePasse = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    final formulaireValide =
        _formKey.currentState?.validate() ?? false;

    if (!formulaireValide) {
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

    Widget prochainePage;

    switch (authProvider.role) {
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
    Navigator.of(context).pushNamed('/inscription');
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
    final authProvider = context.watch<AuthProvider>();
    final hauteurEcran = MediaQuery.sizeOf(context).height;
    final ecranCompact = hauteurEcran < 760;

    return Scaffold(
      backgroundColor: _fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _construireEntete(
                ecranCompact: ecranCompact,
              ),
              Transform.translate(
                offset: const Offset(0, -12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
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
                        padding: EdgeInsets.fromLTRB(
                          20,
                          ecranCompact ? 18 : 22,
                          20,
                          ecranCompact ? 16 : 20,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Connexion',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF1D2939),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Connectez-vous pour accéder à votre espace UniCar.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(
                                height: ecranCompact ? 18 : 22,
                              ),
                              TextFormField(
                                controller: _usernameController,
                                enabled: !authProvider.chargement,
                                textInputAction:
                                    TextInputAction.next,
                                decoration: _decorationChamp(
                                  label: "Nom d'utilisateur",
                                  icon:
                                      Icons.person_outline_rounded,
                                ),
                                validator: (valeur) {
                                  if (valeur == null ||
                                      valeur.trim().isEmpty) {
                                    return "Veuillez saisir votre nom d'utilisateur.";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                enabled: !authProvider.chargement,
                                obscureText: _masquerMotDePasse,
                                textInputAction:
                                    TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (!authProvider.chargement) {
                                    _seConnecter();
                                  }
                                },
                                decoration: _decorationChamp(
                                  label: 'Mot de passe',
                                  icon:
                                      Icons.lock_outline_rounded,
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
                                      color:
                                          const Color(0xFF667085),
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
                              if (authProvider.messageErreur !=
                                  null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding:
                                      const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFFFF1F0),
                                    borderRadius:
                                        BorderRadius.circular(13),
                                    border: Border.all(
                                      color:
                                          const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons
                                            .error_outline_rounded,
                                        color:
                                            Color(0xFFB42318),
                                        size: 21,
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          authProvider
                                              .messageErreur!,
                                          style: const TextStyle(
                                            color:
                                                Color(0xFF912018),
                                            fontWeight:
                                                FontWeight.w500,
                                            fontSize: 13,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              SizedBox(
                                height: ecranCompact ? 17 : 20,
                              ),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                      authProvider.chargement
                                          ? null
                                          : _seConnecter,
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
                                  child:
                                      authProvider.chargement
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
                                                      .login_rounded,
                                                  size: 21,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Se connecter',
                                                  style:
                                                      TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight
                                                            .w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      "Vous n'avez pas de compte ?",
                                      style: TextStyle(
                                        color:
                                            Color(0xFF667085),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        authProvider.chargement
                                            ? null
                                            : _ouvrirInscription,
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          _bleuPrincipal,
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                    ),
                                    child: const Text(
                                      'Inscrivez-vous',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.w800,
                                        fontSize: 13,
                                      ),
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

  Widget _construireEntete({
    required bool ecranCompact,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18,
        ecranCompact ? 10 : 14,
        18,
        ecranCompact ? 27 : 32,
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
                height: ecranCompact ? 125 : 145,
                child: Image.asset(
                  'assets/images/hilux.jpeg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          SizedBox(
            height: ecranCompact ? 8 : 10,
          ),
          const Text(
            'UniCar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
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
