import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'my_reservations_screen.dart';
import 'passenger_profile_screen.dart';
import '../notifications/notifications_screen.dart';

class PassengerMainScreen extends StatefulWidget {
  const PassengerMainScreen({super.key});

  @override
  State<PassengerMainScreen> createState() =>
      _PassengerMainScreenState();
}

class _PassengerMainScreenState
    extends State<PassengerMainScreen> {
  int _indexActuel = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
  
    MyReservationsScreen(),
    NotificationsScreen(),
    PassengerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indexActuel,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexActuel,
        onDestinationSelected: (index) {
          setState(() {
            _indexActuel = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Réservations',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

  