import 'package:get/get.dart';

class TagsController extends GetxController {
  static TagsController instance = Get.find();

  RxList<String> tags = RxList([]);

  //ADD NEW TAG IF DOESN'T EXIST
  void addTag(String tag) {
    if (tags.isEmpty || !tags.contains(tag)) {
      tags.add(tag);
    }
  }
}
