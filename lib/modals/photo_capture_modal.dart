import 'dart:io';

import 'package:camera/camera.dart';
import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/costum_icon_button.dart';
import '../widgets/svg.dart';
import 'utils.dart';

Future<dynamic> showPhotoCaptureModal(context,
    {Function(File file)? onValidate}) async {
  List<CameraDescription> cameras = [];
  /* final TextEditingController _matriculeText = TextEditingController(); */
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  await Future.delayed(Duration.zero);
  try {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  } catch (e) {
    if (kDebugMode) {
      print("Erreur d'initialisation de la caméra : $e");
    }
  }
  bool _isFlashOn = false;

  showCustomModal(
    context,
    onClosed: () {
      _controller.dispose();
    },
    title: "Capture photo",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ClipOval(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.previewSize?.height ?? 300,
                        height: _controller.value.previewSize?.width ?? 300,
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
                      height: 250.0,
                      width: 250.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0,
                        color: primaryMaterialColor.shade300,
                      ),
                    ),
                    SizedBox(
                      height: 250.0,
                      width: 250.0,
                      child: DottedBorder(
                        color: primaryMaterialColor.shade500,
                        radius: const Radius.circular(250.0),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CostumIconButton(
                svg: "camera-capture.svg",
                color: primaryMaterialColor,
                size: 80.0,
                onPress: () async {
                  try {
                    final file = await _controller.takePicture();
                    Get.back();
                    onValidate!.call(File(file.path));
                  } catch (e) {
                    if (kDebugMode) {
                      print("Erreur capture : $e");
                    }
                  }
                },
              ).paddingRight(8.0),
              StatefulBuilder(
                builder: (context, setter) => CostumIconButton(
                  svg: _isFlashOn ? "flash-on-2.svg" : "flash-on-1.svg",
                  size: 80.0,
                  color: Colors.blue.shade800,
                  onPress: () async {
                    setter(() {
                      _isFlashOn = !_isFlashOn;
                    });
                    await _controller.setFlashMode(
                        _isFlashOn ? FlashMode.torch : FlashMode.off);
                  },
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}
