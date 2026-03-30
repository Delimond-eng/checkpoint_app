import 'dart:ui';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';

Future<void> showStationCompleterModal(BuildContext context, {VoidCallback? onFinished}) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            // Header Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const Text(
              "CONFIGURATION GPS",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Staatliches',
                letterSpacing: 1.5,
                color: Color(0xFF16161E),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Enregistrez la position actuelle de la station.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontFamily: 'Ubuntu',
              ),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Info Card for Station
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.share_location_rounded, color: Colors.indigo, size: 28),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "STATION SCANNÉE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(() => Text(
                                  tagsController.scannedSite.value.name?.toUpperCase() ?? "STATION INCONNUE",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16161E),
                                    fontFamily: 'Ubuntu',
                                  ),
                                )),
                                Obx(() => Text(
                                  "CODE : ${tagsController.scannedSite.value.code?.toUpperCase() ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                    fontFamily: 'Ubuntu',
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    const Icon(Icons.gps_fixed_rounded, size: 60, color: Colors.indigoAccent),
                    const SizedBox(height: 20),
                    const Text(
                      "Assurez-vous d'être à l'emplacement exact de la station pour capturer les coordonnées GPS précises.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontFamily: 'Ubuntu',
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: SubmitButton(
                        label: "ENREGISTRER LA POSITION",
                        color: Colors.indigo,
                        loading: tagsController.isLoading.value,
                        onPressed: () async {
                          tagsController.isLoading.value = true;
                          final msg = await HttpManager().completeSite();
                          tagsController.isLoading.value = false;
                          
                          if (msg != null) {
                            EasyLoading.showToast(msg.toString());
                            tagsController.isScanningModalOpen.value = false;
                            Get.back();
                            onFinished?.call();
                          }
                        },
                      ),
                    )),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
