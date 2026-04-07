import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/kernel/services/http_manager.dart';
import '/themes/app_theme.dart';
import '/widgets/costum_button.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';

Future<dynamic> showRecognitionModal(BuildContext context,
    {String key = "",
    String comment = "",
    siteId = "",
    scheduleId = "",
    VoidCallback? onValidate}) async {
  List<CameraDescription> cameras = [];
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  try {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[tagsController.cameraIndex.value],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  } catch (e) {
    if (kDebugMode) {
      print("Erreur d'initialisation de la caméra : $e");
    }
  }
  
  tagsController.face.value = null;
  tagsController.faceResult.value = "";

  // Fonction pour réinitialiser la luminosité
  Future<void> _restoreBrightness() async {
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      debugPrint("ScreenBrightness Error: $e");
    }
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WillPopScope(
      onWillPop: () async {
        await _restoreBrightness();
        return true;
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: Column(
            children: [
              // Header Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Text(
                "authentication".tr.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Staatliches',
                  letterSpacing: 1.5,
                  color: Color(0xFF16161E),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "auth_desc".tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const SizedBox(height: 25),
      
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Face Preview or Captured Image
                      Center(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: tagsController.face.value != null 
                                ? (tagsController.faceResult.value != 'Inconnu' ? Colors.greenAccent : Colors.redAccent)
                                : primaryMaterialColor.withOpacity(0.2), 
                              width: 4
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: tagsController.face.value != null
                              ? Image.file(File(tagsController.face.value!.path), fit: BoxFit.cover)
                              : FutureBuilder(
                                  future: _initializeControllerFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      return FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: _controller.value.previewSize?.height ?? 260,
                                          height: _controller.value.previewSize?.width ?? 260,
                                          child: CameraPreview(_controller),
                                        ),
                                      );
                                    } else {
                                      return const Center(child: CircularProgressIndicator(color: primaryMaterialColor));
                                    }
                                  },
                                ),
                          ),
                        ),
                      ),
                      
                      if (tagsController.faceResult.value.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: tagsController.faceResult.value != 'Inconnu' 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            tagsController.faceResult.value.toUpperCase(),
                            style: TextStyle(
                              fontFamily: "Staatliches",
                              fontSize: 16,
                              color: tagsController.faceResult.value != 'Inconnu' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
      
                      const SizedBox(height: 30),
      
                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCircleAction(
                            icon: tagsController.face.value == null ? Icons.camera_alt_rounded : Icons.refresh_rounded,
                            color: tagsController.face.value == null ? primaryMaterialColor : Colors.orangeAccent,
                            onTap: () async {
                              if (!_controller.value.isInitialized) return;
                              if (tagsController.face.value != null) {
                                tagsController.face.value = null;
                                tagsController.faceResult.value = "";
                                return;
                              }
                              try {
                                final file = await _controller.takePicture();
                                tagsController.face.value = XFile(file.path);
                                
                                faceRecognitionController.isRecognitionLoading.value = true;
                                final result = await faceRecognitionController.recognizeFaceFromImage(file);
                                tagsController.faceResult.value = result ?? "Inconnu";
                                faceRecognitionController.isRecognitionLoading.value = false;
                              } catch (e) {
                                debugPrint("Capture error: $e");
                              }
                            },
                            isLoading: faceRecognitionController.isRecognitionLoading.value,
                          ),
                          const SizedBox(width: 25),
                          _buildCircleAction(
                            icon: tagsController.isFlashOn.value ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                            color: Colors.indigoAccent,
                            onTap: () async {
                              tagsController.isFlashOn.value = !tagsController.isFlashOn.value;
                              
                              if (tagsController.cameraIndex.value == 1) { // Camera Frontale
                                if (tagsController.isFlashOn.value) {
                                  await ScreenBrightness().setScreenBrightness(1.0);
                                } else {
                                  await ScreenBrightness().resetScreenBrightness();
                                }
                              } else { // Camera Arrière
                                await _controller.setFlashMode(
                                  tagsController.isFlashOn.value ? FlashMode.torch : FlashMode.off
                                );
                              }
                            },
                          ),
                        ],
                      ),
      
                      const SizedBox(height: 40),
      
                      // Validation Button
                      if (tagsController.face.value != null && tagsController.faceResult.value != "Inconnu" && !faceRecognitionController.isRecognitionLoading.value)
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: CostumButton(
                            title: "valider_action".tr,
                            isLoading: tagsController.isLoading.value,
                            bgColor: primaryMaterialColor,
                            labelColor: Colors.white,
                            onPress: () async {
                              try {
                                bool success = false;
                                if (key == "check-in") success = await checkPresence("check-in");
                                if (key == "check-out") success = await checkPresence("check-out");
                                if (key == "patrol") success = await startPatrol(comment: comment);
                                if (key == "close") success = await closePatrol(comment: comment);
                                if (key == "supervize-in") {
                                  onValidate?.call();
                                  success = true;
                                }
                                if (key == "supervize-out") {
                                  onValidate?.call();
                                  success = true;
                                }
                                
                                if (success) {
                                  await _restoreBrightness();
                                  await _controller.dispose();
                                  Get.back(); // Ferme recognition_face_modal
                                  if (key == "patrol") {
                                    Get.back(); // Ferme scanning_completer_modal
                                    onValidate?.call(); // Relance le scanner
                                  }
                                }
                              } catch (e) {
                                EasyLoading.showError("Erreur : $e");
                              }
                            },
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildCircleAction({required IconData icon, required Color color, required VoidCallback onTap, bool isLoading = false}) {
  return GestureDetector(
    onTap: isLoading ? null : onTap,
    child: Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Center(
        child: isLoading 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: primaryMaterialColor))
          : Icon(icon, color: color, size: 30),
      ),
    ),
  );
}

Future<bool> checkPresence(String key) async {
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  final value = await manager.checkPresence(key: key);
  tagsController.isLoading.value = false;
  if (value != null) {
    EasyLoading.showSuccess(value.toString());
    return true;
  }
  return false;
}

Future<bool> closePatrol({String comment = ""}) async {
  if (tagsController.faceResult.value != authController.userSession.value!.matricule) {
    EasyLoading.showInfo("Le matricule agent ne correspond pas.");
    return false;
  }
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  final value = await manager.stopPendingPatrol(comment);
  tagsController.isLoading.value = false;
  if (value != null) {
    EasyLoading.showSuccess(value.toString());
    return true;
  }
  return false;
}

Future<bool> startPatrol({String comment = ""}) async {
  if (authController.userSession.value!.matricule!.trim() != tagsController.faceResult.value.trim()) {
    EasyLoading.showInfo("Le matricule agent ne correspond pas.");
    return false;
  }
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  final value = await manager.beginPatrol(comment);
  tagsController.isLoading.value = false;
  if (value != null) {
    EasyLoading.showSuccess(value.toString());
    return true;
  }
  return false;
}
