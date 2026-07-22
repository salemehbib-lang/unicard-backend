import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/trajet_provider.dart';
import '../auth/login_screen.dart';
import 'trip_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bleuPrincipal = Color(0xFF123A63);
  static const Color _bleuClair = Color(0xFFEAF3FC);
  static const Color _orange = Color(0xFFF59E0B);
  static const Color _fond = Color(0xFFF5F7FA);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _departController =
      TextEditingController();

  final TextEditingController _arriveeController =
      TextEditingController();

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  Future<void> _rechercher() async {
    final formulaireValide =
        _formKey.currentState?.validate() ?? false;

    if (!formulaireValide) {
      return;
    }

    FocusScope.of(context).unfocus();

    final depart = _departController.text.trim();
    final arrivee = _arriveeController.text.trim();

    if (depart.toLowerCase() == arrivee.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La ville de départ et la ville d’arrivée doivent être différentes.',
          ),
        ),
      );

      return;
    }

    final trajetProvider = context.read<TrajetProvider>();

    await trajetProvider.rechercherTrajets(
      depart: depart,
      arrivee: arrivee,
    );

    if (!mounted) {
      return;
    }

    if (trajetProvider.messageErreur != null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripListScreen(
          depart: depart,
          arrivee: arrivee,
        ),
      ),
    );
  }

  void _inverserTrajet() {
    final depart = _departController.text;
    final arrivee = _arriveeController.text;

    setState(() {
      _departController.text = arrivee;
      _arriveeController.text = depart;
    });
  }

  Future<void> _seDeconnecter() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: _bleuPrincipal,
              ),
              SizedBox(width: 10),
              Text('Déconnexion'),
            ],
          ),
          content: const Text(
            'Voulez-vous vraiment vous déconnecter de votre compte UniCar ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _bleuPrincipal,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );

    if (confirmation != true || !mounted) {
      return;
    }

    await context.read<AuthProvider>().deconnexion();

    if (!mounted) {
      return;
    }

    context.read<TrajetProvider>().viderTrajets();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  String? _validerVille(
    String? valeur,
    String champ,
  ) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Veuillez saisir la ville $champ.';
    }

    if (valeur.trim().length < 2) {
      return 'La ville $champ est invalide.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final trajetProvider = context.watch<TrajetProvider>();

    final chargement = trajetProvider.chargement;
    final messageErreur = trajetProvider.messageErreur;

    return Scaffold(
      backgroundColor: _fond,
      appBar: AppBar(
        backgroundColor: _bleuPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: _orange,
                size: 23,
              ),
            ),
            SizedBox(width: 11),
            Text(
              'UniCar',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: chargement ? null : _seDeconnecter,
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _construireEntete(),

              Transform.translate(
                offset: const Offset(0, -25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 560,
                    ),
                    child: Column(
                      children: [
                        _construireCarteRecherche(
                          chargement: chargement,
                        ),

                        if (messageErreur != null) ...[
                          const SizedBox(height: 18),
                          _construireMessageErreur(
                            messageErreur,
                            trajetProvider,
                          ),
                        ],

                        const SizedBox(height: 22),

                        _construireSectionAvantages(),

                        const SizedBox(height: 25),

                        const Text(
                          'Voyagez simplement avec UniCar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
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
        24,
        18,
        24,
        55,
      ),
      decoration: const BoxDecoration(
        color: _bleuPrincipal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 560,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue sur UniCar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Trouvez un trajet adapté à votre destination et voyagez en toute simplicité.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.route_rounded,
                    color: _orange,
                    size: 21,
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Dakar • Thiès • Saint-Louis • Nouakchott',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireCarteRecherche({
    required bool chargement,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 7,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          22,
          20,
          22,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  ContainerIcone(
                    icon: Icons.search_rounded,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Où allez-vous ?',
                      style: TextStyle(
                        color: Color(0xFF1D2939),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Indiquez votre ville de départ et votre destination.',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              TextFormField(
                controller: _departController,
                enabled: !chargement,
                textCapitalization:
                    TextCapitalization.words,
                textInputAction:
                    TextInputAction.next,
                autofillHints: const [
                  AutofillHints.addressCity,
                ],
                decoration: _decorationChamp(
                  label: 'Ville de départ',
                  hint: 'Exemple : Dakar',
                  icon: Icons.trip_origin_rounded,
                  couleurIcone: _orange,
                ),
                validator: (valeur) {
                  return _validerVille(
                    valeur,
                    'de départ',
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: IconButton(
                        onPressed: chargement
                            ? null
                            : _inverserTrajet,
                        tooltip: 'Inverser le trajet',
                        style: IconButton.styleFrom(
                          backgroundColor: _bleuClair,
                          foregroundColor:
                              _bleuPrincipal,
                          fixedSize: const Size(45, 45),
                        ),
                        icon: const Icon(
                          Icons.swap_vert_rounded,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(),
                    ),
                  ],
                ),
              ),

              TextFormField(
                controller: _arriveeController,
                enabled: !chargement,
                textCapitalization:
                    TextCapitalization.words,
                textInputAction:
                    TextInputAction.search,
                autofillHints: const [
                  AutofillHints.addressCity,
                ],
                decoration: _decorationChamp(
                  label: 'Ville d’arrivée',
                  hint: 'Exemple : Thiès',
                  icon: Icons.location_on_rounded,
                  couleurIcone: _bleuPrincipal,
                ),
                validator: (valeur) {
                  return _validerVille(
                    valeur,
                    'd’arrivée',
                  );
                },
                onFieldSubmitted: (_) {
                  if (!chargement) {
                    _rechercher();
                  }
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed:
                      chargement ? null : _rechercher,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _orange.withValues(alpha: 0.55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  icon: chargement
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.search_rounded,
                        ),
                  label: Text(
                    chargement
                        ? 'Recherche en cours...'
                        : 'Rechercher un trajet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decorationChamp({
    required String label,
    required String hint,
    required IconData icon,
    required Color couleurIcone,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: couleurIcone,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFD0D5DD),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _bleuPrincipal,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.7,
        ),
      ),
    );
  }

  Widget _construireMessageErreur(
    String messageErreur,
    TrajetProvider trajetProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              messageErreur,
              style: const TextStyle(
                color: Color(0xFF912018),
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            onPressed: trajetProvider.effacerErreur,
            tooltip: 'Fermer le message',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFB42318),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireSectionAvantages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pourquoi choisir UniCar ?',
          style: TextStyle(
            color: Color(0xFF1D2939),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _construireAvantage(
                icon: Icons.speed_rounded,
                titre: 'Rapide',
                description:
                    'Trouvez facilement un trajet.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _construireAvantage(
                icon: Icons.savings_outlined,
                titre: 'Économique',
                description:
                    'Partagez les frais du voyage.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _construireAvantage(
                icon: Icons.people_alt_outlined,
                titre: 'Communautaire',
                description:
                    'Voyagez avec votre communauté.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _construireAvantage(
                icon: Icons.notifications_active_outlined,
                titre: 'Suivi',
                description:
                    'Recevez les états du trajet.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construireAvantage({
    required IconData icon,
    required String titre,
    required String description,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 145,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _bleuClair,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _bleuPrincipal,
              size: 23,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            titre,
            style: const TextStyle(
              color: Color(0xFF1D2939),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class ContainerIcone extends StatelessWidget {
  final IconData icon;

  const ContainerIcone({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF123A63),
        size: 23,
      ),
    );
  }
}