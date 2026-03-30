import 'package:get/get.dart';
import '../kernel/controllers/tag_controller.dart';
import '../kernel/controllers/auth_controller.dart';
import '../kernel/controllers/face_recognition_controller.dart';

// Utilisation de getters pour garantir l'accès à l'instance correcte enregistrée dans GetX
TagsController get tagsController => Get.find<TagsController>();
AuthController get authController => Get.find<AuthController>();
FaceRecognitionController get faceRecognitionController => Get.find<FaceRecognitionController>();
