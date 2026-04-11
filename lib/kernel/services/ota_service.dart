import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ota_update/ota_update.dart';

class OtaService {
  static final OtaService instance = OtaService._init();
  OtaService._init();

  bool _isUpdating = false;

  Future<void> updateApp(String url) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      // 1. Vérification et demande des permissions pour l'installation
      if (Platform.isAndroid) {
        // Permission pour installer des APK (Android 8+)
        var status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          status = await Permission.requestInstallPackages.request();
          if (!status.isGranted) {
            EasyLoading.showError('Permission d\'installation refusée');
            _isUpdating = false;
            return;
          }
        }
      }

      // 2. Exécution de la mise à jour (Téléchargement + Installation automatique)
      OtaUpdate().execute(
        url,
        destinationFilename: 'salama_mamba_update.apk',
      ).listen(
        (OtaEvent event) {
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              EasyLoading.showProgress(
                (double.tryParse(event.value ?? '0') ?? 0) / 100,
                status: 'Téléchargement : ${event.value}%',
              );
              break;
            case OtaStatus.INSTALLING:
              EasyLoading.showSuccess('Installation en cours...');
              _isUpdating = false;
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
              EasyLoading.showError('Mise à jour déjà en cours');
              _isUpdating = false;
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              EasyLoading.showError('Permission de stockage refusée');
              _isUpdating = false;
              break;
            case OtaStatus.INTERNAL_ERROR:
              EasyLoading.showError('Erreur interne lors de la mise à jour');
              _isUpdating = false;
              break;
            case OtaStatus.DOWNLOAD_ERROR:
              EasyLoading.showError('Erreur de téléchargement');
              _isUpdating = false;
              break;
            default:
              EasyLoading.dismiss();
              break;
          }
        },
        onError: (e) {
          EasyLoading.showError('Erreur fatale : $e');
          _isUpdating = false;
        },
      );
    } catch (e) {
      EasyLoading.showError('Erreur mise à jour : $e');
      _isUpdating = false;
    }
  }
}
