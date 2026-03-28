import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import '../models/planning.dart';

class AlarmService {
  static final AlarmService instance = AlarmService._init();
  final FlutterTts _flutterTts = FlutterTts();

  AlarmService._init() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // use default icon
      [
        NotificationChannel(
          channelKey: 'patrol_alarms',
          channelName: 'Patrol Alarms',
          channelDescription: 'Notifications for scheduled patrols',
          defaultColor: const Color(0xFF223e8c),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      debug: true,
    );

    // Request permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> scheduleAlarms(List<Planning> plannings) async {
    // Cancel all previous alarms to avoid duplicates
    await AwesomeNotifications().cancelNotificationsByChannelKey('patrol_alarms');

    final now = DateTime.now();

    for (var planning in plannings) {
      if (planning.date == null || planning.startTime == null) continue;

      try {
        DateTime pDate;
        if (planning.date!.contains('/')) {
          pDate = DateFormat('dd/MM/yyyy').parse(planning.date!);
        } else {
          pDate = DateTime.parse(planning.date!);
        }

        final timeParts = planning.startTime!.split(':');
        final scheduleTime = DateTime(
          pDate.year,
          pDate.month,
          pDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        // Schedule only if time is in the future
        if (scheduleTime.isAfter(now)) {
          await _createPatrolNotification(planning, scheduleTime);
        }
      } catch (e) {
        debugPrint("Error scheduling alarm: $e");
      }
    }
  }

  Future<void> _createPatrolNotification(Planning planning, DateTime time) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: planning.id ?? DateTime.now().millisecond,
        channelKey: 'patrol_alarms',
        title: 'Début de Patrouille',
        body: 'Il est l\'heure pour : ${planning.libelle}',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        payload: {'planning_id': planning.id.toString(), 'libelle': planning.libelle ?? ''},
      ),
      schedule: NotificationCalendar.fromDate(date: time),
    );
  }

  // To be called when notification is received while app is in foreground
  void handleForegroundAlarm(String libelle) {
    speak("Agent, il est l'heure de débuter votre patrouille : $libelle");
  }
}
