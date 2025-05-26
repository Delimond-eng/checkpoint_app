import 'dart:convert';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:checkpoint_app/kernel/services/recognition_service.dart';
import 'package:checkpoint_app/modals/close_patrol_modal.dart';
import 'package:checkpoint_app/modals/scanning_completer_modal.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../constants/styles.dart';
import '../widgets/user_status.dart';

class QRcodeScannerPage extends StatefulWidget {
  const QRcodeScannerPage({super.key});

  @override
  State<QRcodeScannerPage> createState() => _QRcodeScannerPageState();
}

class _QRcodeScannerPageState extends State<QRcodeScannerPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late Barcode result;
  late QRViewController controller;
  bool isLigthing = false;

  late FaceRecognitionController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller =
        Provider.of<FaceRecognitionController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.isModelInitializing && !_controller.isModelLoaded) {
        _controller.initializeModel();
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    controller.pauseCamera();
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
            controller.dispose();
            showScanningCompleter(context, _controller);
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
            controller.pauseCamera();
            controller.dispose();
            showScanningCompleter(context, _controller);
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
      floatingActionButton: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Aligne les boutons aux extrémités
          children: [
            // Bouton flottant avec un libellé
            if (tagsController.patrolId.value != 0) ...[
              FloatingActionButton.extended(
                heroTag: "btnClose",
                backgroundColor: primaryMaterialColor,
                onPressed: () {
                  showClosePatrolModal(context);
                },
                label: const Text(
                  'Cloturer la patrouille en cours',
                  style: TextStyle(
                    fontFamily: "Staatliches",
                    color: whiteColor,
                    letterSpacing: 1,
                  ),
                ), // Texte pour le bouton
                icon: const Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.white,
                ), // Icône optionnelle
              ),
            ],
            if (!tagsController.isQrcodeScanned.value)
              FloatingActionButton(
                heroTag: "btnLight",
                elevation: 10.0,
                backgroundColor: primaryMaterialColor.shade100,
                onPressed: () async {
                  setState(() {
                    isLigthing = !isLigthing;
                  });
                  await controller.toggleFlash();
                },
                child: Icon(
                  (isLigthing)
                      ? Icons.flash_off_rounded
                      : Icons.flash_on_rounded,
                  color: primaryMaterialColor,
                  size: 18.0,
                ),
              ),
          ],
        ).paddingHorizontal(8.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
