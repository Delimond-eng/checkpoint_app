import 'dart:async';
import 'dart:io';

import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/area.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
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
  var planningId = "".obs;

  // Pour stopper proprement le stream
  StreamSubscription<List<Map<String, dynamic>>>? _patrolStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    _startPatrolStream();
  }

  @override
  void onClose() {
    _patrolStreamSubscription?.cancel();
    super.onClose();
  }

  void _startPatrolStream() {
    const Duration interval = Duration(seconds: 5);

    _patrolStreamSubscription = Stream.periodic(interval).asyncMap((_) async {
      try {
        return await HttpManager().checkPending();
      } catch (e) {
        return <Map<String, dynamic>>[];
      }
    }).listen((pendingPatrols) {
      if (pendingPatrols.isEmpty) {
        localStorage.remove("patrol_id");
        patrolId.value = 0;
      } else {
        final first = pendingPatrols.first;
        final newId = first["id"] ?? 0;
        if (patrolId.value != newId) {
          patrolId.value = newId;
          localStorage.write("patrol_id", newId);
        }
      }
    });
  }

  void refreshPending() {
    var patrolIdLocal = localStorage.read("patrol_id");
    patrolId.value = patrolIdLocal ?? 0;
  }
}
