import 'dart:convert';
import 'dart:io';

import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../modals/supervisor_completer_modal.dart';
import '../themes/colors.dart';

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
        title: Text("SUPERVISEUR QRCODE SCAN".toUpperCase()),
        actions: [
          Obx(
            () => CircleAvatar(
              radius: 30,
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
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
