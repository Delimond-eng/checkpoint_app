import 'dart:ui';
import '/global/controllers.dart';
import '/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';

Future<void> showRequestModal(BuildContext context) async {
  final textTitle = TextEditingController();
  final textDescription = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
              "NOUVELLE REQUÊTE",
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
              "Veuillez détailler votre demande administrative.",
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
                    _buildFieldLabel("OBJET"),
                    _buildInputField(
                      controller: textTitle,
                      hint: "Sujet de votre requête...",
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 25),
                    _buildFieldLabel("DESCRIPTION DÉTAILLÉE"),
                    _buildInputField(
                      controller: textDescription,
                      hint: "Expliquez votre situation ici...",
                      icon: Icons.notes_rounded,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 40),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: SubmitButton(
                        label: "ENVOYER LA REQUÊTE",
                        loading: tagsController.isLoading.value,
                        onPressed: () async {
                          if (textTitle.text.isEmpty || textDescription.text.isEmpty) {
                            EasyLoading.showToast("Tous les champs sont requis !");
                            return;
                          }
                          tagsController.isLoading.value = true;
                          var manager = HttpManager();
                          final response = await manager.createRequest(textTitle.text, textDescription.text);
                          tagsController.isLoading.value = false;
                          
                          if (response is String) {
                            EasyLoading.showToast(response);
                          } else {
                            Get.back();
                            EasyLoading.showSuccess("Requête soumise avec succès !");
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

Widget _buildFieldLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(left: 5, bottom: 10),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
        fontFamily: 'Ubuntu',
      ),
    ),
  );
}

Widget _buildInputField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  int maxLines = 1,
}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.withOpacity(0.1)),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  );
}
