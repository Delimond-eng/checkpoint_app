import 'dart:convert';
import 'dart:io';

import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:checkpoint_app/modals/close_patrol_modal.dart';
import 'package:checkpoint_app/modals/scanning_completer_modal.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../themes/colors.dart';

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
            showScanningCompleter(context);
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
        title: Text("Patrouille QRcode Scan".toUpperCase()),
        actions: [
          Obx(
            () => CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                authController.userSession.value.fullname!.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ).marginAll(8.0),
          )
        ],
      ),
      body: SafeArea(
          child: Stack(
        children: [
          QRView(
            key: qrKey,
            overlay: QrScannerOverlayShape(
              borderColor: secondaryColor,
              overlayColor: Colors.white.withOpacity(.5),
              borderRadius: 10.0,
              borderLength: 50.0,
              borderWidth: 4.0,
              cutOutSize: 250,
            ),
            onQRViewCreated: onQRViewCreated,
          )
          //Container()
        ],
      )),
      floatingActionButton: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Aligne les boutons aux extrémités
          children: [
            // Bouton flottant avec un libellé
            if (tagsController.patrolId.value != 0) ...[
              FloatingActionButton.extended(
                heroTag: "btnClose",
                backgroundColor: const Color.fromARGB(255, 207, 136, 4),
                onPressed: () {
                  showClosePatrolModal(context);
                },
                label: const Text(
                  'Cloturer la patrouille en cours',
                ), // Texte pour le bouton
                icon: const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                ), // Icône optionnelle
              ),
            ] else ...[
              const SizedBox.shrink()
            ],
            FloatingActionButton(
              heroTag: "btnLight",
              elevation: 10.0,
              backgroundColor: Colors.blue,
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
          ],
        ).paddingHorizontal(8.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
