import 'dart:convert';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/kernel/controllers/face_recognition_controller.dart';
import '/kernel/controllers/tag_controller.dart';
import '/kernel/models/face.dart';
import '/kernel/services/api.dart';
import '/kernel/services/database_helper.dart';
import '/kernel/services/mdm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';

final FlutterTts flutterTts = FlutterTts();

class FirebaseService {
  static Future<void> initFCM() async {
    try {
      AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Notifications',
            channelDescription: 'Canal de notifications de base',
            importance: NotificationImportance.High,
            defaultColor: primaryMaterialColor,
            playSound: true,
            enableVibration: true,
            soundSource: 'resource://raw/bell',
            enableLights: true,
          )
        ],
        debug: true,
      );

      await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });

      // Écouteur principal (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        if (kDebugMode) print("FCM Message (Foreground): ${message.data}");
        
        final String? type = message.data['type'];
        String title = message.notification?.title ?? message.data['title'] ?? "SALAMA";
        final String body = message.notification?.body ?? message.data['body'] ?? "";

        // SI C'EST UN PLANNING : On affiche le toast et on refresh le badge AVANT la notification
        if (type != null && type.contains('planning')) {
          title = "Notification de planning";
          EasyLoading.showToast("Nouveau planning reçu !");
          
          if (Get.isRegistered<TagsController>()) {
            // Refresh silencieux et immédiat du badge et de la liste
            await tagsController.fetchAnnouncesAndPlannings();
          }
        } else {
          // Pour tout autre type, on refresh quand même les données par précaution
          await handleNotificationData(message);
        }

        showLocalNotification(title, body);
        readMessage(body);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      var token = await getToken();
      if (kDebugMode) print("FCM TOKEN: $token");
    } catch (e) {
      if (kDebugMode) print("Firebase init error $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    // Rafraîchir les données même en arrière-plan pour que le badge soit prêt à l'ouverture
    await handleNotificationData(message, silent: true);
  }

  static Future<void> handleNotificationData(RemoteMessage message, {bool silent = false}) async {
    if (Get.isRegistered<TagsController>()) {
      await tagsController.fetchAnnouncesAndPlannings();
    }

    final String? type = message.data['type'];
    
    // GESTION MDM
    if (type == 'lock') {
      await MdmService.lockDevice();
      return;
    } else if (type == 'unlock') {
      await MdmService.unlockDevice();
      return;
    }

    // GESTION BIOMÉTRIQUE
    final dynamic rawMatricules = message.data['matricules'];
    if (rawMatricules != null) {
      List<String> matricules = [];
      try {
        if (rawMatricules is List) {
          matricules = List<String>.from(rawMatricules);
        } else if (rawMatricules is String) {
          matricules = List<String>.from(jsonDecode(rawMatricules));
        }
      } catch (e) {
        return;
      }

      if (matricules.isNotEmpty) {
        if (type == 'biometric_sync') {
          await syncMatricules(matricules, silent: silent);
        } 
        else if (type == 'biometric_delete') {
          await deleteMatricules(matricules, silent: silent);
        }
      }
    }
  }

  static Future<void> syncMatricules(List<String> matricules, {bool silent = true}) async {
    try {
      final response = await Api.request(
        method: 'post',
        url: 'biometrics/by-matricules',
        body: {'matricules': matricules},
      );
      if (response != null && response['data'] != null) {
        List data = response['data'];
        final dbHelper = DatabaseHelper();
        for (var item in data) {
          List<double> embedding = List<double>.from(
            (item['embedding'] is String ? jsonDecode(item['embedding']) : item['embedding'])
            .map((e) => e.toDouble())
          );
          final face = FacePicture(matricule: item['matricule'], embedding: embedding);
          await dbHelper.deleteFace(face.matricule);
          await dbHelper.insertFace(face);
        }
        if (Get.isRegistered<FaceRecognitionController>()) {
          await FaceRecognitionController.instance.initializeModel();
        }
      }
    } catch (e) {
      debugPrint("Biometric Sync Error: $e");
    }
  }

  static Future<void> deleteMatricules(List<String> matricules, {bool silent = true}) async {
    try {
      final dbHelper = DatabaseHelper();
      for (var matricule in matricules) {
        await dbHelper.deleteFace(matricule);
      }
      if (Get.isRegistered<FaceRecognitionController>()) {
        await FaceRecognitionController.instance.initializeModel();
      }
    } catch (e) {
      debugPrint("Biometric Delete Error: $e");
    }
  }

  static Future<void> showLocalNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> readMessage(String text) async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(text);
  }

  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }
}
