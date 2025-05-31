import 'dart:convert';

import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../modals/supervisor_completer_modal.dart';
import '../widgets/user_status.dart';

class SupervisorHome extends StatefulWidget {
  const SupervisorHome({super.key});

  @override
  State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
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
          tagsController.isLoading.value = false;
          tagsController.isQrcodeScanned.value = true;
          controller.stop();
          tagsController.isScanningModalOpen.value = true;
          showSupervisorCompleter(context);
        }
      } catch (e) {
        EasyLoading.showToast("Echec du scan de qrcode. Veuillez reéssayer !");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    tagsController.isScanningModalOpen.value = false;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "COMPLETER ZONE",
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
        child: Obx(
          () => Stack(
            alignment: Alignment.center,
            children: [
              !tagsController.isScanningModalOpen.value
                  ? MobileScanner(
                      controller: controller,
                      onDetect: _handleBarcode,
                    )
                  : Center(
                      child: DottedBorder(
                        color: primaryMaterialColor.shade100,
                        radius: const Radius.circular(12.0),
                        strokeWidth: 1,
                        borderType: BorderType.RRect,
                        dashPattern: const [6, 3],
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0)),
                          child: Container(
                            height: 150.0,
                            width: 150.0,
                            color: Colors.white,
                            child: Material(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12.0)),
                              color: Colors.white,
                              child: InkWell(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                onTap: () {
                                  //restart scan here
                                  tagsController.isScanningModalOpen.value =
                                      false;
                                  controller
                                      .stop(); // Arrête d'abord proprement
                                  Future.delayed(
                                      const Duration(milliseconds: 300), () {
                                    controller
                                        .start(); // Puis redémarre le scanner
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.refresh_rounded,
                                      color: primaryMaterialColor,
                                    ).paddingBottom(10.0),
                                    const Text(
                                      "Relancer la caméra",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
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
