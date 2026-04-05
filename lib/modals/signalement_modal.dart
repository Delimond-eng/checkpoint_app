import 'dart:io';
import 'dart:ui';
import '/global/controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';
import 'media_capture_modal.dart'; 

Future<void> showSignalementModal(BuildContext context) async {
  final textTitle = TextEditingController();
  final textDescription = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              "incident_sign".tr.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Staatliches',
                letterSpacing: 1.5,
                color: Color(0xFF16161E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Décrivez l'incident et joignez une preuve visuelle.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontFamily: 'Ubuntu',
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("incident_title".tr),
                        _buildInputField(
                          controller: textTitle,
                          hint: "Ex: Intrusion, Panne technique...",
                          icon: Icons.error_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 20),
                        _buildFieldLabel("visual_proof".tr),
                        Obx(() => _buildMediaPicker(context)),
                        const SizedBox(height: 5.0),
                        Obx(() {
                          final file = tagsController.mediaFile.value;
                          if (file == null) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: _buildFilePreview(file),
                                  ),
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                      child: Container(color: Colors.black.withOpacity(0.1)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.file_present_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            basename(file.path),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Ubuntu',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => tagsController.mediaFile.value = null,
                                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        _buildFieldLabel("facts_desc".tr),
                        _buildInputField(
                          controller: textDescription,
                          hint: "Expliquez ce qu'il s'est passé...",
                          icon: Icons.subject_rounded,
                          maxLines: 4,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 50),
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: SubmitButton(
                            label: "send_alert".tr,
                            loading: tagsController.isLoading.value,
                            onPressed: () async {
                              if (tagsController.mediaFile.value == null) {
                                EasyLoading.showToast("Une capture photo ou vidéo est requise !");
                                return;
                              }
                              if (textTitle.text.isEmpty || textDescription.text.isEmpty) {
                                EasyLoading.showToast("Veuillez remplir tous les champs !");
                                return;
                              }

                              tagsController.isLoading.value = true;
                              var manager = HttpManager();
                              final response = await manager.createSignalement(textTitle.text, textDescription.text);
                              tagsController.isLoading.value = false;

                              if (response is String) {
                                EasyLoading.showToast(response);
                              } else {
                                Get.back();
                                tagsController.mediaFile.value = null;
                                EasyLoading.showSuccess("success".tr);
                              }
                            },
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFilePreview(File file) {
  final path = file.path.toLowerCase();
  if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png')) {
    return Image.file(file, fit: BoxFit.cover);
  } else {
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(Icons.videocam_rounded, color: Colors.white30, size: 30),
    );
  }
}

Widget _buildFieldLabel(String label) {
  return Padding(
    padding: const EdgeInsets.only(left: 5, bottom: 8),
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
  required Color color,
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
        prefixIcon: Icon(icon, size: 20, color: color),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  );
}

Widget _buildMediaPicker(BuildContext context) {
  final file = tagsController.mediaFile.value;
  return GestureDetector(
    onTap: () => showMediaCaptureModal(context, onMediaCaptured: (capturedFile) {
      tagsController.mediaFile.value = capturedFile;
    }),
    child: Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: file == null ? const Color(0xFFF8F9FA) : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: file == null ? Colors.grey.withOpacity(0.1) : Colors.green.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file == null ? Icons.camera_alt_rounded : Icons.check_circle_rounded,
              color: file == null ? Colors.grey : Colors.green,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              file == null ? "open_camera".tr : "media_captured".tr,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: file == null ? Colors.grey : Colors.green,
                fontFamily: 'Ubuntu',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
