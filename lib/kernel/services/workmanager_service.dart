import 'package:checkpoint_app/global/store.dart';
import '../models/planning.dart';
import 'http_manager.dart';
import 'notification_service.dart';
import 'tts_service.dart';

// La fonction pour exécuter la tâche en arrière-plan
void alarmCallback() async {
  await HttpManager.getAllPlannings();
  await checkAndTriggerAlarms(); // Appel de la fonction pour déclencher les alarmes
}

Future<void> checkAndTriggerAlarms() async {
  List<Planning> schedules = await getSchedules();
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
      await TTSService().initializeTts();
      await TTSService()
          .speak("C'est l'heure de la patrouille ${schedule.libelle}");
    }
  }
}

Future<List<Planning>> getSchedules() async {
  List<Planning> schedules = [];
  var schedulesJsonArr = localStorage.read("schedules");
  if (schedulesJsonArr != null) {
    schedulesJsonArr.forEach((e) {
      schedules.add(Planning.fromJson(e));
    });
  }
  return schedules;
}

class AlarmManagerService {
  static const int alarmID = 0; // Identifiant unique pour l'alarme

  // Initialiser Android Alarm Manager
  Future<void> initializeAlarmManager() async {
    // Initialiser le service Android Alarm Manager
    //await AndroidAlarmManager.initialize();

    // Programmer une alarme répétitive toutes les 1 minute(s)
    /* await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), // Fréquence de répétition
      alarmID, // Identifiant unique pour l'alarme
      alarmCallback, // Fonction à exécuter lors de l'alarme
      exact: true, // Assurer que l'alarme est exacte
      wakeup: true, // Réveille l'appareil si nécessaire
    ); */
  }

  // Stopper l'alarme
  Future<void> cancelAlarm() async {
    //await AndroidAlarmManager.cancel(alarmID);
  }
}
