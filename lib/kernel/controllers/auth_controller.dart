import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  var userSession = User().obs;

  Future<User> refreshUser() async {
    var userObject = localStorage.read('user_session');
    if (userObject != null) {
      userSession.value = User.fromJson(userObject);
      return userSession.value;
    } else {
      return User();
    }
  }
}
