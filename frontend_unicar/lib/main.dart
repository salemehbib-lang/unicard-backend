import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/vehicule_provider.dart';
import 'providers/trajet_provider.dart';
import 'providers/reservation_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/conducteur/add_trip_screen.dart';

void main() {
  runApp(const UniCarApp());
}

class UniCarApp extends StatelessWidget {
  const UniCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => VehicleProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => TrajetProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => ReservationProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniCar',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
          ),
        ),
        initialRoute: '/connexion',
        routes: {
          '/connexion': (_) => const LoginScreen(),
          '/inscription': (_) => const RegisterScreen(),
          '/ajouter-trajet': (_) => const AddTripScreen(),
        },
      ),
    );
  }
}