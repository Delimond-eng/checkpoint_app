import '/kernel/controllers/tag_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/kernel/application.dart';
import 'kernel/controllers/auth_controller.dart';

void main() async {
  await GetStorage.init();
  Get.put(TagsController());
  Get.put(AuthController());
  runApp(const Application());
}
