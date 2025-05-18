import 'dart:io';

import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../kernel/services/http_manager.dart';
import 'utils.dart';

Future<void> showRecognitionModal(context) async {
  showCustomModal(
    context,
    onClosed: () {
      tagsController.face.value = null;
      tagsController.faceResult.value = "";
    },
    title: "Reconnaissance faciale",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (tagsController.isRecognitionLoading.value) ...[
                  SizedBox(
                    height: 210.0,
                    width: 210.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 4.0,
                      color: primaryMaterialColor.shade300,
                    ),
                  ),
                ],
                DottedBorder(
                  color: (tagsController.faceResult.value.isNotEmpty &&
                          tagsController.faceResult.value != "Inconnu")
                      ? Colors.green.shade400
                      : primaryMaterialColor.shade500,
                  radius: const Radius.circular(110.0),
                  strokeWidth: 1.2,
                  borderType: BorderType.RRect,
                  dashPattern: const [6, 3],
                  child: CircleAvatar(
                    radius: 100.0,
                    backgroundColor: darkColor,
                    child: tagsController.face.value != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100.0),
                            ),
                            child: Image.file(
                              width: 200.0,
                              height: 200.0,
                              File(tagsController.face.value!.path),
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Image.asset(
                              "assets/images/profil-2.png",
                              height: 50.0,
                            ),
                          ),
                  ).marginAll(4.0),
                ),
              ],
            ).paddingBottom(15.0),
            Container(
              padding: const EdgeInsets.all(5.0),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (tagsController.faceResult.value.isNotEmpty &&
                            tagsController.faceResult.value != "Inconnu")
                          const Text(
                            "Reconnaissance faciale résultat ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 10.0,
                            ),
                          ),
                        const SizedBox(height: 4.0),
                        Text(
                          tagsController.faceResult.value.isNotEmpty &&
                                  tagsController.faceResult.value != "Inconnu"
                              ? "Matricule Agent : ${tagsController.faceResult.value}"
                              : tagsController.faceResult.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Staatliches',
                            color:
                                tagsController.faceResult.value != "Inconnu" ||
                                        !tagsController.faceResult.value
                                            .contains("Impossible")
                                    ? Colors.green
                                    : primaryMaterialColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                        if ((tagsController.faceResult.value.isNotEmpty &&
                            tagsController.faceResult.value != "Inconnu")) ...[
                          CostumButton(
                            borderColor: Colors.green.shade200,
                            title: "Valider",
                            isLoading: tagsController.isLoading.value,
                            bgColor: Colors.green,
                            labelColor: Colors.white,
                            onPress: () async {
                              var manager = HttpManager();
                              tagsController.isLoading.value = true;
                              manager.checkPresence().then((value) {
                                tagsController.isLoading.value = false;
                                if (value != "success") {
                                  EasyLoading.showToast(value);
                                } else {
                                  tagsController.faceResult.value = "";
                                  tagsController.face.value = null;
                                  tagsController.isScanningModalOpen.value =
                                      false;
                                  Get.back();
                                  EasyLoading.showSuccess(
                                    "Présence signalée avec succès !",
                                  );
                                }
                              });
                            },
                          ).paddingTop(10.0)
                        ]
                      ],
                    ),
                  )
                ],
              ),
            ),
            /* SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: CostumButton(
                title: "Valider",
                bgColor: primaryMaterialColor,
                labelColor: Colors.white,
                onPress: () {},
              ),
            ) */
          ],
        ),
      ),
    ),
  );
}
