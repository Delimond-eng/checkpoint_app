import 'package:checkpoint_app/constants/styles.dart';
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

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late final Future<Widget> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _initApp(); // ← créé UNE fois
  }

  Future<Widget> _initApp() async {
    final userSession = localStorage.read("user_session");
    return (userSession != null) ? const WelcomeScreen() : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salama Plateforme',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      builder: EasyLoading.init(),
      home: FutureBuilder<Widget>(
        future: _startupFuture, // ← réutilisé
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: darkGreyColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: primaryMaterialColor,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Erreur : ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
