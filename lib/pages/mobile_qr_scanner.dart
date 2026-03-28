import 'dart:convert';
import 'dart:ui';

import '/global/controllers.dart';
import '/kernel/models/area.dart';
import '/modals/close_patrol_modal.dart';
import '/modals/scanning_completer_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../constants/styles.dart';
import '../widgets/user_status.dart';
import '../widgets/scanner_overlay.dart';

class MobileQrScannerPage extends StatefulWidget {
  const MobileQrScannerPage({super.key});

  @override
  State<MobileQrScannerPage> createState() => _MobileQrScannerPageState();
}

class _MobileQrScannerPageState extends State<MobileQrScannerPage> {
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
        if (!tagsController.isScanningModalOpen.value) {
          Map<String, dynamic> jsonMap = jsonDecode(barcodes.barcodes.first.displayValue!);
          var area = Area.fromJson(jsonMap);
          tagsController.scannedArea.value = area;
          tagsController.isLoading.value = false;
          tagsController.isQrcodeScanned.value = true;
          tagsController.isScanningModalOpen.value = true;
          controller.stop();
          showScanningCompleter(context);
        }
      } catch (e) {
        EasyLoading.showToast("Echec du scan de qrcode. Veuillez reéssayer !");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Scanner
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
          
          // Scanner Overlay with Animation or Refresh Icon
          Obx(() => ScannerOverlay(isScanned: tagsController.isScanningModalOpen.value)),

          // Glass Header Section
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
                      const Text(
                        "PATROUILLE",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryMaterialColor, fontFamily: 'Staatliches', letterSpacing: 2),
                      ),
                      const Text(
                        "SCANNEZ LE POINT",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Staatliches'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls & Close Action
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Obx(() => tagsController.patrolId.value != 0 
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => showClosePatrolModal(context),
                          icon: const Icon(Icons.stop_circle_rounded),
                          label: const Text("CLÔTURER LA PATROUILLE", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Ubuntu')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
                Row(
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
              ],
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
