import 'package:checkpoint_app/kernel/services/http_service.dart';

class HttpManager {
  //Patrol begin tasks
  Future startPatrol() async {
    var result = await HttpService.postRequest('', data: {});
    return result;
  }

  //Close patrol
  Future closePatrol() async {
    var result = await HttpService.postRequest('', data: {});
    return result;
  }
}
