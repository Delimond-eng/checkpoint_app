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
import 'package:intl/intl.dart';

SupervisorDataResponse parseSupervisorData(dynamic json) {
  return SupervisorDataResponse.fromJson(json as Map<String, dynamic>);
}

class HttpManager {
  static final Set<String> _processingPresences = {};

  String _now() => DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  String _timeHHmm() => DateFormat('HH:mm').format(DateTime.now());
  String _dateOnly() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String _extractTimeOnly(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return _timeHHmm();
    String time = dateTimeStr;
    if (dateTimeStr.contains(' ')) {
      time = dateTimeStr.split(' ').last;
    }
    return time.length >= 5 ? time.substring(0, 5) : time;
  }

  String _formatToBackend(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return _now();
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Future<bool> _isOffline() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.isEmpty || connectivityResult.every((r) => r == ConnectivityResult.none)) {
        return true;
      }
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));
      return result.isEmpty || result[0].rawAddress.isEmpty;
    } catch (_) {
      return true;
    }
  }

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
    var latlng = await _getCurrentLocation() ?? "0.0,0.0";
    var patrolIdVal = tagsController.patrolId.value;
    var planningId = tagsController.planningId.value; // Ceci est le schedule_id
    var user = authController.userSession.value!;
    var nowStr = _now();
    var timeHHmm = _timeHHmm();

    var data = {
      "site_id": user.siteId,
      "agency_id": user.agencyId,
      "agent_id": user.id,
      "area_id": tagsController.scannedArea.value.id,
      "schedule_id": planningId,
      "matricule": tagsController.faceResult.value,
      "comment": comment,
      "latlng": latlng,
      "started_at": nowStr,
      "time": timeHHmm,
    };

    if (patrolIdVal != 0) {
      data["patrol_id"] = patrolIdVal.toString();
    }

    File photoFile = await ImageService.compressForUpload(tagsController.face.value!);

    if (await _isOffline()) {
      // 🔥 REUTILISATION DU SESSION ID POUR EVITER LES DOUBLONS DE PATROUILLE
      String? localSessionId = localStorage.read("local_session_id");
      if (localSessionId == null || localSessionId == "" || patrolIdVal != 0) {
        localSessionId = DateTime.now().millisecondsSinceEpoch.toString();
        localStorage.write("local_session_id", localSessionId);
      }

      await LocalDbService.instance.addPendingAction({
        'type': 'scan',
        'local_session_id': localSessionId,
        'patrol_id': patrolIdVal != 0 ? patrolIdVal.toString() : "",
        'site_id': user.siteId,
        'agency_id': user.agencyId,
        'agent_id': user.id,
        'area_id': data['area_id'],
        'schedule_id': data['schedule_id'],
        'matricule': data['matricule'],
        'comment': data['comment'],
        'latlng': data['latlng'],
        'photo_path': photoFile.path,
        'created_at': nowStr,
        'started_at': nowStr,
        'time': timeHHmm,
      });

      if (patrolIdVal == 0) {
        tagsController.isOfflinePatrolActive.value = true;
        localStorage.write("is_offline_patrol", true);
        localStorage.write("active_schedule_id", planningId);
        if (planningId.isNotEmpty) await tagsController.removePlanningLocally(int.parse(planningId));
      }
      return "Hors-ligne : Scan enregistré localement.";
    }

    try {
      var response = await Api.request(url: "patrol.scan", method: "post", body: data, files: {"photo": photoFile});
      if (response != null && !response.containsKey("errors")) {
        // Enregistre le vrai ID retourné par le serveur
        var realId = response["result"]["patrol_id"] ?? response["result"]["id"];
        if (realId != null) {
          localStorage.write("patrol_id", realId);
          tagsController.patrolId.value = realId is int ? realId : int.parse(realId.toString());
        }
        if (patrolIdVal == 0 && planningId.isNotEmpty) await tagsController.removePlanningLocally(int.parse(planningId));
        tagsController.refreshPending();
        return response["message"] ?? "Ronde enregistrée avec succès.";
      }
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) {
      EasyLoading.showError("Erreur réseau : $e");
      return null;
    }
  }

  // Close pending patrol
  Future<dynamic> stopPendingPatrol(String? comment) async {
    var patrolIdVal = localStorage.read("patrol_id");
    var localSessionId = localStorage.read("local_session_id");
    var planningId = tagsController.planningId.value;
    var user = authController.userSession.value!;
    var nowStr = _now();
    var timeHHmm = _timeHHmm();
    File photoFile = await ImageService.compressForUpload(tagsController.face.value!);

    if (await _isOffline()) {
      await LocalDbService.instance.addPendingAction({
        'type': 'close',
        'patrol_id': (patrolIdVal != null && patrolIdVal != 0) ? patrolIdVal.toString() : "",
        'local_session_id': localSessionId ?? "",
        'schedule_id': planningId,
        'agent_id': user.id,
        'comment': comment,
        'photo_path': photoFile.path,
        'created_at': nowStr,
        'ended_at': nowStr,
        'time': timeHHmm,
      });
      localStorage.remove("patrol_id");
      localStorage.remove("is_offline_patrol");
      localStorage.remove("local_session_id");
      localStorage.remove("active_schedule_id");
      tagsController.isOfflinePatrolActive.value = false;
      tagsController.refreshPending();
      return "Hors-ligne : Clôture enregistrée localement.";
    }

    try {
      Map<String, dynamic> data = {
        "schedule_id": planningId,
        "agent_id": user.id,
        "comment_text": comment ?? "",
        "ended_at": nowStr,
        "time": timeHHmm,
      };
      if (patrolIdVal != null && patrolIdVal != 0) data["patrol_id"] = patrolIdVal.toString();

      var response = await Api.request(url: "patrol.close", method: "post", body: data, files: {"photo": photoFile});
      if (response != null && !response.containsKey("errors")) {
        localStorage.remove("patrol_id");
        localStorage.remove("local_session_id");
        localStorage.remove("is_offline_patrol");
        localStorage.remove("active_schedule_id");
        tagsController.isOfflinePatrolActive.value = false;
        tagsController.refreshPending();
        return response["message"] ?? "Patrouille clôturée avec succès.";
      }
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) {
      EasyLoading.showError("Erreur réseau : $e");
      return null;
    }
  }

  // Sync locally stored actions
  Future<dynamic> syncLocalAction(Map<String, dynamic> action) async {
    try {
      File? photoFile;
      if (action['photo_path'] != null) {
        photoFile = File(action['photo_path']);
        if (!await photoFile.exists()) return {"status": "success"};
      }

      if (action['type'] == 'scan') {
        Map<String, dynamic> body = {
          "site_id": action['site_id'],
          "agency_id": action['agency_id'],
          "agent_id": action['agent_id'],
          "area_id": action['area_id'],
          "schedule_id": action['schedule_id'],
          "matricule": action['matricule'],
          "comment": action['comment'],
          "latlng": action['latlng'],
          "started_at": _formatToBackend(action['started_at'] ?? action['created_at']),
          "time": _extractTimeOnly(action['time']),
        };
        if (action['patrol_id'] != null && action['patrol_id'] != "" && action['patrol_id'] != "0") {
          body["patrol_id"] = action['patrol_id'];
        }
        var response = await Api.request(url: "patrol.scan", method: "post", body: body, files: photoFile != null ? {"photo": photoFile} : null);
        if (response != null && !response.containsKey("errors")) {
           return response["result"] ?? response; 
        }
        return response;
      } else if (action['type'] == 'close') {
        Map<String, dynamic> body = {
          "schedule_id": action['schedule_id'],
          "agent_id": action['agent_id'],
          "comment_text": action['comment'],
          "ended_at": _formatToBackend(action['ended_at'] ?? action['created_at']),
          "time": _extractTimeOnly(action['time']),
        };
        if (action['patrol_id'] != null && action['patrol_id'] != "" && action['patrol_id'] != "0") {
          body["patrol_id"] = action['patrol_id'];
        }
        return await Api.request(url: "patrol.close", method: "post", body: body, files: photoFile != null ? {"photo": photoFile} : null);
      } else if (action['type'] == 'presence') {
        var body = {
          "matricule": action['matricule'],
          "key": action['key'],
          "coordonnees": action['latlng'] ?? "0.0,0.0",
          "date_reference": action['date_reference'],
          "started_at": action['started_at'],
          "ended_at": action['ended_at'],
        };
        return await Api.request(url: "presence.create", method: "post", body: body, files: photoFile != null ? {"photo": photoFile} : null);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Presence signal
  Future<dynamic> checkPresence({String? key}) async {
    var user = authController.userSession.value!;
    
    // Verrouillage anti-double clic
    String lockKey = "${user.id}_$key";
    if (_processingPresences.contains(lockKey)) return null;
    _processingPresences.add(lockKey);

    try {
      var latlng = await _getCurrentLocation() ?? "0.0,0.0";
      var dateRef = _dateOnly();
      var fullNow = _now();
      File photoFile = await ImageService.compressForUpload(tagsController.face.value!);

      // Vérification file d'attente locale
      final pending = await LocalDbService.instance.getPendingActions();
      if (pending.any((a) => a['type'] == 'presence' && a['key'] == key && a['date_reference'] == dateRef)) {
        EasyLoading.showInfo("Pointage déjà en attente de synchronisation.");
        return null;
      }

      if (await _isOffline()) {
        await LocalDbService.instance.addPendingAction({
          'type': 'presence',
          'matricule': user.matricule,
          'key': key,
          'latlng': latlng,
          'started_at': key == 'check-in' ? fullNow : null,
          'ended_at': key == 'check-out' ? fullNow : null,
          'date_reference': dateRef,
          'photo_path': photoFile.path,
          'created_at': fullNow,
        });
        return "Hors-ligne : Pointage enregistré localement.";
      }

      try {
        Map<String, dynamic> data = {
          "matricule": user.matricule, 
          "key": key, 
          "coordonnees": latlng,
          "date_reference": dateRef,
          "started_at": key == 'check-in' ? fullNow : null,
          "ended_at": key == 'check-out' ? fullNow : null,
        };
        var response = await Api.request(url: "presence.create", method: "post", body: data, files: {'photo': photoFile});
        if (response != null && !response.containsKey("errors")) return response["message"] ?? "Succès";
        EasyLoading.showError(_parseError(response));
        return null;
      } catch (e) {
        EasyLoading.showError("Echec : $e");
        return null;
      }
    } finally {
      _processingPresences.remove(lockKey);
    }
  }

  // Common methods
  Future<dynamic> createRequest(String object, String desc) async {
    var data = {"object": object, "description": desc, "agent_id": authController.userSession.value!.id, "agency_id": authController.userSession.value!.agencyId};
    try {
      var response = await Api.request(url: "request.create", method: "post", body: data);
      if (response != null && !response.containsKey("errors")) return response["result"];
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) { return null; }
  }

  Future<dynamic> createSignalement(String title, String description) async {
    var user = authController.userSession.value!;
    try {
      File photoFile = await ImageService.compressForUpload(tagsController.mediaFile.value!);
      var response = await Api.request(method: "post", url: "signalement.create", body: {"title": title, "description": description, "site_id": user.siteId.toString(), "agent_id": user.id.toString(), "agency_id": user.agencyId.toString()}, files: {"media": photoFile});
      if (response != null && !response.containsKey("errors")) return response["result"];
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) { return null; }
  }

  Future<dynamic> enrollAgent(String matricule, List<double> embedding) async {
    try {
      File photoFile = await ImageService.compressForUpload(tagsController.face.value!);
      var response = await Api.request(url: "agent.enroll", method: "post", files: {"photo": photoFile}, body: {"matricule": matricule, "embedding": jsonEncode(embedding), "model_version": "facenet_v1"});
      if (response != null && !response.containsKey("errors")) return "success";
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) { return null; }
  }

  Future<List<SupElement>> getSupervisionElements() async {
    List<SupElement> elements = [];
    try {
      var response = await Api.request(method: "get", url: "supervision.elements");
      if (response != null && response["elements"] != null) {
        var jsonArr = response["elements"];
        jsonArr.forEach((e) => elements.add(SupElement.fromJson(e)));
      }
    } catch (e) {}
    return elements;
  }

  Future<List<User>> getStationAgents(id) async {
    List<User> agents = [];
    try {
      var response = await Api.request(method: "get", url: "supervision.agents?id=$id");
      if (response != null && response["agents"] != null) {
        var jsonArr = response["agents"];
        jsonArr.forEach((e) => agents.add(User.fromJson(e)));
      }
    } catch (e) {}
    return agents;
  }

  Future<dynamic> completeSite() async {
    var latlng = await _getCurrentLocation();
    try {
      var response = await Api.request(url: "site.complete", method: "post", body: {"site_id": tagsController.scannedSite.value.id, "latlng": latlng});
      if (response != null && !response.containsKey("errors")) return "Station GPS completé avec succès.";
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) { return null; }
  }

  Future<dynamic> saveLog(Map<String, dynamic> data) async {
    try {
      var response = await Api.request(url: "log.create", method: "post", body: data);
      return (response != null && !response.containsKey("errors")) ? response["result"] : null;
    } catch (e) { return null; }
  }

  String _parseError(dynamic response) {
    if (response == null) return "Erreur serveur inconnue.";
    if (response is Map && response.containsKey("errors")) {
      var err = response["errors"];
      if (err is List && err.isNotEmpty) return err[0].toString();
      if (err is Map && err.isNotEmpty) return err.values.first.toString();
      return err.toString();
    }
    return "Une erreur est survenue.";
  }

  static Future<List<Announce>?> getAllAnnounces() async {
    if (authController.userSession.value == null) return null;
    var user = authController.userSession.value!;
    List<Announce> announcesList = [];
    try {
      var response = await Api.request(method: "get", url: "announces.load?site_id=${user.siteId}&agency_id=${user.agencyId}");
      if (response != null && response["announces"] != null) {
        var jsonArr = response["announces"];
        jsonArr.forEach((e) => announcesList.add(Announce.fromJson(e)));
      }
      return announcesList;
    } catch (e) { return null; }
  }

  static Future<List<Planning>?> getAllPlannings() async {
    if (authController.userSession.value == null) return null;
    var user = authController.userSession.value!;
    List<Planning> planningsList = [];
    try {
      var response = await Api.request(method: "get", url: "schedules.all?site_id=${user.siteId}&agency_id=${user.agencyId}");
      if (response != null && response["schedules"] != null) {
        var jsonArr = response["schedules"];
        localStorage.write("schedules", jsonArr);
        jsonArr.forEach((e) => planningsList.add(Planning.fromJson(e)));
      }
      return planningsList;
    } catch (e) { return null; }
  }

  Future<dynamic> confirm011Ronde(String comment) async {
    var latlng = await _getCurrentLocation();
    try {
      File photoFile = await ImageService.compressForUpload(tagsController.face.value!);
      var response = await Api.request(url: "ronde.scan", method: "post", body: {"site_id": tagsController.scannedSite.value.id, "matricule": tagsController.faceResult.value, "comment": comment, "latlng": latlng}, files: {"photo": photoFile});
      return (response != null && !response.containsKey("errors")) ? "success" : null;
    } catch (e) { return null; }
  }

  Future<dynamic> completeArea(String libelle) async {
    var latlng = await _getCurrentLocation();
    try {
      var response = await Api.request(url: "area.complete", method: "post", body: {"area_id": tagsController.scannedArea.value.id, "libelle": libelle, "latlng": latlng});
      if (response != null && !response.containsKey("errors")) return "Zone completée avec succès.";
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) { return null; }
  }

  Future<dynamic> startSupervison() async {
    var file = File(tagsController.face.value!.path);
    var latlng = await _getCurrentLocation();
    File photoFile = await ImageService.compressForUpload(file);
    try {
      var response = await Api.request(method: "post", url: "supervision.start", body: {"site_id": tagsController.scannedSite.value.id, "matricule": tagsController.faceResult.value, "latlng": latlng}, files: {"photo": photoFile});
      if (response != null && !response.containsKey("errors")) {
        localStorage.write("supervision", response["result"]["supervision"]);
        authController.refreshSupervision();
        return response["result"];
      }
      EasyLoading.showError(_parseError(response));
      return null;
    } catch (e) { return null; }
  }

  Future<dynamic> _getCurrentLocation() async {
    try {
      await _checkPermission();
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).timeout(const Duration(seconds: 10));
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

  Future<List<Map<String, dynamic>>?> checkPending() async {
    var user = authController.userSession.value;
    if (user == null || user.siteId == null) return null;
    try {
      var response = await Api.request(method: "get", url: "site.patrol.pending?id=${user.siteId}");
      if (response != null && response["patrol"] != null) {
        return List<Map<String, dynamic>>.from(response["patrol"]);
      }
      return null;
    } catch (e) { return null; }
  }

  Future<dynamic> updateSiteTOKEN(String? token, id) async {
    try {
      var response = await Api.request(url: "site.token", method: "post", body: {"site_id": id, "fcm_token": token});
      return (response != null && !response.containsKey("errors")) ? response["result"] : null;
    } catch (e) { return null; }
  }
}
