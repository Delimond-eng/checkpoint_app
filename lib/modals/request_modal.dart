import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showRequestModal(context) async {
  final textTitle = TextEditingController();
  final textDescription = TextEditingController();
  showCustomModal(
    context,
    onClosed: () {},
    title: "Faites votre requête",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Veuillez renseigner tous les champs requis pour effectuer une requête !",
              style: Theme.of(context).textTheme.bodyLarge,
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
                        hintText: "Objet de la requête",
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
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 55.0,
              child: SubmitButton(
                label: "Envoyer la requête",
                loading: tagsController.isLoading.value,
                onPressed: () async {
                  if (textTitle.text.isEmpty) {
                    EasyLoading.showToast("L'objet de la requête requis !");
                    return;
                  }
                  if (textDescription.text.isEmpty) {
                    EasyLoading.showToast(
                        "Une Description pour la requête requis !");
                    return;
                  }
                  var manager = HttpManager();
                  tagsController.isLoading.value = true;
                  manager
                      .createRequest(textTitle.text, textDescription.text)
                      .then((value) {
                    tagsController.isLoading.value = false;
                    if (value is String) {
                      EasyLoading.showToast(value);
                    } else {
                      Get.back();
                      EasyLoading.showSuccess(
                        "Votre requête a été soumise avec succès !",
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
