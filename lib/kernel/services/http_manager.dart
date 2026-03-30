import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '/global/controllers.dart';
import '/global/store.dart';
import '/kernel/models/announce.dart';
import '/kernel/models/planning.dart';
import '/kernel/models/supervision_element.dart';
import '/kernel/models/supervisor_data.dart';
import '/kernel/models/user.dart';
import '/kernel/services/api.dart';
import '/kernel/services/firebase_service.dart';
import '/kernel/services/local_db_service.dart';
import '/kernel/services/image_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

SupervisorDataResponse parseSupervisorData(dynamic json) {
  return SupervisorDataResponse.fromJson(json as Map<String, dynamic>);
}

class HttpManager {
  // Agent login
  Future<dynamic> login({required String uMatricule, required String uPass}) async {
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
            if (kDebugMode) print('Firebase error $e');
          }
          return agent;
        }
      } else {
        return "Echec de connexion.";
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  // Start scanning for patrol (with Offline Support)
  Future<dynamic> beginPatrol(String comment) async {
    var latlng = await _getCurrentLocation();
    var patrolId = tagsController.patrolId.value;
    var planningId = tagsController.planningId.value;
    var user = authController.userSession.value!;
    var now = DateTime.now().toIso8601String();

    var data = {
      "patrol_id": patrolId != 0 ? patrolId.toString() : "",
      "site_id": user.siteId,
      "agency_id": user.agencyId,
      "agent_id": user.id,
      "scan_agent_id": user.id,
      "area_id": tagsController.scannedArea.value.id,
      "schedule_id": planningId,
      "matricule": tagsController.faceResult.value,
      "comment": comment,
      "latlng": latlng,
      "time": now,
      "started_at": patrolId == 0 ? now : null,
    };

    File photoFile = await ImageService.compressForUpload(tagsController.face.value!);

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      String localSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      await LocalDbService.instance.addPendingAction({
        'type': 'scan',
        'local_session_id': localSessionId,
        'patrol_id': data['patrol_id'],
        'site_id': data['site_id'],
        'agency_id': data['agency_id'],
        'agent_id': data['agent_id'],
        'area_id': data['area_id'],
        'schedule_id': data['schedule_id'],
        'matricule': data['matricule'],
        'comment': data['comment'],
        'latlng': data['latlng'],
        'photo_path': photoFile.path,
        'created_at': now,
      });

      if (patrolId == 0) {
        tagsController.isOfflinePatrolActive.value = true;
        localStorage.write("is_offline_patrol", true);
        localStorage.write("local_session_id", localSessionId);
        
        if (planningId.isNotEmpty) {
          await tagsController.removePlanningLocally(int.parse(planningId));
        }
      }
      
      return "Hors-ligne : Scan enregistré localement.";
    }

    try {
      var response = await Api.request(
        url: "patrol.scan",
        method: "post",
        body: data,
        files: {"photo": photoFile},
      );

      if (response != null && !response.containsKey("errors")) {
        if (localStorage.read("patrol_id") == null) {
          localStorage.write("patrol_id", response["result"]["id"]);
        }
        if (patrolId == 0 && planningId.isNotEmpty) {
          await tagsController.removePlanningLocally(int.parse(planningId));
        }
        tagsController.refreshPending();
        return response["message"] ?? "Ronde enregistrée avec succès.";
      }
      return _parseError(response);
    } catch (e) {
      return "Erreur réseau : $e";
    }
  }

  // Close pending patrol
  Future<dynamic> stopPendingPatrol(String? comment) async {
    var patrolId = localStorage.read("patrol_id");
    var localSessionId = localStorage.read("local_session_id");
    var now = DateTime.now().toIso8601String();
    File photoFile = await ImageService.compressForUpload(tagsController.face.value!);

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await LocalDbService.instance.addPendingAction({
        'type': 'close',
        'patrol_id': patrolId?.toString() ?? "",
        'local_session_id': localSessionId ?? "",
        'comment': comment,
        'photo_path': photoFile.path,
        'created_at': now,
      });
      
      localStorage.remove("patrol_id");
      localStorage.remove("is_offline_patrol");
      localStorage.remove("local_session_id");
      tagsController.isOfflinePatrolActive.value = false;
      tagsController.refreshPending();
      return "Hors-ligne : Clôture enregistrée localement.";
    }

    try {
      var response = await Api.request(
        url: "patrol.close",
        method: "post",
        body: {
          "patrol_id": patrolId, 
          "comment_text": comment!,
          "ended_at": now,
        },
        files: {"photo": photoFile},
      );

      if (response != null && !response.containsKey("errors")) {
        localStorage.remove("patrol_id");
        localStorage.remove("local_session_id");
        localStorage.remove("is_offline_patrol");
        tagsController.isOfflinePatrolActive.value = false;
        tagsController.refreshPending();
        return response["message"] ?? "Patrouille clôturée avec succès.";
      }
      return _parseError(response);
    } catch (e) {
      return "Erreur réseau : $e";
    }
  }

  // Sync locally stored actions
  Future<dynamic> syncLocalAction(Map<String, dynamic> action) async {
    try {
      var createdAt = action['created_at'];
      if (action['type'] == 'scan') {
        var response = await Api.request(
          url: "patrol.scan",
          method: "post",
          body: {
            "patrol_id": action['patrol_id'],
            "site_id": action['site_id'],
            "agency_id": action['agency_id'],
            "agent_id": action['agent_id'],
            "scan_agent_id": action['agent_id'],
            "area_id": action['area_id'],
            "schedule_id": action['schedule_id'],
            "matricule": action['matricule'],
            "comment": action['comment'],
            "latlng": action['latlng'],
            "time": createdAt,
            "started_at": (action['patrol_id'] == null || action['patrol_id'] == "" || action['patrol_id'] == "0") ? createdAt : null,
          },
          files: {"photo": File(action['photo_path'])}, 
        );
        if (response != null && !response.containsKey("errors")) {
          return response["result"] as Map<String, dynamic>; 
        }
        return "error";
      } else if (action['type'] == 'close') {
        var response = await Api.request(
          url: "patrol.close",
          method: "post",
          body: {
            "patrol_id": action['patrol_id'], 
            "comment_text": action['comment'],
            "ended_at": createdAt,
          },
          files: {"photo": File(action['photo_path'])}, 
        );
        return (response != null && !response.containsKey("errors")) ? "success" : "error";
      }
      return "error";
    } catch (e) {
      return "error";
    }
  }

  // Presence signal
  Future<dynamic> checkPresence({String? key}) async {
    var latlng = await _getCurrentLocation();
    try {
      File photoFile = await ImageService.compressForUpload(tagsController.face.value!);
      Map<String, dynamic> data = {
        "matricule": tagsController.faceResult.value,
        "key": key,
        "coordonnees": latlng,
      };
      var response = await Api.request(url: "presence.create", method: "post", body: data, files: {'photo': photoFile});
      if (response != null) {
        if (response.containsKey("errors")) {
          return _parseError(response);
        } else {
          return response["message"] ?? "Pointage effectué avec succès.";
        }
      }
      return "Erreur lors du pointage.";
    } catch (e) {
      return "Echec : $e";
    }
  }

  // Create Request
  Future<dynamic> createRequest(String object, String desc) async {
    var data = {
      "object": object,
      "description": desc,
      "agent_id": authController.userSession.value!.id,
      "agency_id": authController.userSession.value!.agencyId
    };
    try {
      var response = await Api.request(url: "request.create", method: "post", body: data);
      if (response != null && !response.containsKey("errors")) {
        return response["result"];
      }
      return _parseError(response);
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  // Create Signalement
  Future<dynamic> createSignalement(String title, String description) async {
    var file = tagsController.mediaFile.value!;
    try {
      File photoFile = await ImageService.compressForUpload(file);
      var response = await Api.request(
        method: "post",
        url: "signalement.create",
        body: {
          "title": title,
          "description": description,
          "site_id": authController.userSession.value!.siteId.toString(),
          "agent_id": authController.userSession.value!.id.toString(),
          "agency_id": authController.userSession.value!.agencyId.toString(),
        },
        files: {"media": photoFile},
      );
      if (response != null && !response.containsKey("errors")) {
        return response["result"];
      }
      return _parseError(response);
    } catch (e) {
      return "Échec de traitement";
    }
  }

  // Enroll agent
  Future<dynamic> enrollAgent(String matricule, List<double> embedding) async {
    try {
      File photoFile = await ImageService.compressForUpload(tagsController.face.value!);
      var data = {
        "matricule": matricule,
        "embedding": jsonEncode(embedding),
        "model_version": "facenet_v1",
      };
      var response = await Api.request(url: "agent.enroll", method: "post", files: {"photo": photoFile}, body: data);
      if (response != null && !response.containsKey("errors")) {
        return "success";
      }
      return _parseError(response);
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  // Get Supervision Elements
  Future<List<SupElement>> getSupervisionElements() async {
    List<SupElement> elements = [];
    try {
      var response = await Api.request(method: "get", url: "supervision.elements");
      if (response != null && response["elements"] != null) {
        var jsonArr = response["elements"];
        jsonArr.forEach((e) => elements.add(SupElement.fromJson(e)));
      }
    } catch (e) {
      debugPrint("Error getSupervisionElements: $e");
    }
    return elements;
  }

  // Get Station Agents
  Future<List<User>> getStationAgents(id) async {
    List<User> agents = [];
    try {
      var response = await Api.request(method: "get", url: "supervision.agents?id=$id");
      if (response != null && response["agents"] != null) {
        var jsonArr = response["agents"];
        jsonArr.forEach((e) => agents.add(User.fromJson(e)));
      }
    } catch (e) {
      tagsController.isLoading.value = false;
    }
    return agents;
  }

  // Complete site
  Future<dynamic> completeSite() async {
    var latlng = await _getCurrentLocation();
    try {
      var data = {"site_id": tagsController.scannedSite.value.id, "latlng": latlng};
      var response = await Api.request(url: "site.complete", method: "post", body: data);
      if (response != null && !response.containsKey("errors")) {
        return "Station GPS completé avec succès.";
      }
      return _parseError(response);
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  // Save log
  Future<dynamic> saveLog(Map<String, dynamic> data) async {
    try {
      var response = await Api.request(url: "log.create", method: "post", body: data);
      if (response != null && !response.containsKey("errors")) {
        return response["result"];
      }
      return "error";
    } catch (e) {
      return "error";
    }
  }

  // Helper pour parser les erreurs Laravel
  String _parseError(dynamic response) {
    if (response == null) return "Erreur serveur inconnue.";
    if (response.containsKey("errors")) {
      var err = response["errors"];
      if (err is List && err.isNotEmpty) return err[0].toString();
      if (err is Map && err.isNotEmpty) return err.values.first.toString();
      return err.toString();
    }
    return "Une erreur est survenue.";
  }

  // Static loaders
  static Future<List<Announce>> getAllAnnounces() async {
    if (authController.userSession.value == null) return [];
    var user = authController.userSession.value!;
    List<Announce> announces = [];
    try {
      var response = await Api.request(method: "get", url: "announces.load?site_id=${user.siteId}&agency_id=${user.agencyId}");
      if (response != null && response["announces"] != null) {
        var jsonArr = response["announces"];
        jsonArr.forEach((e) => announces.add(Announce.fromJson(e)));
      }
    } catch (e) {}
    return announces;
  }

  static Future<List<Planning>> getAllPlannings() async {
    if (authController.userSession.value == null) return [];
    var user = authController.userSession.value!;
    List<Planning> planningsList = [];
    try {
      var response = await Api.request(method: "get", url: "schedules.all?site_id=${user.siteId}&agency_id=${user.agencyId}");
      if (response != null && response["schedules"] != null) {
        var jsonArr = response["schedules"];
        localStorage.write("schedules", jsonArr);
        jsonArr.forEach((e) => planningsList.add(Planning.fromJson(e)));
      }
    } catch (e) {}
    return planningsList;
  }

  // Other methods
  Future<dynamic> confirm011Ronde(String comment) async {
    var latlng = await _getCurrentLocation();
    try {
      File photoFile = await ImageService.compressForUpload(tagsController.face.value!);
      var data = {"site_id": tagsController.scannedSite.value.id, "matricule": tagsController.faceResult.value, "comment": comment, "latlng": latlng};
      var response = await Api.request(url: "ronde.scan", method: "post", body: data, files: {"photo": photoFile});
      return (response != null && !response.containsKey("errors")) ? "success" : "errors";
    } catch (e) { return "errors"; }
  }

  Future<dynamic> completeArea(String libelle) async {
    var latlng = await _getCurrentLocation();
    try {
      var data = {"area_id": tagsController.scannedArea.value.id, "libelle": libelle, "latlng": latlng};
      var response = await Api.request(url: "area.complete", method: "post", body: data);
      return (response != null && !response.containsKey("errors")) ? "Zone completée avec succès." : _parseError(response);
    } catch (e) { return "Echec"; }
  }

  Future<dynamic> startSupervison() async {
    var file = File(tagsController.face.value!.path);
    var latlng = await _getCurrentLocation();
    File photoFile = await ImageService.compressForUpload(file);
    var data = {"site_id": tagsController.scannedSite.value.id, "matricule": tagsController.faceResult.value, "latlng": latlng};
    try {
      var response = await Api.request(method: "post", url: "supervision.start", body: data, files: {"photo": photoFile});
      if (response != null && !response.containsKey("errors")) {
        localStorage.write("supervision", response["result"]["supervision"]);
        authController.refreshSupervision();
        return response["result"];
      }
      return _parseError(response);
    } catch (e) { return "Échec"; }
  }

  Future<dynamic> _getCurrentLocation() async {
    try {
      await _checkPermission();
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).timeout(const Duration(seconds: 60));
      return "${position.latitude},${position.longitude}";
    } catch (e) { return null; }
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Localisation désactivée.');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Permission refusée.');
    }
  }

  Future<List<Map<String, dynamic>>> checkPending() async {
    List<Map<String, dynamic>> data = [];
    var siteId = authController.userSession.value!.siteId;
    try {
      var response = await Api.request(method: "get", url: "site.patrol.pending?id=$siteId");
      if (response != null && response["patrol"] != null) {
        var patrol = response["patrol"];
        for (var e in patrol) {
          data.add(e as Map<String, dynamic>);
        }
      }
    } catch (e) {}
    return data;
  }

  Future<dynamic> updateSiteTOKEN(String? token, id) async {
    var data = {"site_id": id, "fcm_token": token};
    try {
      var response = await Api.request(url: "site.token", method: "post", body: data);
      return (response != null && !response.containsKey("errors")) ? response["result"] : "error";
    } catch (e) { return "error"; }
  }
}
