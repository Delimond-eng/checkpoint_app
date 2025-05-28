import 'dart:io';

import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class TagsController extends GetxController {
  static TagsController instance = Get.find();

  var scannedArea = Area().obs;
  var isQrcodeScanned = false.obs;
  var patrolId = 0.obs;
  var isLoading = false.obs;
  var isScanningModalOpen = false.obs;
  var mediaFile = Rx<File?>(null);
  var face = Rx<XFile?>(null);
  var faceResult = "".obs;
  var isFlashOn = false.obs;
  var cameraIndex = 1.obs;

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
