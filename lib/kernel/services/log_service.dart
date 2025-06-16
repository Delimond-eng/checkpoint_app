// ignore_for_file: unused_local_variable, unused_element
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogService {
  static Future<void> loadPowerEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final shutdownTime = prefs.getInt('shutdown_time');
    final shutdownBattery = prefs.getInt('shutdown_battery');
    final bootTime = prefs.getInt('boot_time');
    final bootBattery = prefs.getInt('boot_battery');

    final httpManager = HttpManager();

    if (shutdownTime != null) {
      httpManager.saveLog({
        "reason": "shutdown",
        "battery_level": shutdownBattery.toString(),
        "date_and_time": _formatTime(shutdownTime)
      });
    }
    if (bootTime != null) {
      httpManager.saveLog({
        "reason": "shutdown",
        "battery_level": bootBattery.toString(),
        "date_and_time": _formatTime(bootTime)
      });
    }
  }

  static String _formatTime(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}
