import 'dart:io';

import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/themes/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showSignalementModal(context) async {
  final textTitle = TextEditingController();
  final textDescription = TextEditingController();

  showCustomModal(
    context,
    onClosed: () {},
    title: "Signalement",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Veuillez renseigner tous les champs requis pour effectuer un signalement !",
              style: Theme.of(context).textTheme.bodySmall,
            ).paddingBottom(8.0),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: textTitle,
                      decoration: const InputDecoration(
                        hintText: "Titre du signalement",
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  )
                ],
              ).paddingHorizontal(5.0),
            ).paddingBottom(10.0),
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
                  controller: textDescription,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "Description...",
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ).paddingBottom(10.0),
            PickerButton(
              isPicked: tagsController.mediaFile.value != null,
              onCleared: () {
                tagsController.mediaFile.value = null;
              },
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15.0),
                      ),
                    ),
                    builder: (context) {
                      return Container(
                        height: 120.0,
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: PickerActionButton(
                                  label: "Capture Photo",
                                  icon: CupertinoIcons.photo_camera,
                                  onPressed: () {
                                    pickImage().then((value) => Get.back());
                                  },
                                ).paddingRight(10.0),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: PickerActionButton(
                                  label: "Capture vidéo",
                                  icon: CupertinoIcons.video_camera,
                                  onPressed: () {
                                    pickVideo().then((value) => Get.back());
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    });
              },
            ).paddingBottom(10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 55.0,
              child: SubmitButton(
                label: "Envoyer la requête",
                loading: tagsController.isLoading.value,
                onPressed: () async {
                  if (tagsController.mediaFile.value == null) {
                    EasyLoading.showSuccess(
                        "Vous devez faire une capture vidéo ou image !");
                    return;
                  }
                  if (textTitle.text.isEmpty) {
                    EasyLoading.showSuccess(
                        "Vous devez donner un titre à votre signalement !");
                    return;
                  }

                  if (textDescription.text.isEmpty) {
                    EasyLoading.showSuccess(
                        "Vous devez donner une description à votre signalement !");
                    return;
                  }
                  var manager = HttpManager();
                  tagsController.isLoading.value = true;
                  manager
                      .createSignalement(textTitle.text, textDescription.text)
                      .then((value) {
                    tagsController.isLoading.value = false;
                    if (value is String) {
                      EasyLoading.showToast(value);
                    } else {
                      Get.back();
                      tagsController.mediaFile.value = null;
                      EasyLoading.showSuccess(
                        "Votre signalement a été transmis au centre de contrôle avec succès !",
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

Future<void> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 100,
  );

  if (pickedFile != null) {
    tagsController.mediaFile.value = File(pickedFile.path);
  } else {
    tagsController.mediaFile.value = null;
  }
}

// Fonction pour capturer une vidéo (max 30s)
Future<void> pickVideo() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickVideo(
    source: ImageSource.camera,
    maxDuration: const Duration(seconds: 30),
  );
  if (pickedFile != null) {
    tagsController.mediaFile.value = File(pickedFile.path);
  } else {
    tagsController.mediaFile.value = null;
  }
}

class PickerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onCleared;
  final bool isPicked;
  const PickerButton({
    super.key,
    this.onPressed,
    this.onCleared,
    this.isPicked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DottedBorder(
          color: primaryMaterialColor.shade500,
          radius: const Radius.circular(12.0),
          strokeWidth: 1,
          borderType: BorderType.RRect,
          dashPattern: const [6, 3],
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Container(
              height: 120.0,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(2.5),
              color: whiteColor,
              child: Material(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.0),
                  onTap: onPressed,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tagsController.mediaFile.value == null) ...[
                        const Text("Faites une capture photo ou une video")
                            .paddingBottom(10),
                      ] else ...[
                        Text(
                          basename(tagsController.mediaFile.value!.path),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.green),
                        ).paddingBottom(10).paddingHorizontal(10.0),
                      ],
                      const Icon(
                        CupertinoIcons.play,
                        color: primaryMaterialColor,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isPicked)
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Material(
                borderRadius: BorderRadius.circular(40),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: onCleared,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.clear,
                      size: 18.0,
                      color: Colors.red.shade300,
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}

class PickerActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  const PickerActionButton({
    super.key,
    this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: primaryMaterialColor.shade500,
      radius: const Radius.circular(12.0),
      strokeWidth: 1,
      borderType: BorderType.RRect,
      dashPattern: const [6, 3],
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          child: Material(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: onPressed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: primaryMaterialColor,
                    size: 30.0,
                  ).paddingBottom(10),
                  Text(
                    label,
                    style: const TextStyle(
                        fontFamily: "Staatliches", color: blackColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
