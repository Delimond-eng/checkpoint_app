import 'package:flutter/services.dart';

class MdmService {
  static const MethodChannel _channel = MethodChannel('com.example.checkpoint_app/mdm');

  /// Verrouille l'appareil en mode Kiosque (Lock Task)
  static Future<bool> lockDevice() async {
    try {
      final bool success = await _channel.invokeMethod('lockDevice');
      return success;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Déverrouille l'appareil et quitte le mode Kiosque
  static Future<bool> unlockDevice() async {
    try {
      final bool success = await _channel.invokeMethod('unlockDevice');
      return success;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Vérifie si le mode Kiosque est actuellement actif
  static Future<bool> isDeviceLocked() async {
    try {
      final bool isLocked = await _channel.invokeMethod('isDeviceLocked');
      return isLocked;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
