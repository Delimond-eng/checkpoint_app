import 'dart:io';

import 'package:camera/camera.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:checkpoint_app/widgets/costum_icon_button.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:checkpoint_app/widgets/user_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../constants/styles.dart';

class EnrollFacePage extends StatefulWidget {
  const EnrollFacePage({super.key});

  @override
  State<EnrollFacePage> createState() => _EnrollFacePageState();
}

class _EnrollFacePageState extends State<EnrollFacePage> {
  final TextEditingController _matriculeController = TextEditingController();

  List<CameraDescription> cameras = [];
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  int _cameraIndex = 1; // 1 = front, 0 = back
  bool _isFlashOn = false;

  String result = '';
  bool isLoading = false;

  XFile? pickedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(
        cameras[_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    } catch (e) {
      print("Erreur d'initialisation de la caméra : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "Enrôlement visage",
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w900,
            color: whiteColor,
            fontFamily: 'Staatliches',
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          const UserStatus(name: "Gaston delimond").marginAll(8.0),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Cliquez pour prendre la photo du visage de l'agent à enroller.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: primaryMaterialColor,
                      fontWeight: FontWeight.w500,
                    ),
              ).paddingBottom(15.0),
              if (pickedImage != null) ...[
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
                        File(pickedImage!.path),
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
                              width:
                                  _controller.value.previewSize?.height ?? 250,
                              height:
                                  _controller.value.previewSize?.width ?? 250,
                              child: CameraPreview(_controller),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return _loaderWidget();
                    }
                  },
                ).paddingBottom(15.0),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CostumIconButton(
                    color: Colors.blue.shade800,
                    svg: "camera-toggle.svg",
                    size: 60.0,
                    onPress: _switchCamera,
                  ).paddingRight(8.0),
                  CostumIconButton(
                    svg: pickedImage == null
                        ? "camera-capture.svg"
                        : "camera-refresh.svg",
                    color: pickedImage == null
                        ? Colors.deepPurple
                        : Colors.green.shade400,
                    size: 80.0,
                    onPress: _capturePhoto,
                  ).paddingRight(8.0),
                  CostumIconButton(
                    svg: _isFlashOn ? "flash-on-2.svg" : "flash-on-1.svg",
                    size: 60.0,
                    color: _cameraIndex == 1
                        ? Colors.blue.shade200
                        : Colors.blue.shade800,
                    onPress: _toggleFlash,
                  ),
                ],
              ).paddingBottom(15.0),
              if (pickedImage != null) ...[
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _matriculeController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: "Matricule de l'agent",
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      )
                    ],
                  ).paddingHorizontal(8.0),
                ).paddingBottom(10.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 55.0,
                  child: CostumButton(
                    title: "Enroller",
                    bgColor: primaryMaterialColor,
                    labelColor: whiteColor,
                    isLoading: isLoading,
                    onPress: _enroll,
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _loaderWidget() {
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

  void _toggleFlash() async {
    if (_cameraIndex == 0) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      await _controller
          .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } else {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      if (_isFlashOn) {
        await ScreenBrightness().setScreenBrightness(1.0);
      } else {
        await ScreenBrightness().resetApplicationScreenBrightness();
      }
    }
  }

  void _switchCamera() async {
    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    await _controller.dispose();
    await _initCamera();
  }

  Future<void> _capturePhoto() async {
    if (!_controller.value.isInitialized) return;

    if (pickedImage != null) {
      setState(() {
        pickedImage = null;
      });
      return;
    }
    try {
      final file = await _controller.takePicture();
      setState(() {
        pickedImage = XFile(file.path);
      });
      tagsController.face.value = pickedImage;
    } catch (e) {
      print("Erreur capture : $e");
    }
  }

  Future<void> _enroll() async {
    final matricule = _matriculeController.text.trim();
    if (matricule.isEmpty) {
      EasyLoading.showToast("Entrez le matricule de l'agent !");
      return;
    }

    final embedding = faceRecognitionController.getEmbedding(pickedImage!);
    // ignore: unnecessary_null_comparison
    if (embedding == null) {
      EasyLoading.showInfo(
          "Aucun visage détecté. veuillez prendre une photo du visage !");
      return;
    }

    setState(() => isLoading = true);

    var manager = HttpManager();
    tagsController.isLoading.value = true;
    await faceRecognitionController.addKnownFaceFromImage(
        matricule, pickedImage!);
    manager.enrollAgent(matricule).then((value) {
      _matriculeController.clear();
      pickedImage = null;
      tagsController.face.value = null;
      setState(() => isLoading = false);
      if (value != "success") {
        EasyLoading.showInfo(value);
      } else {
        EasyLoading.showSuccess(
          "Données transmises avec succès !",
        );
      }
    });
  }
}
