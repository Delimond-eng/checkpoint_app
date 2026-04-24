import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ota_update/ota_update.dart';
import '/constants/styles.dart';

class OtaService {
  static final OtaService instance = OtaService._init();
  OtaService._init();

  bool _isUpdating = false;
  final RxString _statusMessage = 'Initialisation...'.obs;
  final RxDouble _progressValue = 0.0.obs;

  Future<void> updateApp(String url) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      // 1. Demande de permission
      if (Platform.isAndroid) {
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

      // 2. Affichage du modal plein écran
      _showUpdateModal();

      // 3. Exécution de la mise à jour
      OtaUpdate().execute(
        url,
        destinationFilename: 'salama_mamba_update.apk',
      ).listen(
        (OtaEvent event) {
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              _statusMessage.value = 'Téléchargement de la mise à jour...';
              _progressValue.value = (double.tryParse(event.value ?? '0') ?? 0) / 100;
              break;
            case OtaStatus.INSTALLING:
              _statusMessage.value = 'Installation en cours...';
              // On ferme le modal après un délai ou on laisse le système Android prendre le relais
              Future.delayed(const Duration(seconds: 3), () {
                if (Get.isDialogOpen!) Get.back();
                _isUpdating = false;
              });
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
              _handleError('Mise à jour déjà en cours');
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              _handleError('Permission de stockage refusée');
              break;
            case OtaStatus.DOWNLOAD_ERROR:
              _handleError('Erreur lors du téléchargement de l\'APK');
              break;
            case OtaStatus.INTERNAL_ERROR:
              _handleError('Erreur interne du système');
              break;
            default:
              break;
          }
        },
        onError: (e) => _handleError('Erreur fatale : $e'),
      );
    } catch (e) {
      _handleError('Erreur : $e');
    }
  }

  void _showUpdateModal() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Empêche de fermer avec le bouton retour
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Scaffold(
            backgroundColor: const Color(0xFF0B0B0F).withOpacity(0.85),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitFoldingCube(color: primaryMaterialColor, size: 50),
                    const SizedBox(height: 40),
                    const Text(
                      "MISE À JOUR DU SYSTÈME",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Staatliches',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Obx(() => Text(
                      _statusMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Ubuntu'),
                    )),
                    const SizedBox(height: 30),
                    
                    // Barre de progression
                    Obx(() => Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progressValue.value,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(primaryMaterialColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${(_progressValue.value * 100).toInt()}%",
                          style: const TextStyle(color: primaryMaterialColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    )),
                    
                    const SizedBox(height: 50),
                    const Text(
                      "Veuillez ne pas fermer l'application pendant cette opération.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _handleError(String message) {
    _isUpdating = false;
    if (Get.isDialogOpen!) Get.back();
    EasyLoading.showError(message);
  }
}
