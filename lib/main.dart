import 'package:checkpoint_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import '/kernel/application.dart';
import '/kernel/controllers/tag_controller.dart';
import 'kernel/controllers/auth_controller.dart';
import 'kernel/services/recognition_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les notifications locales
  await GetStorage.init();
  //Get.put(FaceRecognitionService());
  Get.put(TagsController());
  Get.put(AuthController());
  runApp(
    ChangeNotifierProvider(
      create: (_) => FaceRecognitionController(),
      child: const Application(),
    ),
  );
  configEasyLoading();
  await checkPermission();
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
