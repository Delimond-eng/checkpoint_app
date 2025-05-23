import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/screens/auth/login.dart';
import 'package:checkpoint_app/screens/public/welcome_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../themes/app_theme.dart';
import 'package:flutter/material.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
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
