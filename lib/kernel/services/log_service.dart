// ignore_for_file: unused_local_variable, unused_element, depend_on_referenced_packages
import 'dart:async';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:intl/intl.dart';
import 'battery_service.dart';

class LogService {
  static void startActivityHeartbeat() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final battery = await BatteryService.getBatteryLevel();
      localStorage.write('last_active_time', now);
      localStorage.write('last_active_battery', battery);
    });
  }

  static Future<bool> loadPowerEvents() async {
    final httpManager = HttpManager();

    final lastActiveTime = localStorage.read('last_active_time');
    final lastActiveBattery = localStorage.read('last_active_battery');
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentBattery = await BatteryService.getBatteryLevel();

    List<Map<String, dynamic>> data = [];

    if (lastActiveTime != null && now - lastActiveTime > 60 * 1000) {
      // > 1 minute
      data.add({
        "agent_id": authController.userSession.value.id,
        "site_id": authController.userSession.value.siteId,
        "reason": "shutdown",
        "battery_level": lastActiveBattery?.toString() ?? "-",
        "date_and_time": _formatTime(int.parse(lastActiveTime.toString()))
      });

      data.add({
        "agent_id": authController.userSession.value.id,
        "site_id": authController.userSession.value.siteId,
        "reason": "boot",
        "battery_level": currentBattery.toString(),
        "date_and_time": _formatTime(int.parse(lastActiveTime.toString()))
      });
    }

    // Envoi
    if (data.isNotEmpty) {
      for (var e in data) {
        await httpManager.saveLog(e);
      }
      // Nettoyer après
      localStorage.remove('last_active_time');
      localStorage.remove('last_active_battery');
    }
    return true;
  }

  static String _formatTime(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
