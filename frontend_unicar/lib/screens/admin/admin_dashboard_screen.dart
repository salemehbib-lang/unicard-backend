import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_utilisateur.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _rechercheController =
      TextEditingController();

  String _recherche = '';
  String _filtreRole = 'tous';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    final provider = context.read<AdminProvider>();

    await Future.wait([
      provider.chargerStatistiques(),
      provider.chargerUtilisateurs(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    final chargement =
        provider.chargementStatistiques ||
        provider.chargementUtilisateurs;

    final utilisateursFiltres =
        _filtrerUtilisateurs(provider.utilisateurs);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined),
            SizedBox(width: 10),
            Text(
              'Administration UniCar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: chargement
                ? null
                : _chargerDonnees,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _chargerDonnees,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _construireEntete(),

            if (chargement)
              const LinearProgressIndicator(),

            if (provider.messageErreur != null)
              _construireMessage(
                provider.messageErreur!,
                estErreur: true,
              ),

            if (provider.messageSucces != null)
              _construireMessage(
                provider.messageSucces!,
                estErreur: false,
              ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _construireTitreSection(
                    titre: 'Vue générale',
                    icone: Icons.dashboard_outlined,
                  ),

                  const SizedBox(height: 14),

                  _construireStatistiques(provider),

                  const SizedBox(height: 28),

                  _construireTitreUtilisateurs(
                    utilisateursFiltres.length,
                  ),

                  const SizedBox(height: 14),

                  _construireRecherche(),

                  const SizedBox(height: 12),

                  _construireFiltres(),

                  const SizedBox(height: 18),

                  if (!chargement &&
                      utilisateursFiltres.isEmpty)
                    _construireListeVide()
                  else
                    ...utilisateursFiltres.map(
                      (utilisateur) =>
                          _construireCarteUtilisateur(
                        provider,
                        utilisateur,
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireEntete() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        24,
        22,
        30,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Gérez les utilisateurs et consultez les statistiques de UniCar.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireStatistiques(
    AdminProvider provider,
  ) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        int nombreColonnes;

        if (contraintes.maxWidth >= 900) {
          nombreColonnes = 3;
        } else if (contraintes.maxWidth >= 550) {
          nombreColonnes = 2;
        } else {
          nombreColonnes = 2;
        }

        return GridView.count(
          crossAxisCount: nombreColonnes,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              contraintes.maxWidth >= 550
                  ? 2.1
                  : 1.35,
          children: [
            _CarteStatistique(
              titre: 'Utilisateurs',
              valeur: _valeurStatistique(
                provider,
                [
                  ['utilisateurs', 'total'],
                  [
                    'utilisateurs',
                    'nombre_total',
                  ],
                ],
              ),
              icone: Icons.people_alt_outlined,
              couleur: const Color(0xFF1565C0),
            ),
            _CarteStatistique(
              titre: 'Passagers',
              valeur: _valeurStatistique(
                provider,
                [
                  ['utilisateurs', 'passagers'],
                  [
                    'utilisateurs',
                    'nombre_passagers',
                  ],
                ],
              ),
              icone: Icons.person_outline,
              couleur: const Color(0xFF00897B),
            ),
            _CarteStatistique(
              titre: 'Conducteurs',
              valeur: _valeurStatistique(
                provider,
                [
                  [
                    'utilisateurs',
                    'conducteurs',
                  ],
                  [
                    'utilisateurs',
                    'nombre_conducteurs',
                  ],
                ],
              ),
              icone: Icons.directions_car_outlined,
              couleur: const Color(0xFFF57C00),
            ),
            _CarteStatistique(
              titre: 'Bloqués',
              valeur: _valeurStatistique(
                provider,
                [
                  ['utilisateurs', 'bloques'],
                  [
                    'utilisateurs',
                    'utilisateurs_bloques',
                  ],
                ],
              ),
              icone: Icons.block_outlined,
              couleur: const Color(0xFFD32F2F),
            ),
            _CarteStatistique(
              titre: 'Trajets',
              valeur: _valeurStatistique(
                provider,
                [
                  ['trajets', 'total'],
                  ['trajets', 'nombre_total'],
                ],
              ),
              icone: Icons.route_outlined,
              couleur: const Color(0xFF7B1FA2),
            ),
            _CarteStatistique(
              titre: 'Réservations',
              valeur: _valeurStatistique(
                provider,
                [
                  ['reservations', 'total'],
                  [
                    'reservations',
                    'nombre_total',
                  ],
                ],
              ),
              icone: Icons.event_seat_outlined,
              couleur: const Color(0xFF455A64),
            ),
          ],
        );
      },
    );
  }

  Widget _construireTitreSection({
    required String titre,
    required IconData icone,
  }) {
    return Row(
      children: [
        Icon(
          icone,
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(width: 9),
        Text(
          titre,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF263238),
          ),
        ),
      ],
    );
  }

  Widget _construireTitreUtilisateurs(
    int nombre,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.manage_accounts_outlined,
          color: Color(0xFF1565C0),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            'Gestion des utilisateurs',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$nombre utilisateur${nombre > 1 ? 's' : ''}',
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireRecherche() {
    return TextField(
      controller: _rechercheController,
      onChanged: (valeur) {
        setState(() {
          _recherche =
              valeur.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText:
            'Rechercher par nom, email ou utilisateur...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _recherche.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _rechercheController.clear();

                  setState(() {
                    _recherche = '';
                  });
                },
                icon: const Icon(Icons.close),
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF1565C0),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _construireFiltres() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FiltreBouton(
            titre: 'Tous',
            valeur: 'tous',
            selectionne:
                _filtreRole == 'tous',
            onSelection: _changerFiltre,
          ),
          _FiltreBouton(
            titre: 'Passagers',
            valeur: 'passager',
            selectionne:
                _filtreRole == 'passager',
            onSelection: _changerFiltre,
          ),
          _FiltreBouton(
            titre: 'Conducteurs',
            valeur: 'conducteur',
            selectionne:
                _filtreRole == 'conducteur',
            onSelection: _changerFiltre,
          ),
          _FiltreBouton(
            titre: 'Administrateurs',
            valeur: 'administrateur',
            selectionne:
                _filtreRole == 'administrateur',
            onSelection: _changerFiltre,
          ),
          _FiltreBouton(
            titre: 'Bloqués',
            valeur: 'bloques',
            selectionne:
                _filtreRole == 'bloques',
            onSelection: _changerFiltre,
          ),
        ],
      ),
    );
  }

  void _changerFiltre(String valeur) {
    setState(() {
      _filtreRole = valeur;
    });
  }

  List<AdminUtilisateur> _filtrerUtilisateurs(
    List<AdminUtilisateur> utilisateurs,
  ) {
    return utilisateurs.where((utilisateur) {
      final correspondFiltre =
          _filtreRole == 'tous' ||
          (_filtreRole == 'bloques' &&
              utilisateur.estBloque) ||
          utilisateur.role == _filtreRole;

      final texte =
          '${utilisateur.nomComplet} '
          '${utilisateur.username} '
          '${utilisateur.email}'
              .toLowerCase();

      final correspondRecherche =
          _recherche.isEmpty ||
          texte.contains(_recherche);

      return correspondFiltre &&
          correspondRecherche;
    }).toList();
  }

  Widget _construireCarteUtilisateur(
    AdminProvider provider,
    AdminUtilisateur utilisateur,
  ) {
    final modification =
        provider.utilisateurEnModification(
      utilisateur.id,
    );

    final couleurRole =
        _couleurSelonRole(utilisateur.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: utilisateur.estBloque
              ? Colors.red.shade200
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  couleurRole.withValues(
                alpha: 0.12,
              ),
              child: Icon(
                _iconeSelonRole(utilisateur.role),
                color: couleurRole,
                size: 27,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    utilisateur.nomComplet.isNotEmpty
                        ? utilisateur.nomComplet
                        : utilisateur.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '@${utilisateur.username}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      _EtiquetteUtilisateur(
                        texte:
                            utilisateur.roleAffiche,
                        icone: _iconeSelonRole(
                          utilisateur.role,
                        ),
                        couleur: couleurRole,
                      ),
                      _EtiquetteUtilisateur(
                        texte:
                            utilisateur.estBloque
                                ? 'Compte bloqué'
                                : 'Compte actif',
                        icone:
                            utilisateur.estBloque
                                ? Icons.block
                                : Icons.check_circle,
                        couleur:
                            utilisateur.estBloque
                                ? Colors.red
                                : Colors.green,
                      ),
                    ],
                  ),

                  if (utilisateur.email.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            utilisateur.email,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            if (modification)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            else if (utilisateur.role ==
                'administrateur')
              const Tooltip(
                message: 'Administrateur',
                child: Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF1565C0),
                ),
              )
            else
              PopupMenuButton<String>(
                tooltip: 'Actions',
                onSelected: (action) {
                  if (action == 'bloquer') {
                    _confirmerModification(
                      provider,
                      utilisateur,
                      true,
                    );
                  } else {
                    _confirmerModification(
                      provider,
                      utilisateur,
                      false,
                    );
                  }
                },
                itemBuilder: (context) {
                  if (utilisateur.estBloque) {
                    return const [
                      PopupMenuItem(
                        value: 'debloquer',
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_open_outlined,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10),
                            Text('Débloquer'),
                          ],
                        ),
                      ),
                    ];
                  }

                  return const [
                    PopupMenuItem(
                      value: 'bloquer',
                      child: Row(
                        children: [
                          Icon(
                            Icons.block_outlined,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text('Bloquer'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerModification(
    AdminProvider provider,
    AdminUtilisateur utilisateur,
    bool bloquer,
  ) async {
    final confirmation =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          icon: Icon(
            bloquer
                ? Icons.block_outlined
                : Icons.lock_open_outlined,
            size: 45,
            color:
                bloquer ? Colors.red : Colors.green,
          ),
          title: Text(
            bloquer
                ? 'Bloquer cet utilisateur ?'
                : 'Débloquer cet utilisateur ?',
          ),
          content: Text(
            bloquer
                ? '${utilisateur.username} ne pourra plus accéder à son compte.'
                : '${utilisateur.username} pourra de nouveau accéder à son compte.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment:
              MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bloquer
                    ? Colors.red
                    : Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                bloquer
                    ? 'Bloquer'
                    : 'Débloquer',
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    final succes = bloquer
        ? await provider.bloquerUtilisateur(
            utilisateurId: utilisateur.id,
          )
        : await provider.debloquerUtilisateur(
            utilisateurId: utilisateur.id,
          );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            succes ? Colors.green : Colors.red,
        content: Text(
          succes
              ? provider.messageSucces ??
                  'Modification effectuée.'
              : provider.messageErreur ??
                  'La modification a échoué.',
        ),
      ),
    );
  }

  Widget _construireMessage(
    String message, {
    required bool estErreur,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: estErreur
              ? Colors.red.shade50
              : Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: estErreur
                ? Colors.red.shade200
                : Colors.green.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              estErreur
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color:
                  estErreur ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireListeVide() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Aucun utilisateur trouvé.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _valeurStatistique(
    AdminProvider provider,
    List<List<String>> chemins,
  ) {
    for (final chemin in chemins) {
      final valeur = provider.valeurStatistique(
        chemin[0],
        chemin[1],
      );

      if (valeur != 0) {
        return valeur;
      }
    }

    return 0;
  }

  IconData _iconeSelonRole(String role) {
    switch (role) {
      case 'conducteur':
        return Icons.directions_car_outlined;
      case 'administrateur':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Color _couleurSelonRole(String role) {
    switch (role) {
      case 'conducteur':
        return const Color(0xFFF57C00);
      case 'administrateur':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF00897B);
    }
  }
}

class _CarteStatistique extends StatelessWidget {
  const _CarteStatistique({
    required this.titre,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  final String titre;
  final int valeur;
  final IconData icone;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: couleur.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icone,
              color: couleur,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$valeur',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: couleur,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
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

class _FiltreBouton extends StatelessWidget {
  const _FiltreBouton({
    required this.titre,
    required this.valeur,
    required this.selectionne,
    required this.onSelection,
  });

  final String titre;
  final String valeur;
  final bool selectionne;
  final ValueChanged<String> onSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(titre),
        selected: selectionne,
        onSelected: (_) {
          onSelection(valeur);
        },
        selectedColor: const Color(0xFF1565C0),
        labelStyle: TextStyle(
          color:
              selectionne ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selectionne
              ? const Color(0xFF1565C0)
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _EtiquetteUtilisateur
    extends StatelessWidget {
  const _EtiquetteUtilisateur({
    required this.texte,
    required this.icone,
    required this.couleur,
  });

  final String texte;
  final IconData icone;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone,
            size: 14,
            color: couleur,
          ),
          const SizedBox(width: 4),
          Text(
            texte,
            style: TextStyle(
              color: couleur,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}