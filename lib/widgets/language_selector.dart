import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/global/store.dart';
import '/constants/styles.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            "select_language".tr,
            style: const TextStyle(
              fontFamily: "Staatliches",
              fontSize: 20,
              letterSpacing: 1,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildLanguageItem("french".tr, const Locale('fr', 'FR')),
          _buildLanguageItem("english".tr, const Locale('en', 'US')),
          _buildLanguageItem("portuguese".tr, const Locale('pt', 'PT')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String label, Locale locale) {
    return ListTile(
      onTap: () {
        Get.updateLocale(locale);
        localStorage.write("language", locale.languageCode);
        Get.back();
      },
      leading: const Icon(Icons.language_rounded, color: primaryColor),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: "Ubuntu",
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      trailing: Get.locale?.languageCode == locale.languageCode
          ? const Icon(Icons.check_circle_rounded, color: Colors.green)
          : null,
    );
  }
}

void showLanguageSelector(BuildContext context) {
  Get.bottomSheet(const LanguageSelector());
}
