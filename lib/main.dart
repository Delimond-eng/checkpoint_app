import 'package:checkpoint_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/kernel/application.dart';
import '/kernel/controllers/tag_controller.dart';
import 'kernel/controllers/auth_controller.dart';
import 'kernel/controllers/face_recognition_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les notifications locales
  await GetStorage.init();
  Get.put(TagsController());
  Get.put(AuthController());
  Get.put(FaceRecognitionController());
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
