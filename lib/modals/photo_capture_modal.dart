import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import '/constants/styles.dart';
import '/themes/app_theme.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/costum_icon_button.dart';
import '../widgets/svg.dart';

Future<dynamic> showPhotoCaptureModal(BuildContext context,
    {Function(File file)? onValidate}) async {
  List<CameraDescription> cameras = [];
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

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

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            
            const Text(
              "CAPTURE PHOTO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Staatliches',
                letterSpacing: 1.5,
                color: Color(0xFF16161E),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Prenez une photo pour justifier l'action.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontFamily: 'Ubuntu',
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Camera Preview Circle
                    Center(
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryMaterialColor.withOpacity(0.2), width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: FutureBuilder(
                            future: _initializeControllerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                return FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _controller.value.previewSize?.height ?? 280,
                                    height: _controller.value.previewSize?.width ?? 280,
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
                    
                    const SizedBox(height: 40),

                    // Controls
                    StatefulBuilder(
                      builder: (context, setter) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Capture Button
                          GestureDetector(
                            onTap: () async {
                              try {
                                final file = await _controller.takePicture();
                                await _controller.dispose();
                                Get.back();
                                onValidate?.call(File(file.path));
                              } catch (e) {
                                debugPrint("Capture error: $e");
                              }
                            },
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: primaryMaterialColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryMaterialColor.withOpacity(0.2), width: 2),
                              ),
                              child: const Center(
                                child: Icon(Icons.camera_rounded, color: primaryMaterialColor, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          // Flash Button
                          GestureDetector(
                            onTap: () async {
                              setter(() {
                                _isFlashOn = !_isFlashOn;
                              });
                              await _controller.setFlashMode(
                                _isFlashOn ? FlashMode.torch : FlashMode.off
                              );
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 2),
                              ),
                              child: Icon(
                                _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, 
                                color: Colors.blueAccent, 
                                size: 28
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
