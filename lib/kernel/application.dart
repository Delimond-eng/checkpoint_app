import 'package:awesome_notifications/awesome_notifications.dart';
import '/kernel/services/alarm_service.dart';
import '/kernel/services/translations.dart';
import '/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../global/controllers.dart';
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
    return GetMaterialApp(
      title: 'Salama Mamba',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(), // Ajout des traductions
      locale: Get.deviceLocale, // Langue par défaut du système
      fallbackLocale: const Locale('fr', 'FR'), // Langue de secours
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
