import 'dart:convert';
import 'dart:ui';

import '/constants/styles.dart';
import '/global/controllers.dart';
import '/kernel/models/area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../modals/supervisor_completer_modal.dart';
import '../widgets/user_status.dart';
import '../widgets/scanner_overlay.dart';

class SupervisorQRCODECompleter extends StatefulWidget {
  const SupervisorQRCODECompleter({super.key});

  @override
  State<SupervisorQRCODECompleter> createState() =>
      _SupervisorQRCODECompleterState();
}

class _SupervisorQRCODECompleterState extends State<SupervisorQRCODECompleter> {
  final controller = MobileScannerController(autoStart: true);
  bool isLigthing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      try {
        if (tagsController.isScanningModalOpen.value == false) {
          Map<String, dynamic> jsonMap = jsonDecode(barcodes.barcodes.first.displayValue!);
          var area = Area.fromJson(jsonMap);
          tagsController.scannedArea.value = area;
          tagsController.isLoading.value = false;
          tagsController.isQrcodeScanned.value = true;
          tagsController.isScanningModalOpen.value = true;
          controller.stop();
          showSupervisorCompleter(context);
        }
      } catch (e) {
        EasyLoading.showToast("scan_error".tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          
          // Scanner Overlay with Animation or Refresh Icon
          Obx(() => ScannerOverlay(isScanned: tagsController.isScanningModalOpen.value)),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  color: Colors.black.withOpacity(0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          const UserStatus(name: ""),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "configuration".tr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryMaterialColor, fontFamily: 'Staatliches', letterSpacing: 2),
                      ),
                      Text(
                        "complete_zone".tr,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Staatliches'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlBtn(
                    icon: isLigthing ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
                    onTap: () {
                      setState(() => isLigthing = !isLigthing);
                      controller.toggleTorch();
                    },
                  ),
                  const SizedBox(width: 30),
                  _buildControlBtn(
                    icon: Icons.refresh_rounded,
                    onTap: () {
                      tagsController.isScanningModalOpen.value = false;
                      controller.start();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
