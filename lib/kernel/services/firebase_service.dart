import 'dart:convert';
import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/kernel/controllers/face_recognition_controller.dart';
import 'package:checkpoint_app/kernel/models/face.dart';
import 'package:checkpoint_app/kernel/services/api.dart';
import 'package:checkpoint_app/kernel/services/database_helper.dart';
import 'package:checkpoint_app/kernel/services/mdm_service.dart'; // Import MDM
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

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? "Nouvelle notification";
        final body = message.notification?.body ?? "";

        if (kDebugMode) {
          print("title : $title, body : $body");
        }
        
        handleNotificationData(message);
        showLocalNotification(title, body);
        readMessage(body);
      });

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      var token = await getToken();
      if (kDebugMode) {
        print("FCM TOKEN: $token");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Firebase init error $e");
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await handleNotificationData(message, silent: true);
    final title = message.data['title'] ?? message.notification?.title ?? 'Titre';
    final body = message.data['body'] ?? message.notification?.body ?? 'Corps';
    await showLocalNotification(title, body);
  }

  static Future<void> handleNotificationData(RemoteMessage message, {bool silent = false}) async {
    final String? type = message.data['type'];
    
    // GESTION MDM (Lock/Unlock)
    if (type == 'lock') {
      await MdmService.lockDevice();
      return;
    } else if (type == 'unlock') {
      await MdmService.unlockDevice();
      return;
    }

    final dynamic rawMatricules = message.data['matricules'];
    List<String> matricules = [];
    try {
      if (rawMatricules is List) {
        matricules = List<String>.from(rawMatricules);
      } else if (rawMatricules is String) {
        matricules = List<String>.from(jsonDecode(rawMatricules));
      }
    } catch (e) {
      debugPrint("❌ Erreur parsing matricules FCM: $e");
      return;
    }

    if (matricules.isEmpty) return;

    if (type == 'biometric_sync') {
      await syncMatricules(matricules, silent: silent);
    } 
    else if (type == 'biometric_delete') {
      await deleteMatricules(matricules, silent: silent);
    }
  }

  static Future<void> syncMatricules(List<String> matricules, {bool silent = true}) async {
    try {
      if (!silent) EasyLoading.show(status: 'Mise à jour biométrique...');
      final response = await Api.request(
        method: 'post',
        url: 'biometrics/by-matricules',
        body: {'matricules': matricules},
      );
      if (response != null && response['data'] != null) {
        List data = response['data'];
        final dbHelper = DatabaseHelper();
        for (var item in data) {
          List<double> embedding;
          var rawEmb = item['embedding'];
          if (rawEmb is String) {
            embedding = List<double>.from(jsonDecode(rawEmb).map((e) => e.toDouble()));
          } else {
            embedding = List<double>.from(rawEmb.map((e) => e.toDouble()));
          }
          final face = FacePicture(
            matricule: item['matricule'],
            embedding: embedding,
          );
          await dbHelper.deleteFace(face.matricule);
          await dbHelper.insertFace(face);
        }
        if (Get.isRegistered<FaceRecognitionController>()) {
          await FaceRecognitionController.instance.initializeModel();
        }
        if (!silent) EasyLoading.showSuccess('${data.length} visages synchronisés');
      }
    } catch (e) {
      if (!silent) debugPrint("Sync error: $e");
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
      if (!silent) EasyLoading.showSuccess("Données supprimées");
    } catch (e) {
      if (!silent) debugPrint("Delete error: $e");
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
