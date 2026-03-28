import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../kernel/services/http_manager.dart';
import 'utils.dart';

Future<void> showStationCompleterModal(context,
    {VoidCallback? onFinished}) async {
  showCustomModal(
    context,
    onClosed: () {
      //tagsController.isScanningModalOpen.value = false;
    },
    title: "COMPLETER STATION",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const Svg(
                  path: "pin.svg",
                  size: 120.0,
                  color: darkColor,
                ),
                Positioned(
                  bottom: 50.0,
                  child: Image.asset(
                    "assets/images/tango.png",
                    height: 40.0,
                  ),
                ),
              ],
            ).paddingBottom(10.0),
            Text(
              tagsController.scannedSite.value.name!.toUpperCase(),
              style: TextStyle(
                fontFamily: "Staatliches",
                fontSize: 22.0,
                color: primaryMaterialColor.shade900,
                fontWeight: FontWeight.w900,
              ),
            ).paddingBottom(5.0),
            Text(
              tagsController.scannedSite.value.code!.toUpperCase(),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ).paddingBottom(10.0),
            Container(
              height: 60.0,
              width: 60.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60.0),
                gradient: const LinearGradient(
                  colors: [
                    Colors.indigo,
                    Colors.indigoAccent,
                  ], // orange dégradé
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(60.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(60.0),
                  onTap: () {
                    tagsController.isLoading.value = true;
                    HttpManager().completeSite().then((msg) {
                      tagsController.isLoading.value = false;
                      EasyLoading.showToast(msg);
                      Get.back();
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tagsController.isLoading.value) ...[
                        const SizedBox(
                          height: 30.0,
                          width: 30.0,
                          child: CircularProgressIndicator(
                              color: whiteColor, strokeWidth: 2.0),
                        )
                      ] else ...[
                        const Icon(
                          CupertinoIcons.plus,
                          size: 20.0,
                          color: whiteColor,
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
