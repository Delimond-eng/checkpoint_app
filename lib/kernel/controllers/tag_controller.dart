import 'package:checkpoint_app/global/store.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';

class TagsController extends GetxController {
  static TagsController instance = Get.find();

  RxList<Map<String, dynamic>> tags = RxList([]);
  RxInt patrolCode = RxInt(0);

  //ADD NEW TAG IF DOESN'T EXIST
  void addTag(String tag, String tagName) {
    tags.add({"tag_id": tag, "tag_name": tagName});
    EasyLoading.showSuccess("Effectué avec succès !");
  }

  Future<int> refreshCurrentPatrol() async {
    var pId = localStorage.read("code_patrouille");
    if (pId != null) {
      patrolCode = pId;
      return pId;
    } else {
      return 0;
    }
  }

  void closePatrol() {
    NfcManager.instance.stopSession();
    tags.clear();
    localStorage.remove('code_patrouille');
    refreshCurrentPatrol();
  }
}
