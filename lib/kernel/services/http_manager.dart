import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/announce.dart';
import 'package:checkpoint_app/kernel/models/planning.dart';
import 'package:checkpoint_app/kernel/models/supervisor_data.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:checkpoint_app/kernel/services/api.dart';
import 'package:checkpoint_app/kernel/services/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

SupervisorDataResponse parseSupervisorData(dynamic json) {
  return SupervisorDataResponse.fromJson(json as Map<String, dynamic>);
}

class HttpManager {
  //Agent login
  Future<dynamic> login(
      {required String uMatricule, required String uPass}) async {
    try {
      var response = await Api.request(
        url: "agent.login",
        method: "post",
        body: {"matricule": uMatricule, "password": uPass},
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        } else {
          var agent = User.fromJson(response["agent"]);
          localStorage.write("user_session", agent.toJson());
          authController.userSession.value = agent;
          authController.refreshUser();
          try {
            var token = await FirebaseService.getToken();
            await updateSiteTOKEN(token, agent.siteId);
          } catch (e) {
            if (kDebugMode) {
              print('Firebase error $e');
            }
          }
          return agent;
        }
      } else {
        return response["errors"].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Echec de traitement de la requête !";
    }
  }

  //Start scanning for patrol
  Future<dynamic> beginPatrol(String comment) async {
    var latlng = await _getCurrentLocation();
    var patrolId = tagsController.patrolId.value;
    var planningId = tagsController.planningId.value;

    try {
      // Construction du body
      var data = {
        "patrol_id": patrolId != 0 ? patrolId : "",
        "site_id": authController.userSession.value.siteId,
        "agency_id": authController.userSession.value.agencyId,
        "agent_id": authController.userSession.value.id,
        "scan_agent_id": authController.userSession.value.id,
        "area_id": tagsController.scannedArea.value.id,
        "schedule_id": planningId,
        "matricule": tagsController.faceResult.value,
        "comment": comment,
        "latlng": latlng,
      };

      var response = await Api.request(
        url: "patrol.scan",
        method: "post",
        body: data,
        files: {
          "photo": File(tagsController.face.value!.path),
        },
      );

      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          if (localStorage.read("patrol_id") == null) {
            localStorage.write("patrol_id", response["result"]["id"]);
          }
          tagsController.refreshPending();
          return "Patrouille enregistrée avec succès. Veuillez passer à la zone suivante ou clôturer la patrouille.";
        }
      } else {
        return "Erreur réseau ou serveur injoignable.";
      }
    } catch (e) {
      return "Echec de traitement de la requête : $e";
    }
  }

  //Confirm 011 Ronde
  Future<dynamic> confirm011Ronde(String comment) async {
    var latlng = await _getCurrentLocation();

    try {
      // Construction du body
      var data = {
        "site_id": tagsController.scannedSite.value.id,
        "matricule": tagsController.faceResult.value,
        "comment": comment,
        "latlng": latlng,
      };

      var response = await Api.request(
        url: "ronde.scan",
        method: "post",
        body: data,
        files: {
          "photo": File(tagsController.face.value!.path),
        },
      );

      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"];
        } else {
          return "success";
        }
      } else {
        return "errors";
      }
    } catch (e) {
      return "errors";
    }
  }

  //Complete Area
  Future<dynamic> completeArea(String libelle) async {
    var latlng = await _getCurrentLocation();
    try {
      var data = {
        "area_id": tagsController.scannedArea.value.id,
        "libelle": libelle,
        "latlng": latlng
      };
      var response = await Api.request(
        url: "area.complete",
        method: "post",
        body: data,
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          if (localStorage.read("patrol_id") == null) {
            localStorage.write("patrol_id", response["result"]["id"]);
          }
          tagsController.refreshPending();
          return "Zone completée avec succès.";
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  //Enroll agent image from database online
  Future<dynamic> enrollAgent(String matricule) async {
    try {
      var data = {
        "matricule": matricule,
      };
      var response = await Api.request(
        url: "agent.enroll",
        method: "post",
        files: {
          "photo": File(tagsController.face.value!.path),
        },
        body: data,
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          if (localStorage.read("patrol_id") == null) {
            localStorage.write("patrol_id", response["result"]["id"]);
          }
          tagsController.refreshPending();
          return "success";
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  //Presence signal
  Future<dynamic> checkPresence({String? key}) async {
    var latlng = await _getCurrentLocation();
    try {
      Map<String, dynamic> data = {
        "matricule": tagsController.faceResult.value,
        "heure": "${DateTime.now().hour}:${DateTime.now().minute}",
        "key": key,
        "coordonnees": latlng,
      };

      var response = await Api.request(
        url: "presence.create",
        method: "post",
        body: data,
        files: {
          'photo': File(tagsController.face.value!.path),
        },
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          return response["message"];
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  //close pending patrol
  Future<dynamic> stopPendingPatrol(String? comment) async {
    var patrolId = localStorage.read("patrol_id");
    var data = {"patrol_id": patrolId, "comment_text": comment!};
    try {
      var response = await Api.request(
        url: "patrol.close",
        method: "post",
        body: data,
        files: {
          "photo": File(tagsController.face.value!.path),
        },
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          localStorage.remove("patrol_id");
          tagsController.refreshPending();
          return "Patrouille clôturée avec succès.";
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête $e!";
    }
  }

  //Create Request by agent
  Future<dynamic> createRequest(String object, String desc) async {
    var data = {
      "object": object,
      "description": desc,
      "agent_id": authController.userSession.value.id,
      "agency_id": authController.userSession.value.agencyId
    };
    try {
      var response = await Api.request(
        url: "request.create",
        method: "post",
        body: data,
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          return response["result"];
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  //update notification token
  Future<dynamic> updateSiteTOKEN(String? token, id) async {
    var data = {
      "site_id": id,
      "fcm_token": token,
    };
    try {
      var response = await Api.request(
        url: "site.token",
        method: "post",
        body: data,
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          return response["result"];
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  Future<dynamic> saveLog(Map<String, dynamic> data) async {
    try {
      var response = await Api.request(
        url: "log.create",
        method: "post",
        body: data,
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          return response["result"];
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  // Create Signalement
  Future<dynamic> createSignalement(String title, String description) async {
    var file = tagsController.mediaFile.value!;

    try {
      var response = await Api.request(
        method: "post",
        url: "signalement.create",
        body: {
          "title": title,
          "description": description,
          "site_id": authController.userSession.value.siteId.toString(),
          "agent_id": authController.userSession.value.id.toString(),
          "agency_id": authController.userSession.value.agencyId.toString(),
        },
        files: {
          "media": file,
        },
      );

      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          return response["result"];
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur createSignalement: $e");
      }
      return "Échec de traitement de la requête";
    }
  }

  //load announces
  static Future<List<Announce>> getAllAnnounces() async {
    var user = authController.userSession.value;
    List<Announce> announces = [];
    try {
      var response = await Api.request(
        method: "get",
        url: "announces.load?site_id=${user.siteId}&agency_id=${user.agencyId}",
      );
      if (response != null) {
        var jsonArr = response["announces"];
        jsonArr.forEach((e) {
          announces.add(Announce.fromJson(e));
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Request Error ${e.toString()}");
      }
    }
    return announces;
  }

  //load announces
  static Future<List<Planning>> getAllPlannings() async {
    var user = authController.userSession.value;
    List<Planning> plannings = [];
    try {
      var response = await Api.request(
        method: "get",
        url: "schedules.all?site_id=${user.siteId}&agency_id=${user.agencyId}",
      );
      if (response != null) {
        var jsonArr = response["schedules"];
        localStorage.write("schedules", jsonArr);
        jsonArr.forEach((e) {
          plannings.add(Planning.fromJson(e));
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Request Error ${e.toString()}");
      }
    }
    return plannings;
  }

  // Fonction pour récupérer la position actuelle
  Future<dynamic> _getCurrentLocation() async {
    try {
      await _checkPermission();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          EasyLoading.showInfo("GPS trop lent, délai dépassé.");
          throw TimeoutException("GPS trop lent, délai dépassé.");
        },
      );
      if (kDebugMode) {
        print("${position.latitude},${position.longitude}");
      }
      return "${position.latitude},${position.longitude}";
    } catch (e) {
      return null;
    }
  }

  Future<SupervisorDataResponse?> loadSupervisorData() async {
    SupervisorDataResponse? datas;
    var agent = authController.userSession.value;
    try {
      if (agent.role == 'supervisor') {
        var response = await Api.request(
          method: "get",
          url: "supervisor.datas?_id=${agent.id}",
        );
        if (response != null) {
          var json = response["datas"];
          datas = await compute(parseSupervisorData, json);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Request Error ${e.toString()}");
      }
    }
    return datas;
  }

  Future<dynamic> makeSupervision(siteId, planningId,
      {List<Map<String, dynamic>>? elements}) async {
    try {
      var latlng = await _getCurrentLocation();
      var data = <String, dynamic>{
        if (authController.pendingSupervisionMap.isNotEmpty)
          "id": authController.pendingSupervisionMap["id"],
        "site_id": siteId,
        "schedule_id": planningId,
        "latlng": latlng,
        "matricule": authController.userSession.value.matricule,
        "comment": "",
        if (elements != null) "elements": jsonEncode(elements)
      };

      var response = await Api.request(
        url: "supervisor.visit.create",
        method: "post",
        body: data,
        files: {
          "photo": File(tagsController.face.value!.path),
        },
      );
      if (kDebugMode) {
        print(response);
      }
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          localStorage.write("pending_supervision", response["result"]);
          authController.refreshPendingSupervisionMap();
          return response["result"];
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  Future<List<Map<String, dynamic>>> checkPending() async {
    List<Map<String, dynamic>> data = [];
    var siteId = authController.userSession.value.siteId;
    try {
      var response = await Api.request(
          method: "get", url: "site.patrol.pending?id=$siteId");
      if (response != null) {
        var patrol = response["patrol"];
        for (var e in patrol) {
          data.add(e as Map<String, dynamic>);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error $e");
      }
    }
    return data;
  }

  // Fonction pour vérifier et demander la permission de localisation
  Future<void> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Vérifie si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si le service est désactivé, vous pouvez demander à l'utilisateur de l'activer
      return Future.error('Le service de localisation est désactivé.');
    }

    // Vérifie les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Si la permission est refusée, affiche un message
        return Future.error('La permission de localisation est refusée.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Si la permission est refusée de manière permanente
      return Future.error(
          'La permission de localisation est refusée de manière permanente.');
    }
  }
}
