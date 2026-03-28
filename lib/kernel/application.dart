import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:checkpoint_app/kernel/services/alarm_service.dart';
import 'package:checkpoint_app/themes/colors.dart';
import 'package:flutter/material.dart';
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
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        if (receivedAction.channelKey == 'patrol_alarms') {
          final libelle = receivedAction.payload?['libelle'] ?? '';
          AlarmService.instance.handleForegroundAlarm(libelle);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Salama Mamba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Palette.kPrimarySwatch,
        fontFamily: 'Ubuntu',
      ),
      home: Obx(() {
        return authController.userSession.value?.id != null
            ? const WelcomeScreen()
            : const LoginScreen();
      }),
    );
  }
}
