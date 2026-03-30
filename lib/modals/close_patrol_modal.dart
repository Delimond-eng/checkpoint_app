import 'dart:ui';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/submit_button.dart';
import 'recognition_face_modal.dart';

Future<void> showClosePatrolModal(BuildContext context) async {
  final commentController = TextEditingController();

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
            
            // Modal Title
            const Text(
              "FIN DE PATROUILLE",
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
              "Clôture définitive de la session actuelle.",
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
                    // Warning Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade700.withOpacity(0.15),
                            Colors.orange.shade700.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.orange.shade700.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 30),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ACTION IRRÉVERSIBLE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Veuillez confirmer la fin de votre ronde. Vous ne pourrez plus ajouter de points après cette étape.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF16161E),
                                    fontFamily: 'Ubuntu',
                                    height: 1.4,
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
                      "OBSERVATIONS FINALES (OPTIONNEL)",
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
                          hintText: "Rapport de fin de patrouille ou remarques...",
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
                        label: "CLÔTURER LA SESSION",
                        color: primaryMaterialColor,
                        loading: tagsController.isLoading.value,
                        onPressed: () async {
                          showRecognitionModal(
                            context,
                            key: "close",
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
