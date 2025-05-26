import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showClosePatrolModal(context) async {
  final commentController = TextEditingController();
  showCustomModal(
    context,
    onClosed: () {},
    title: "Clôture de la patrouille.",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 207, 136, 4),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Veuillez clôture la session de patrouille en cours !. Attention cette action est irréversible !.",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: whiteColor),
                        ).paddingBottom(5),
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
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 55.0,
              child: SubmitButton(
                label: "Clôturer",
                loading: tagsController.isLoading.value,
                onPressed: () async {
                  var manager = HttpManager();
                  tagsController.isLoading.value = true;
                  manager
                      .stopPendingPatrol(commentController.text)
                      .then((value) {
                    tagsController.isLoading.value = false;

                    if (value is String) {
                      EasyLoading.showToast(value);
                    } else {
                      EasyLoading.showSuccess(
                        "Données transmises avec succès !",
                      );
                      Get.back();
                    }
                  });
                },
              ),
            ),
          )
        ],
      ),
    ),
  );
}
