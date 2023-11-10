import 'package:checkpoint_app/kernel/controllers/tag_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/kernel/application.dart';

void main() async {
  Get.put(TagsController());
  runApp(const Application());
}
