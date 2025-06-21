import 'dart:io';

import 'package:camera/camera.dart';
import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/modal.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:checkpoint_app/pages/supervisor_agent.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../widgets/costum_icon_button.dart';
import '../widgets/svg.dart';
import 'utils.dart';

Future<void> showRecognitionModal(context,
    {String key = "",
    String comment = "",
    siteId = "",
    scheduleId = ""}) async {
  List<CameraDescription> cameras = [];
  /* final TextEditingController _matriculeText = TextEditingController(); */
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
    if (kDebugMode) {
      print("Erreur d'initialisation de la caméra : $e");
    }
  }
  tagsController.face.value = null;
  tagsController.faceResult.value = "";

  showCustomModal(
    context,
    onClosed: () {
      tagsController.face.value = null;
      tagsController.faceResult.value = "";
      _controller.dispose();
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
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  DottedBorder(
                    color: tagsController.faceResult.value != 'Inconnu'
                        ? Colors.green.shade400
                        : Colors.red,
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
                  ),
                  if (tagsController.faceResult.value.isNotEmpty) ...[
                    Positioned(
                      bottom: -15.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: tagsController.faceResult.value != 'Inconnu'
                              ? Colors.green.withOpacity(.8)
                              : Colors.red.withOpacity(.8),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          tagsController.faceResult.value,
                          style: const TextStyle(
                            fontFamily: "Staatliches",
                            fontSize: 15.0,
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ]
                ],
              ).paddingBottom(25.0),
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
                    tagsController.face.value = null;
                    tagsController.faceResult.value = "";
                    try {
                      final file = await _controller.takePicture();
                      tagsController.face.value = XFile(file.path);
                      await Future.delayed(Duration.zero);
                      faceRecognitionController.isRecognitionLoading.value =
                          true;
                      final faceResult = await faceRecognitionController
                          .recognizeFaceFromImage(file);
                      if (faceResult != null) {
                        /* _matriculeText.text = faceResult; */
                        tagsController.faceResult.value = faceResult;
                        faceRecognitionController.isRecognitionLoading.value =
                            false;
                        tagsController.isLoading.value = false;
                      } else {
                        tagsController.isLoading.value = false;
                        faceRecognitionController.isRecognitionLoading.value =
                            false;
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print("Erreur capture : $e");
                      }
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
            ).paddingBottom(10.0),
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
                          /* if (tagsController.faceResult.value.isNotEmpty &&
                              tagsController.faceResult.value != "Inconnu") ...[
                            const Text(
                              "Reconnaissance faciale matricule agent trouvé ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 10.0,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            //input face result here...
                            EnrollInput(
                              controller: _matriculeText,
                              isActive: _matriculeText.text.isNotEmpty,
                            )
                          ], */
                          if ((tagsController.faceResult.value.isNotEmpty &&
                              tagsController.faceResult.value !=
                                  "Inconnu")) ...[
                            CostumButton(
                              borderColor: Colors.blue.shade300,
                              title: "Valider",
                              isLoading: tagsController.isLoading.value,
                              bgColor: Colors.blue,
                              labelColor: Colors.white,
                              onPress: () async {
                                if (key.isEmpty) {
                                  checkPresence();
                                  _controller.dispose();
                                } else {
                                  if (key == "patrol") {
                                    await startPatrol(comment: comment);
                                    _controller.dispose();
                                    Get.back();
                                  }
                                  if (key == "close") {
                                    await closePatrol(comment: comment);
                                    _controller.dispose();
                                    Get.back();
                                  }

                                  if (key == "supervize-in") {
                                    DGCustomDialog.showInteraction(context,
                                        message:
                                            "Etes-vous sûr de vouloir commencer cette supervision ?",
                                        onValidated: () {
                                      supervizeStart(siteId, scheduleId)
                                          .then((v) {
                                        tagsController.isLoading.value = false;
                                        if (v == "success") {
                                          _controller.dispose();
                                          Get.back();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SupervisorAgent(),
                                            ),
                                          );
                                        } else {
                                          EasyLoading.showInfo(
                                              "Echec de traitement, veuillez recommencer SVP !");
                                        }
                                      });
                                    });
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
    tagsController.faceResult.value = "";
    tagsController.face.value = null;
    if (value != "success") {
      EasyLoading.showSuccess(value);
      Get.back();
    } else {
      tagsController.faceResult.value = "";
      tagsController.face.value = null;
      Get.back();
      EasyLoading.showSuccess(
        "Présence signalée avec succès !",
      );
    }
  });
}

Future<void> closePatrol({String comment = ""}) async {
  if (tagsController.faceResult.value !=
      authController.userSession.value.matricule) {
    EasyLoading.showInfo(
        "Le matricule agent ne correspond pas.connectez-vous avec un compte vous appartenant.");
    return;
  }
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  manager.stopPendingPatrol(comment).then((value) {
    tagsController.isLoading.value = false;
    tagsController.faceResult.value = "";
    tagsController.face.value = null;
    if (value is String) {
      EasyLoading.showToast(value);
      Get.back();
    } else {
      EasyLoading.showSuccess(
        "Patrouille cloturée avec succès !",
      );
      Get.back();
    }
  });
}

Future<void> startPatrol({String comment = ""}) async {
  if (authController.userSession.value.matricule!.trim() !=
      tagsController.faceResult.value.trim()) {
    EasyLoading.showInfo(
        "Le matricule agent ne correspond pas.connectez-vous avec un compte vous appartenant.");
    return;
  }
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  manager.beginPatrol(comment).then((value) {
    tagsController.isLoading.value = false;
    tagsController.faceResult.value = "";
    tagsController.face.value = null;
    if (value is String) {
      EasyLoading.showToast(value);
      Get.back();
    } else {
      EasyLoading.showSuccess(
        "Zone patrouille scanné avec succès !",
      );
      Get.back();
    }
  });
}

Future<dynamic> supervizeStart(siteId, scheduleId) async {
  if (kDebugMode) {
    print("start supervision...");
    print("siteID : $siteId");
    print("planningID : $scheduleId");
  }
  if (authController.userSession.value.matricule!.trim() !=
      tagsController.faceResult.value.trim()) {
    EasyLoading.showInfo(
        "Le matricule agent ne correspond pas.connectez-vous avec un compte vous appartenant.");
    return;
  }
  var manager = HttpManager();
  tagsController.isLoading.value = true;
  var value = await manager.makeSupervision(siteId, scheduleId);
  tagsController.isLoading.value = false;
  tagsController.faceResult.value = "";
  tagsController.face.value = null;
  if (value is String) {
    return "errors";
  } else {
    EasyLoading.showSuccess(
      "Bienvenue, vous avez commencer une nouvelle supervision !",
    );
    return "success";
  }
}
