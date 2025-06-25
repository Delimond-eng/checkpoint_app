import 'package:checkpoint_app/constants/styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/kernel/application.dart';
import '/kernel/controllers/tag_controller.dart';
import 'firebase_options.dart';
import 'kernel/controllers/auth_controller.dart';
import 'kernel/controllers/face_recognition_controller.dart';
import 'kernel/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    /* await FirebaseMessaging.instance.requestPermission(); */
    await FirebaseService.initFCM();
    // await FirebaseService.getToken();
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  // Initialiser les notifications locales
  await GetStorage.init();
  Get.put(TagsController());
  Get.put(AuthController());
  Get.put(FaceRecognitionController());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const Application());
  configEasyLoading();
}

void configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..radius = 14.0 // Définissez ici le radius
    ..backgroundColor = Colors.black
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..maskColor = primaryMaterialColor.shade300.withOpacity(0.5)
    ..userInteractions = true;
}
