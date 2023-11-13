import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/services/http_service.dart';

class HttpManager {
  //Agent login
  Future<bool> login({required String uName, required String uPass}) async {
    var response = await HttpService.postRequest(
      "all/insertion/insertConnexion",
      data: {"username": uName, "password": uPass},
    );

    if (response != null) {
      if (response['reponse']['status'] == 'successs') {
        //save user session data
        localStorage.write("user_session", response['reponse']['dataexist'][0]);
        authController.refreshUser();
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  //Patrol begin tasks
  Future<int> startPatrol() async {
    var response =
        await HttpService.postRequest('all/insertion/insertDebut', data: {});
    print(response);
    if (response != null) {
      if (response['reponse']['status'] == 'success') {
        localStorage.write(
            "code_patrouille", response['reponse']['code_patrouille']);
        return int.parse(response['reponse']['code_patrouille'].toString());
      } else {
        return 0;
      }
    }
    return 0;
  }

  Future savePatrol({
    int? code,
    String? tag,
  }) async {
    var user = await authController.refreshUser();
    var patrolCode = await tagsController.refreshCurrentPatrol();
    var response =
        await HttpService.postRequest("all/insertion/insertPatrouilles", data: {
      "code_patrouille": patrolCode,
      "agent_id": user.agentId,
      "pointag_id": tag,
      "site_id": user.siteId,
    });

    if (response != null) {
      if (response['reponse']['status'] == 'successs') {
        return response['reponse']['dataexist'][0];
      } else {
        return null;
      }
    }
    return null;
  }

  //Close patrol
  Future closePatrol() async {
    var result = await HttpService.postRequest('', data: {});
    return result;
  }
}
