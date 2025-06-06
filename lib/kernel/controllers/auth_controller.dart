import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  var userSession = User().obs;

  @override
  void onInit() {
    super.onInit();
    refreshUser();
  }

  Future<User> refreshUser() async {
    var userObject = localStorage.read('user_session');
    if (userObject != null) {
      if (kDebugMode) {
        print(userObject);
      }
      userSession.value = User.fromJson(userObject);
      return userSession.value;
    } else {
      return User();
    }
  }
}
