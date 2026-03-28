import 'dart:io';
import 'dart:ui';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';

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
              "SIGNALER UN INCIDENT",
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
              "Décrivez l'incident et joignez une preuve visuelle.",
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
                    _buildFieldLabel("TITRE DE L'INCIDENT"),
                    _buildInputField(
                      controller: textTitle,
                      hint: "Ex: Intrusion, Panne technique...",
                      icon: Icons.error_outline_rounded,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel("PREUVE VISUELLE"),
                    Obx(() => _buildMediaPicker(context)),
                    const SizedBox(height: 20),
                    _buildFieldLabel("DESCRIPTION DES FAITS"),
                    _buildInputField(
                      controller: textDescription,
                      hint: "Expliquez ce qu'il s'est passé...",
                      icon: Icons.subject_rounded,
                      maxLines: 4,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 35),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: SubmitButton(
                        label: "TRANSMETTRE L'ALERTE",
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
                            EasyLoading.showSuccess("Signalement transmis avec succès !");
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
    onTap: () => _showPickerOptions(context),
    child: Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: file == null ? const Color(0xFFF8F9FA) : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: file == null ? Colors.grey.withOpacity(0.1) : Colors.green.withOpacity(0.2),
          style: file == null ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          Center(
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
                  file == null ? "AJOUTER UNE PHOTO / VIDÉO" : basename(file.path),
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
          if (file != null)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => tagsController.mediaFile.value = null,
                child: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 24),
              ),
            ),
        ],
      ),
    ),
  );
}

void _showPickerOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("CHOISIR UN MÉDIA", style: TextStyle(fontFamily: 'Staatliches', fontSize: 18, letterSpacing: 1.5)),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: _buildPickerAction(
                  icon: Icons.photo_camera_rounded,
                  label: "PHOTO",
                  onTap: () async {
                    Get.back();
                    await _pickMedia(ImageSource.camera, isVideo: false);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildPickerAction(
                  icon: Icons.videocam_rounded,
                  label: "VIDÉO",
                  onTap: () async {
                    Get.back();
                    await _pickMedia(ImageSource.camera, isVideo: true);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

Widget _buildPickerAction({required IconData icon, required String label, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.redAccent, size: 30),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Staatliches')),
        ],
      ),
    ),
  );
}

Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
  final ImagePicker picker = ImagePicker();
  if (isVideo) {
    final XFile? pickedFile = await picker.pickVideo(source: source, maxDuration: const Duration(seconds: 30));
    if (pickedFile != null) tagsController.mediaFile.value = File(pickedFile.path);
  } else {
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 60);
    if (pickedFile != null) tagsController.mediaFile.value = File(pickedFile.path);
  }
}
