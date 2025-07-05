import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  static final _battery = Battery();

  static Future<int> getBatteryLevel() async {
    return await _battery.batteryLevel;
  }
}
