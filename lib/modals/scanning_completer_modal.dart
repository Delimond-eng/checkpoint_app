import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showScanningCompleter(context) async {
  final commentController = TextEditingController();
  tagsController.isScanningModalOpen.value = true;
  showCustomModal(
    context,
    onClosed: () {
      tagsController.isScanningModalOpen.value = false;
    },
    title: "Patrouille zone QRCODE",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color(0xFF0cb0ff),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/scanner.png",
                      height: 60.0,
                    ).paddingRight(10.0),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Zone scannée libellé",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: whiteColor),
                          ).paddingBottom(5),
                          Text(
                            tagsController.scannedArea.value.libelle!
                                .toUpperCase(),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: whiteColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ).paddingBottom(8.0),
            Text(
              "Signalez un problème si possible(optionnel)",
              style: Theme.of(context).textTheme.bodyLarge,
            ).paddingBottom(5.0),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: commentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Veuillez saisir le problème survenu...",
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ).paddingBottom(10.0),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 55.0,
              child: SubmitButton(
                label: "Soumettre",
                loading: tagsController.isLoading.value,
                onPressed: () async {
                  var manager = HttpManager();
                  tagsController.isLoading.value = true;
                  manager.beginPatrol(commentController.text).then((value) {
                    tagsController.isLoading.value = false;
                    if (value != "success") {
                      EasyLoading.showToast(value);
                    } else {
                      tagsController.isScanningModalOpen.value = false;
                      Get.back();
                      EasyLoading.showSuccess(
                        "Données transmises avec succès !",
                      );
                    }
                  });
                },
              ),
            )
          ],
        ),
      ),
    ),
  );
}
