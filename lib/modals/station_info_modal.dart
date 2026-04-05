import 'dart:ui';
import '/constants/styles.dart';
import '/global/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';

Future<void> showStationInfoModal(BuildContext context, {VoidCallback? onFinished}) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Obx(() {
          final site = tagsController.scannedSite.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryMaterialColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_rounded,
                  size: 50,
                  color: primaryMaterialColor,
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                "station".tr.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 2,
                  fontFamily: 'Ubuntu',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                site.name?.toUpperCase() ?? "station".tr.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF16161E),
                  fontFamily: 'Staatliches',
                ),
              ),
              Text(
                "Code : ${site.code?.toUpperCase() ?? 'N/A'}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 35),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: tagsController.isLoading.value ? null : () async {
                    tagsController.isLoading.value = true;
                    try {
                      final agents = await HttpManager().getStationAgents(site.id);
                      tagsController.isLoading.value = false;
                      authController.stationAgents.value = agents;
                      Get.back();
                      onFinished?.call();
                    } catch (e) {
                      tagsController.isLoading.value = false;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryMaterialColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: tagsController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "continue_btn".tr.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                fontFamily: 'Ubuntu',
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        }),
      ),
    ),
  );
}
