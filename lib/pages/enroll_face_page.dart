import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '/global/controllers.dart';
import '/kernel/services/http_manager.dart';
import '/themes/app_theme.dart';
import '/widgets/user_status.dart';
import '../constants/styles.dart';

class EnrollFacePage extends StatefulWidget {
  const EnrollFacePage({super.key});

  @override
  State<EnrollFacePage> createState() => _EnrollFacePageState();
}

class _EnrollFacePageState extends State<EnrollFacePage> {
  CameraController? _controller;
  XFile? _capturedImage;
  bool _isDetecting = false;
  bool _facePresent = false;
  bool _isCapturing = false;
  int _cameraIndex = 1; // Default to front camera
  List<CameraDescription> _cameras = [];
  final TextEditingController _matriculeController = TextEditingController();
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    _controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});

      _controller!.startImageStream((image) {
        if (_isDetecting || _capturedImage != null) return;
        _isDetecting = true;
        _checkFacePresence(image);
      });
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    
    _cameraIndex = (_cameraIndex == 1) ? 0 : 1;
    if (_controller != null) {
      await _controller!.dispose();
    }
    _initCamera();
  }

  Future<void> _checkFacePresence(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isDetecting = false;
      return;
    }

    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (mounted) {
        setState(() {
          _facePresent = faces.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint("Face detection error: $e");
    }
    _isDetecting = false;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final bytes = Uint8List.fromList(
        image.planes.fold<List<int>>([], (buffer, plane) => buffer..addAll(plane.bytes)),
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation270deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing || !_facePresent) return;

    setState(() => _isCapturing = true);
    try {
      final photo = await _controller!.takePicture();
      setState(() {
        _capturedImage = photo;
      });
      await _controller!.stopImageStream();
    } catch (e) {
      EasyLoading.showError("Erreur lors de la capture");
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _submitEnroll() async {
    final matricule = _matriculeController.text.trim();
    if (matricule.isEmpty) {
      EasyLoading.showInfo("Matricule requis");
      return;
    }
    
    EasyLoading.show(status: 'Analyse biométrique...');
    
    try {
      final embedding = await faceRecognitionController.getEmbedding(_capturedImage!);
      if (embedding == null || embedding.isEmpty) {
        EasyLoading.showError("Échec de l'analyse faciale.");
        return;
      }

      tagsController.face.value = _capturedImage;
      final response = await HttpManager().enrollAgent(matricule, embedding);
      
      if (response == "success") {
        await faceRecognitionController.addKnownFaceFromImage(
          matricule,
          _capturedImage!,
        );

        EasyLoading.showSuccess("Agent $matricule enrôlé avec succès");
        Get.back();
      } else {
        EasyLoading.showError(response.toString());
      }
    } catch (e) {
      EasyLoading.showError("Échec : $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    _matriculeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F), // Dark Theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: const Text(
          "ENRÔLEMENT VISAGE",
          style: TextStyle(fontFamily: 'Staatliches', letterSpacing: 1.5, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: UserStatus(name: ""),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _capturedImage != null 
                          ? "Vérifiez les informations" 
                          : (_facePresent ? "Visage détecté : Prêt" : "Positionnez le visage dans le cercle"),
                        style: TextStyle(
                          color: _facePresent ? Colors.greenAccent : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Camera / Preview Circle
                      Center(
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _capturedImage != null 
                                ? Colors.greenAccent 
                                : (_facePresent ? Colors.greenAccent : Colors.blueAccent.withOpacity(0.5)), 
                              width: 4
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_facePresent ? Colors.greenAccent : Colors.blueAccent).withOpacity(0.2),
                                blurRadius: 20,
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: _capturedImage != null
                              ? Image.file(File(_capturedImage!.path), fit: BoxFit.cover)
                              : (_controller != null && _controller!.value.isInitialized)
                                  ? FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width: _controller!.value.previewSize?.height,
                                        height: _controller!.value.previewSize?.width,
                                        child: CameraPreview(_controller!),
                                      ),
                                    )
                                  : const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      if (_capturedImage == null)
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: ElevatedButton.icon(
                                onPressed: (_isCapturing || !_facePresent) ? null : _capturePhoto,
                                icon: _isCapturing 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.camera_alt_rounded),
                                label: const Text("CAPTURER", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Staatliches')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryMaterialColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.white30,
                                  disabledForegroundColor: Colors.grey.shade400,
                                  minimumSize: const Size(0, 60),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: IconButton(
                                onPressed: _toggleCamera,
                                icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 28),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _matriculeController,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Ubuntu'),
                                    decoration: InputDecoration(
                                      labelText: "Matricule de l'agent",
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      hintText: "Saisir le matricule",
                                      hintStyle: const TextStyle(color: Colors.white24),
                                      prefixIcon: const Icon(Icons.badge_rounded, color: primaryMaterialColor),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: primaryMaterialColor)),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _capturedImage = null;
                                              _initCamera(); 
                                            });
                                          },
                                          child: const Text("REPRENDRE", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _submitEnroll,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent.shade700,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(0, 50),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          ),
                                          child: const Text("VALIDER", style: TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
