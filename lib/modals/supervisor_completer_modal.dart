import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showSupervisorCompleter(context) async {
  tagsController.isScanningModalOpen.value = true;
  final areaLibelle = TextEditingController();
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
              "Veuillez completer la zone avec le libellé et les coordonnées GPS !",
              style: Theme.of(context).textTheme.bodyLarge,
            ).paddingBottom(8.0),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: primaryMaterialColor.shade100,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: areaLibelle,
                      decoration: const InputDecoration(
                        hintText: "Zone Libellé.",
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  )
                ],
              ).paddingHorizontal(8.0),
            ).paddingBottom(10.0),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 55.0,
              child: SubmitButton(
                label: "Completer",
                loading: tagsController.isLoading.value,
                onPressed: () async {
                  var manager = HttpManager();
                  tagsController.isLoading.value = true;
                  manager.completeArea(areaLibelle.text).then((value) {
                    tagsController.isLoading.value = false;
                    if (value != "success") {
                      EasyLoading.showToast(value);
                    } else {
                      tagsController.isScanningModalOpen.value = false;
                      Get.back();
                      EasyLoading.showSuccess(
                        "Zone de patrouille completées avec succès !",
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
