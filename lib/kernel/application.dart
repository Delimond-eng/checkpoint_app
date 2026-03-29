import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:checkpoint_app/kernel/services/alarm_service.dart';
import 'package:checkpoint_app/themes/colors.dart';
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
    // On pointe vers les méthodes statiques de AlarmService qui ont le décorateur @pragma("vm:entry-point")
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
