import 'package:checkpoint_app/constants/styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

final FlutterTts flutterTts = FlutterTts();

class FirebaseService {
  static Future<void> initFCM() async {
    // Initialiser les notifications Awesome
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

    // Demander la permission (obligatoire pour Android 13+ et iOS)
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Écouter les messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? "Nouvelle notification";
      final body = message.notification?.body ?? "";

      if (kDebugMode) {
        print("title : $title, body : $body");
        EasyLoading.showToast(body);
      }
      // Afficher la notification avec Awesome
      showLocalNotification(title, body);

      // Lire le message à voix haute
      readMessage(body);
    });

    // Messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();

    final title = message.data['title'] ?? 'Titre';
    final body = message.data['body'] ?? 'Corps';

    await showLocalNotification(title, body);

    if (kDebugMode) {
      print('Notification en arrière-plan: ${message.notification?.title}');
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

    var result = await flutterTts.speak(text);
    if (result == 1) {
      debugPrint("✅ Lecture démarrée");
    } else {
      debugPrint("Erreur lors de la lecture");
    }
  }

  static Future<String?> getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      String? token = await messaging.getToken();
      if (kDebugMode) {
        print("TOKEN : $token");
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la récupération du token FCM : $e");
      }
      return null;
    }
  }
}
