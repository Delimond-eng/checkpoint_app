import 'dart:io';

import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:get/get.dart';

class TagsController extends GetxController {
  static TagsController instance = Get.find();

  var scannedArea = Area().obs;
  var patrolId = 0.obs;
  var isLoading = false.obs;
  var isScanningModalOpen = false.obs;
  var mediaFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    refreshPending();
  }

  void refreshPending() {
    var patrolIdLocal = localStorage.read("patrol_id");
    patrolId.value = patrolIdLocal ?? 0;
  }
}
