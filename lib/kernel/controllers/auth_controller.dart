import 'dart:io';
import '/global/store.dart';
import '/kernel/models/supervision.dart';
import '/kernel/models/supervision_element.dart';
import '/kernel/models/user.dart';
import '/kernel/services/http_manager.dart';
import 'package:get/get.dart';
import '../models/supervisor_data.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  Rx<User?> userSession = Rx<User?>(null);
  var supervisorElements = <SupElement>[].obs;
  var supervisorSites = <SiteModel>[].obs;
  var selectedSupervisorAgents = <AgentModel>[].obs;
  RxInt selectedAgentId = 0.obs;
  var supervisedAgent = <int>[].obs;
  var pendingSupervisionMap = <String, dynamic>{}.obs;

  Rx<Supervision?> pendingSupervision = Rx<Supervision?>(null);
  RxList<User> stationAgents = RxList<User>([]);
  RxList<Map<String, dynamic>> supervisedDatas =
      RxList<Map<String, dynamic>>([]);
  var photo = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    refreshUser();
    refreshSupervision();
  }

  Future<User?> refreshUser() async {
    var userObject = localStorage.read('user_session');

    if (userObject != null) {
      userSession.value = User.fromJson(userObject);
      var datas = await HttpManager().getSupervisionElements();
      supervisorElements.value = datas;
      return userSession.value;
    } else {
      return null;
    }
  }

  void refreshEe() async {
    var datas = await HttpManager().getSupervisionElements();
    supervisorElements.value = datas;
  }

  void refreshSupervision() async {
    var localData = localStorage.read("supervision");
    if (localData != null) {
      pendingSupervision.value = Supervision.fromJson(localData);
      var agents = await HttpManager()
          .getStationAgents(pendingSupervision.value!.siteId!);
      stationAgents.value = agents;
    } else {
      pendingSupervision.value = null;
      stationAgents.value = [];
      supervisedDatas.value = [];
      supervisedAgent.value = [];
      selectedAgentId.value = 0;
    }
  }

  void updateAgentPhoto(int agentId, File photo) {
    var index = supervisedDatas.indexWhere((e) => e['agent_id'] == agentId);
    if (index != -1) {
      supervisedDatas[index]['photo'] = photo;
      supervisedDatas.refresh();
    }
  }

  void updateAgentNote({
    required int agentId,
    required int controlElementId,
    required String noteLabel,
  }) {
    var index = supervisedDatas.indexWhere((e) => e['agent_id'] == agentId);
    if (index == -1) return;

    var notes = supervisedDatas[index]['notes'] as List;
    var existing =
        notes.indexWhere((n) => n['control_element_id'] == controlElementId);

    if (existing != -1) {
      notes[existing]['note'] = noteLabel;
    } else {
      notes.add({
        'control_element_id': controlElementId,
        'note': noteLabel,
        'comment': '',
      });
    }

    supervisedDatas.refresh();

    // Vérifie si tous les éléments de supervision ont été notés
    bool allChecked = supervisorElements
        .every((e) => notes.any((n) => n['control_element_id'] == e.id));

    if (allChecked && !supervisedAgent.contains(agentId)) {
      supervisedAgent.add(agentId);
    }
  }
}
