import 'package:workmanager/workmanager.dart';

import '../models/planning.dart';
import 'database_helper.dart';
import 'notification_service.dart';
import 'tts_service.dart';

class WorkManagerService {
  static const String taskName = "check_schedule_task";

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      await checkAndTriggerAlarms();
      return Future.value(true);
    });
  }

  Future<void> initializeWorkManager() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await Workmanager().registerPeriodicTask(
      '1',
      taskName,
      frequency: const Duration(hours: 1),
    );
  }

  Future<void> checkAndTriggerAlarms() async {
    await DatabaseHelper.database();
    await DatabaseHelper.insertSchedule();

    List<Planning> schedules = await DatabaseHelper.getSchedules();
    DateTime now = DateTime.now();

    for (Planning schedule in schedules) {
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(schedule.startTime!.split(':')[0]),
        int.parse(schedule.startTime!.split(':')[1]),
      );

      if (scheduledTime.isAfter(now)) {
        // Notification et Text-to-Speech à l'heure prévue
        await NotificationService()
            .showNotification(schedule.id!, schedule.libelle!);
        await TTSService()
            .speak("C'est l'heure de la patrouille ${schedule.libelle}");
      }
    }
  }
}
