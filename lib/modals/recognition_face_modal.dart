import 'dart:io';

import 'package:camera/camera.dart';
import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../widgets/costum_icon_button.dart';
import '../widgets/svg.dart';
import 'utils.dart';

Future<void> showRecognitionModal(context,
    {String key = "", String comment = "", VoidCallback? onClosed}) async {
  List<CameraDescription> cameras = [];
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  await Future.delayed(Duration.zero);
  try {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[tagsController.cameraIndex.value],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  } catch (e) {
    print("Erreur d'initialisation de la caméra : $e");
  }
  showCustomModal(
    context,
    onClosed: () {
      tagsController.face.value = null;
      tagsController.faceResult.value = "";
      _controller.dispose();
      onClosed!();
    },
    title: "Reconnaissance faciale",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (tagsController.face.value != null) ...[
              DottedBorder(
                color: Colors.green.shade400,
                radius: const Radius.circular(130.0),
                strokeWidth: 1.2,
                borderType: BorderType.RRect,
                dashPattern: const [6, 3],
                child: CircleAvatar(
                  radius: 120.0,
                  backgroundColor: darkColor,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(240.0),
                    ),
                    child: Image.file(
                      width: 240.0,
                      height: 240.0,
                      File(tagsController.face.value!.path),
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ).paddingBottom(15.0),
            ] else ...[
              FutureBuilder(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ClipOval(
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.previewSize?.height ?? 250,
                            height: _controller.value.previewSize?.width ?? 250,
                            child: CameraPreview(_controller),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 220.0,
                          width: 220.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 4.0,
                            color: primaryMaterialColor.shade300,
                          ),
                        ),
                        SizedBox(
                          height: 220.0,
                          width: 220.0,
                          child: DottedBorder(
                            color: primaryMaterialColor.shade500,
                            radius: const Radius.circular(110.0),
                            strokeWidth: 1.2,
                            borderType: BorderType.RRect,
                            dashPattern: const [6, 3],
                            child: const Center(
                              child: Svg(
                                size: 40.0,
                                path: "camera-refresh.svg",
                                color: primaryMaterialColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ).paddingBottom(15.0),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CostumIconButton(
                  isLoading:
                      faceRecognitionController.isRecognitionLoading.value,
                  svg: tagsController.face.value == null
                      ? "camera-capture.svg"
                      : "camera-refresh.svg",
                  color: tagsController.face.value == null
                      ? Colors.deepPurple
                      : Colors.green.shade400,
                  size: 80.0,
                  onPress: () async {
                    if (!_controller.value.isInitialized) return;
                    if (tagsController.face.value != null) {
                      tagsController.face.value = null;
                      return;
                    }
                    try {
                      final file = await _controller.takePicture();
                      tagsController.face.value = XFile(file.path);
                      await Future.delayed(Duration.zero);
                      faceRecognitionController.isRecognitionLoading.value =
                          true;
                      final faceResult = await faceRecognitionController
                          .recognizeFaceFromImage(file);
                      tagsController.faceResult.value = faceResult;
                      faceRecognitionController.isRecognitionLoading.value =
                          false;
                      tagsController.isLoading.value = false;
                    } catch (e) {
                      print("Erreur capture : $e");
                    }
                  },
                ).paddingRight(8.0),
                CostumIconButton(
                  svg: tagsController.isFlashOn.value
                      ? "flash-on-2.svg"
                      : "flash-on-1.svg",
                  size: 80.0,
                  color: tagsController.cameraIndex.value == 1
                      ? Colors.blue.shade200
                      : Colors.blue.shade800,
                  onPress: () async {
                    if (tagsController.cameraIndex.value == 0) {
                      tagsController.isFlashOn.value =
                          !tagsController.isFlashOn.value;
                      await _controller.setFlashMode(
                          tagsController.isFlashOn.value
                              ? FlashMode.torch
                              : FlashMode.off);
                    } else {
                      tagsController.isFlashOn.value =
                          !tagsController.isFlashOn.value;
                      if (tagsController.isFlashOn.value) {
                        await ScreenBrightness().setScreenBrightness(1.0);
                      } else {
                        await ScreenBrightness()
                            .resetApplicationScreenBrightness();
                      }
                    }
                  },
                ),
              ],
            ).paddingBottom(15.0),
            if (tagsController.face.value != null) ...[
              Container(
                padding: const EdgeInsets.all(5.0),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tagsController.faceResult.value.isNotEmpty &&
                              tagsController.faceResult.value != "Inconnu")
                            const Text(
                              "Reconnaissance faciale résultat ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 10.0,
                              ),
                            ),
                          const SizedBox(height: 4.0),
                          Text(
                            tagsController.faceResult.value.isNotEmpty &&
                                    tagsController.faceResult.value != "Inconnu"
                                ? "Matricule Agent : ${tagsController.faceResult.value}"
                                : tagsController.faceResult.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Staatliches',
                              color: tagsController.faceResult.value !=
                                          "Inconnu" ||
                                      !tagsController.faceResult.value
                                          .contains("Impossible")
                                  ? Colors.green
                                  : primaryMaterialColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.0,
                            ),
                          ),
                          if ((tagsController.faceResult.value.isNotEmpty &&
                              tagsController.faceResult.value !=
                                  "Inconnu")) ...[
                            CostumButton(
                              borderColor: Colors.green.shade200,
                              title: "Valider",
                              isLoading: tagsController.isLoading.value,
                              bgColor: Colors.green,
                              labelColor: Colors.white,
                              onPress: () async {
                                if (key.isEmpty) {
                                  await checkPresence();
                                  _controller.dispose();
                                  onClosed!();
                                } else {
                                  if (key == "patrol") {
                                    await startPatrol(comment: comment);
                                    _controller.dispose();
                                    onClosed!();
                                    Get.back();
                                  }
                                  if (key == "close") {
                                    await closePatrol(comment: comment);
                                    _controller.dispose();
                                    onClosed!();
                                    Get.back();
                                  }
                                }
                              },
                            ).paddingTop(10.0)
                          ]
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    ),
  );
}

Future<void> checkPresence() async {
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  manager.checkPresence().then((value) {
    tagsController.isLoading.value = false;
    if (value != "success") {
      EasyLoading.showInfo(value);
    } else {
      tagsController.faceResult.value = "";
      tagsController.face.value = null;
      tagsController.isScanningModalOpen.value = false;
      Get.back();
      EasyLoading.showSuccess(
        "Présence signalée avec succès !",
      );
    }
  });
}

Future<void> closePatrol({String comment = ""}) async {
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  manager.stopPendingPatrol(comment).then((value) {
    tagsController.isLoading.value = false;
    tagsController.isScanningModalOpen.value = false;
    tagsController.isQrcodeScanned.value = false;
    tagsController.faceResult.value = "";
    tagsController.face.value = null;
    if (value is String) {
      EasyLoading.showToast(value);
    } else {
      EasyLoading.showSuccess(
        "Données transmises avec succès !",
      );
      Get.back();
    }
  });
}

Future<void> startPatrol({String comment = ""}) async {
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  manager.beginPatrol(comment).then((value) {
    tagsController.isLoading.value = false;
    tagsController.faceResult.value = "";
    tagsController.face.value = null;
    tagsController.isScanningModalOpen.value = false;
    tagsController.isQrcodeScanned.value = false;
    if (value is String) {
      EasyLoading.showToast(value);
    } else {
      EasyLoading.showSuccess(
        "Zone patrouille scanné avec succès !",
      );
      Get.back();
    }
  });
}
