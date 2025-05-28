import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/screens/auth/login.dart';
import 'package:checkpoint_app/screens/public/welcome_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../themes/app_theme.dart';
import 'package:flutter/material.dart';

// Fonction pour vérifier et demander la permission de localisation
Future<void> checkPermission() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Vérifie si le service de localisation est activé
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Si le service est désactivé, vous pouvez demande3.
    // r à l'utilisateur de l'activer
    return Future.error('Le service de localisation est désactivé.');
  }

  // Vérifie les permissions de localisation
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Si la permission est refusée, affiche un message
      return Future.error('La permission de localisation est refusée.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Si la permission est refusée de manière permanente
    return Future.error(
        'La permission de localisation est refusée de manière permanente.');
  }
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    checkPermission();
    // Lire la session utilisateur une seule fois
    final userSession = localStorage.read("user_session");
    // Déterminer l'écran d'accueil en fonction du rôle
    Widget getHomeScreen() {
      if (userSession != null) {
        return const WelcomeScreen();
      }
      return const LoginScreen();
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salama Plateforme',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      builder: EasyLoading.init(),
      home: getHomeScreen(),
    );
  }
}
