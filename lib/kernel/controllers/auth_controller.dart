import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/supervisor_data.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  var userSession = User().obs;
  var supervisorElements = <ElementModel>[].obs;
  var supervisorSites = <SiteModel>[].obs;
  var selectedSupervisorAgents = <AgentModel>[].obs;

  Map<int, List<ElementModel>> agentElementsMap = {};
  RxInt selectedAgentId = 0.obs;
  var supervisedAgent = <int>[].obs;
  var pendingSupervisionMap = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    refreshUser();
  }

  Future<User> refreshUser() async {
    var userObject = localStorage.read('user_session');
    if (userObject != null) {
      userSession.value = User.fromJson(userObject);
      tagsController.isLoading.value = true;
      var datas = await HttpManager().loadSupervisorData();
      tagsController.isLoading.value = false;
      supervisorSites.value = datas!.sites;
      supervisorElements.value = datas.elements;
      return userSession.value;
    } else {
      return User();
    }
  }

  Future<void> refreshPendingSupervisionMap() async {
    var data = localStorage.read("pending_supervision");
    if (data != null) {
      if (kDebugMode) {
        print(data);
      }
      pendingSupervisionMap.value = data as Map<String, dynamic>;
    } else {
      pendingSupervisionMap.value = {};
      agentElementsMap = {};
    }
  }
}
