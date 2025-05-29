import 'dart:convert';

import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:checkpoint_app/modals/close_patrol_modal.dart';
import 'package:checkpoint_app/modals/scanning_completer_modal.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../constants/styles.dart';
import '../widgets/user_status.dart';

class MobileQrScannerPage extends StatefulWidget {
  const MobileQrScannerPage({super.key});

  @override
  State<MobileQrScannerPage> createState() => _MobileQrScannerPageState();
}

class _MobileQrScannerPageState extends State<MobileQrScannerPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

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
          // Convertir la chaîne JSON en Map
          Map<String, dynamic> jsonMap =
              jsonDecode(barcodes.barcodes.first.displayValue!);
          // Formatter le JSON en objet Dart
          var area = Area.fromJson(jsonMap);
          tagsController.scannedArea.value = area;
          tagsController.isQrcodeScanned.value = true;
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
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "PATROUILLE",
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
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _handleBarcode,
            ),
            // Overlay avec fenêtre transparente

            Obx(
              () => tagsController.patrolId.value != 0
                  ? Positioned(
                      bottom: 15.0,
                      left: 15.0,
                      child: CostumButton(
                        bgColor: primaryMaterialColor,
                        borderColor: primaryMaterialColor.shade400,
                        title: "Cloturer la patrouille en cours",
                        labelColor: whiteColor,
                        onPress: () {
                          showClosePatrolModal(context);
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          isLigthing
              ? Icons.flashlight_off_rounded
              : Icons.flashlight_on_rounded,
        ),
        onPressed: () {
          setState(() => isLigthing = !isLigthing);
          controller.toggleTorch();
        },
      ),
    );
  }
}
