import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import '/constants/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<void> showMediaCaptureModal(BuildContext context, {required Function(File file) onMediaCaptured}) async {
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    EasyLoading.showError("error".tr);
    return;
  }

  if (cameras.isEmpty) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _MediaCaptureContent(cameras: cameras, onMediaCaptured: onMediaCaptured),
  );
}

class _MediaCaptureContent extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(File file) onMediaCaptured;

  const _MediaCaptureContent({required this.cameras, required this.onMediaCaptured});

  @override
  State<_MediaCaptureContent> createState() => _MediaCaptureContentState();
}

class _MediaCaptureContentState extends State<_MediaCaptureContent> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  bool _isFlashOn = false;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    int backCameraIndex = widget.cameras.indexWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back
    );
    _cameraIndex = backCameraIndex != -1 ? backCameraIndex : 0;
    _initCamera();
  }

  void _initCamera() {
    _controller = CameraController(
      widget.cameras[_cameraIndex],
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCamera() async {
    _cameraIndex = (_cameraIndex + 1) % widget.cameras.length;
    await _controller.dispose();
    setState(() {
      _initCamera();
    });
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      widget.onMediaCaptured(File(image.path));
      Navigator.pop(context);
    } catch (e) {
      EasyLoading.showError("error".tr);
    }
  }

  Future<void> _toggleRecording() async {
    try {
      await _initializeControllerFuture;
      if (_isRecording) {
        final video = await _controller.stopVideoRecording();
        setState(() => _isRecording = false);
        widget.onMediaCaptured(File(video.path));
        Navigator.pop(context);
      } else {
        await _controller.startVideoRecording();
        setState(() => _isRecording = true);
      }
    } catch (e) {
      EasyLoading.showError("error".tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35), topRight: Radius.circular(35)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Text(
              "CAPTURE MÉDIA".tr,
              style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Staatliches',
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.previewSize?.height ?? 1,
                            height: _controller.value.previewSize?.width ?? 1,
                            child: CameraPreview(_controller),
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator(
                            color: primaryMaterialColor));
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSmallAction(
                    icon: Icons.flip_camera_ios_rounded,
                    onTap: _toggleCamera,
                  ),

                  if (!_isRecording)
                    GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        height: 80, width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: primaryMaterialColor, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            height: 60, width: 60,
                            decoration: const BoxDecoration(
                                color: primaryMaterialColor,
                                shape: BoxShape.circle),
                            child: const Icon(
                                Icons.camera_alt_rounded, color: Colors.white,
                                size: 30),
                          ),
                        ),
                      ),
                    ),

                  GestureDetector(
                    onTap: _toggleRecording,
                    child: Container(
                      height: 80, width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent, width: 4),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: _isRecording ? 30 : 60,
                          width: _isRecording ? 30 : 60,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(
                                _isRecording ? 5 : 30),
                          ),
                          child: !_isRecording
                              ? const Icon(
                              Icons.videocam_rounded, color: Colors.white,
                              size: 30)
                              : null,
                        ),
                      ),
                    ),
                  ),

                  _buildSmallAction(
                    icon: _isFlashOn ? Icons.flash_on_rounded : Icons
                        .flash_off_rounded,
                    onTap: () async {
                      setState(() => _isFlashOn = !_isFlashOn);
                      await _controller.setFlashMode(
                          _isFlashOn ? FlashMode.torch : FlashMode.off);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAction(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, width: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}
