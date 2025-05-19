import 'dart:convert';
import 'dart:io';

import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../modals/supervisor_completer_modal.dart';
import '../widgets/user_status.dart';

class SupervisorHome extends StatefulWidget {
  const SupervisorHome({super.key});

  @override
  State<SupervisorHome> createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  late QRViewController controller;
  bool isLigthing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _restartCameraAndListen() {
    tagsController.isQrcodeScanned.value = false;
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        try {
          if (!tagsController.isScanningModalOpen.value) {
            Map<String, dynamic> jsonMap = jsonDecode(scanData.code!);
            var area = Area.fromJson(jsonMap);
            tagsController.scannedArea.value = area;
            tagsController.isQrcodeScanned.value = true;
            controller.pauseCamera();
            showSupervisorCompleter(context);
          }
        } catch (e) {
          EasyLoading.showToast(
              "Echec du scan de qrcode. Veuillez reéssayer !");
        }
      }
    });
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        // Pause the camera after a successful scan
        try {
          if (!tagsController.isScanningModalOpen.value) {
            // Convertir la chaîne JSON en Map
            Map<String, dynamic> jsonMap = jsonDecode(scanData.code!);
            // Formatter le JSON en objet Dart
            var area = Area.fromJson(jsonMap);
            tagsController.scannedArea.value = area;
            tagsController.isQrcodeScanned.value = true;
            showSupervisorCompleter(context);
          }
        } catch (e) {
          EasyLoading.showToast(
              "Echec du scan de qrcode. Veuillez reéssayer !");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          () => Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                !tagsController.isQrcodeScanned.value
                    ? QRView(
                        key: qrKey,
                        overlay: QrScannerOverlayShape(
                          borderColor: primaryMaterialColor,
                          overlayColor: Colors.white.withOpacity(.5),
                          borderRadius: 12.0,
                          borderLength: 50.0,
                          borderWidth: 8.0,
                          cutOutSize: 250,
                        ),
                        onQRViewCreated: onQRViewCreated,
                      )
                    : DottedBorder(
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
                                    Radius.circular(12.0)),
                                onTap: _restartCameraAndListen,
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
                      )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        backgroundColor: primaryMaterialColor,
        onPressed: () async {
          setState(() {
            isLigthing = !isLigthing;
          });
          await controller.toggleFlash();
        },
        child: Icon(
          (isLigthing) ? Icons.flash_off_rounded : Icons.flash_on_rounded,
          color: Colors.white,
          size: 18.0,
        ),
      ),
    );
  }
}
