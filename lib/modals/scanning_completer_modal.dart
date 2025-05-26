import 'dart:io';

import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/services/recognition_service.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showScanningCompleter(
    context, FaceRecognitionController controller) async {
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
                  Get.back();
                  tagsController.recognitionKey.value = "patrol";
                  showPatrolRecognitionModal(context, commentController.text);
                  tagsController.recognize(controller, ImageSource.camera);
                },
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Future<void> showPatrolRecognitionModal(context, String comment) async {
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
                              if (tagsController.faceResult.value !=
                                  authController.userSession.value.matricule) {
                                EasyLoading.showInfo(
                                    "Le visage scanné ne correspond pas au compte de l'agent connecté !");
                                return;
                              }
                              var manager = HttpManager();
                              tagsController.isLoading.value = true;
                              manager.beginPatrol(comment).then((value) {
                                tagsController.isLoading.value = false;
                                tagsController.faceResult.value = "";
                                tagsController.face.value = null;
                                if (value != "success") {
                                  EasyLoading.showToast(value);
                                } else {
                                  tagsController.isScanningModalOpen.value =
                                      false;
                                  Get.back();
                                  EasyLoading.showSuccess(
                                    "Données transmises avec succès !",
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
