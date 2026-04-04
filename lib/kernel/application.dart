import 'package:awesome_notifications/awesome_notifications.dart';
import '/kernel/services/alarm_service.dart';
import '/kernel/services/translations.dart';
import '/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../global/controllers.dart';
import '../global/store.dart';
import '../screens/auth/login.dart';
import '../screens/public/welcome_screen.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  void initState() {
    super.initState();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: AlarmService.onActionReceivedMethod,
      onNotificationCreatedMethod: AlarmService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: AlarmService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: AlarmService.onDismissActionReceivedMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer la langue sauvegardée au démarrage
    String? savedLang = localStorage.read("language");
    Locale initialLocale = savedLang != null ? Locale(savedLang) : Get.deviceLocale ?? const Locale('fr', 'FR');

    return GetMaterialApp(
      title: 'Salama Mamba',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale, // Utilise la langue sauvegardée
      fallbackLocale: const Locale('fr', 'FR'),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Palette.kPrimarySwatch,
        fontFamily: 'Ubuntu',
      ),
      builder:  EasyLoading.init(),
      home: Obx(() {
        return authController.userSession.value?.id != null
            ? const WelcomeScreen()
            : const LoginScreen();
      }),
    );
  }
}
