import 'dart:ui';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/modals/recognition_face_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/submit_button.dart';

Future<void> showScanningCompleter(BuildContext context, {String key = "patrol"}) async {
  final commentController = TextEditingController();
  tagsController.isScanningModalOpen.value = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Column(
          children: [
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
              "VALIDATION DU POINT",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Staatliches',
                letterSpacing: 1.5,
                color: Color(0xFF16161E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Confirmez votre passage sur ce point de contrôle.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontFamily: 'Ubuntu',
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scanned Item Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.1),
                            Colors.blueAccent.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, color: Colors.blueAccent, size: 30),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  key == "supervize-in" ? "STATION SCANNÉE" : "ZONE IDENTIFIÉE",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  key == "supervize-in" 
                                    ? "${tagsController.scannedSite.value.name?.toUpperCase()}"
                                    : tagsController.scannedArea.value.libelle?.toUpperCase() ?? "ZONE INCONNUE",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16161E),
                                    fontFamily: 'Ubuntu',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      "OBSERVATION (OPTIONNEL)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      child: TextField(
                        controller: commentController,
                        maxLines: 4,
                        style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Saisissez un problème ou une remarque si nécessaire...",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: SubmitButton(
                        label: "CONTINUER VERS POINTAGE",
                        loading: tagsController.isLoading.value,
                        onPressed: () async {
                          showRecognitionModal(
                            context,
                            key: key,
                            comment: commentController.text,
                          );
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
