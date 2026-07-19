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
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

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

    final trajetProvider =
        context.read<TrajetProvider>();

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
    final confirmation =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text(
            'Voulez-vous vraiment vous déconnecter ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
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

  @override
  Widget build(BuildContext context) {
    final trajetProvider =
        context.watch<TrajetProvider>();

    final chargement = trajetProvider.chargement;
    final messageErreur =
        trajetProvider.messageErreur;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UniCar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                chargement ? null : _seDeconnecter,
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 70,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bienvenue sur UniCar 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Trouvez facilement un trajet adapté à votre destination.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Où allez-vous ?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller:
                                  _departController,
                              enabled: !chargement,
                              textCapitalization:
                                  TextCapitalization.words,
                              textInputAction:
                                  TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.addressCity,
                              ],
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Ville de départ',
                                hintText:
                                    'Exemple : Dakar',
                                prefixIcon: Icon(
                                  Icons.trip_origin,
                                ),
                                border:
                                    OutlineInputBorder(),
                              ),
                              validator: (valeur) {
                                if (valeur == null ||
                                    valeur
                                        .trim()
                                        .isEmpty) {
                                  return 'Veuillez saisir la ville de départ.';
                                }

                                if (valeur.trim().length <
                                    2) {
                                  return 'La ville de départ est invalide.';
                                }

                                return null;
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: Align(
                                alignment:
                                    Alignment.center,
                                child: IconButton.filledTonal(
                                  onPressed: chargement
                                      ? null
                                      : _inverserTrajet,
                                  tooltip:
                                      'Inverser le trajet',
                                  icon: const Icon(
                                    Icons.swap_vert,
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller:
                                  _arriveeController,
                              enabled: !chargement,
                              textCapitalization:
                                  TextCapitalization.words,
                              textInputAction:
                                  TextInputAction.search,
                              autofillHints: const [
                                AutofillHints.addressCity,
                              ],
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    'Ville d’arrivée',
                                hintText:
                                    'Exemple : Thiès',
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                ),
                                border:
                                    OutlineInputBorder(),
                              ),
                              validator: (valeur) {
                                if (valeur == null ||
                                    valeur
                                        .trim()
                                        .isEmpty) {
                                  return 'Veuillez saisir la ville d’arrivée.';
                                }

                                if (valeur.trim().length <
                                    2) {
                                  return 'La ville d’arrivée est invalide.';
                                }

                                return null;
                              },
                              onFieldSubmitted: (_) {
                                if (!chargement) {
                                  _rechercher();
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: chargement
                                    ? null
                                    : _rechercher,
                                icon: chargement
                                    ? const SizedBox(
                                        width: 21,
                                        height: 21,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.search,
                                      ),
                                label: Text(
                                  chargement
                                      ? 'Recherche en cours...'
                                      : 'Rechercher un trajet',
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (messageErreur != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                messageErreur,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: trajetProvider
                                  .effacerErreur,
                              tooltip:
                                  'Fermer le message',
                              icon: const Icon(
                                Icons.close,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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