import 'dart:ui';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';

Future<void> showSupervisorCompleter(BuildContext context) async {
  tagsController.isScanningModalOpen.value = true;
  final areaLibelle = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
              "CONFIGURATION ZONE",
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
              "Associez un libellé à ce point de contrôle.",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.orangeAccent.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_location_alt_rounded, color: Colors.orangeAccent, size: 28),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "POINT DÉTECTÉ",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orangeAccent,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "NOUVELLE ZONE",
                                  style: TextStyle(
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
                    const SizedBox(height: 30),

                    const Text(
                      "NOM DE LA ZONE",
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
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: areaLibelle,
                        style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Ex: Entrée Principale, Parking Sud...",
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: const Icon(Icons.edit_location_alt_rounded, size: 20, color: Colors.orangeAccent),
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
                        label: "ENREGISTRER LA ZONE",
                        loading: tagsController.isLoading.value,
                        onPressed: () async {
                          if (areaLibelle.text.isEmpty) {
                            EasyLoading.showToast("Le libellé est requis !");
                            return;
                          }
                          var manager = HttpManager();
                          tagsController.isLoading.value = true;
                          final value = await manager.completeArea(areaLibelle.text);
                          tagsController.isLoading.value = false;
                          tagsController.isScanningModalOpen.value = false;
                          
                          if (value != "Zone completée avec succès.") {
                            EasyLoading.showToast(value.toString());
                          } else {
                            Get.back();
                            EasyLoading.showSuccess("Zone configurée avec succès !");
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
