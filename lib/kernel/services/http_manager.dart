import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/announce.dart';
import 'package:checkpoint_app/kernel/models/planning.dart';
import 'package:checkpoint_app/kernel/models/supervision_element.dart';
import 'package:checkpoint_app/kernel/models/supervisor_data.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:checkpoint_app/kernel/services/api.dart';
import 'package:checkpoint_app/kernel/services/firebase_service.dart';
import 'package:checkpoint_app/kernel/services/local_db_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  //Start scanning for patrol (with Offline Support)
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

    var photoPath = tagsController.face.value!.path;

    // Check connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // OFFLINE MODE: Save to local DB
      await LocalDbService.instance.addPendingAction({
        'type': 'scan',
        'local_session_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'patrol_id': data['patrol_id'],
        'site_id': data['site_id'],
        'agency_id': data['agency_id'],
        'agent_id': data['agent_id'],
        'area_id': data['area_id'],
        'schedule_id': data['schedule_id'],
        'matricule': data['matricule'],
        'comment': data['comment'],
        'latlng': data['latlng'],
        'photo_path': photoPath,
        'created_at': now,
      });
      return "Hors-ligne : Scan enregistré localement.";
    }

    try {
      var response = await Api.request(
        url: "patrol.scan",
        method: "post",
        body: data,
        files: {"photo": File(photoPath)},
      );

      if (response != null && !response.containsKey("errors")) {
        if (localStorage.read("patrol_id") == null) {
          localStorage.write("patrol_id", response["result"]["id"]);
        }
        tagsController.refreshPending();
        return "Patrouille enregistrée avec succès.";
      }
      return response?["errors"]?[0]?.toString() ?? "Erreur lors de l'enregistrement.";
    } catch (e) {
      return "Erreur réseau : $e";
    }
  }

  // Clôturer une patrouille (with Offline Support)
  Future<dynamic> stopPendingPatrol(String? comment) async {
    var patrolId = localStorage.read("patrol_id");
    var photoPath = tagsController.face.value!.path;
    var now = DateTime.now().toIso8601String();

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // OFFLINE MODE
      await LocalDbService.instance.addPendingAction({
        'type': 'close',
        'patrol_id': patrolId.toString(),
        'comment': comment,
        'photo_path': photoPath,
        'created_at': now,
      });
      localStorage.remove("patrol_id");
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
        files: {"photo": File(photoPath)},
      );

      if (response != null && !response.containsKey("errors")) {
        localStorage.remove("patrol_id");
        tagsController.refreshPending();
        return "Patrouille clôturée avec succès.";
      }
      return response?["errors"]?[0]?.toString() ?? "Erreur lors de la clôture.";
    } catch (e) {
      return "Erreur réseau : $e";
    }
  }

  // Logic used by SyncService - returns result Map or status String
  Future<dynamic> syncLocalAction(Map<String, dynamic> action) async {
    try {
      var createdAt = action['created_at'];
      if (action['type'] == 'scan') {
        var patrolId = action['patrol_id'];
        var response = await Api.request(
          url: "patrol.scan",
          method: "post",
          body: {
            "patrol_id": patrolId,
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
            "started_at": (patrolId == null || patrolId == "" || patrolId == "0") ? createdAt : null,
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

  //Enroll agent image and embedding
  Future<dynamic> enrollAgent(String matricule, List<double> embedding) async {
    try {
      var data = {
        "matricule": matricule,
        "embedding": jsonEncode(embedding),
        "model_version": "facenet_v1",
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
          return "success";
        }
      } else {
        return "Erreur serveur";
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
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
          return "Zone completée avec succès.";
        }
      } else {
        return response["errors"][0].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  //Complete site
  Future<dynamic> completeSite() async {
    var latlng = await _getCurrentLocation();
    try {
      var data = {
        "site_id": tagsController.scannedSite.value.id,
        "latlng": latlng
      };
      var response = await Api.request(
        url: "site.complete",
        method: "post",
        body: data,
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          return "Station GPS completé avec succès.";
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

  //Create Request by agent
  Future<dynamic> createRequest(String object, String desc) async {
    var data = {
      "object": object,
      "description": desc,
      "agent_id": authController.userSession.value!.id,
      "agency_id": authController.userSession.value!.agencyId
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
          "site_id": authController.userSession.value!.siteId.toString(),
          "agent_id": authController.userSession.value!.id.toString(),
          "agency_id": authController.userSession.value!.agencyId.toString(),
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
    var user = authController.userSession.value!;
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
    var user = authController.userSession.value!;
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

  //Get supervision elements
  Future<List<SupElement>> getSupervisionElements() async {
    List<SupElement> elements = [];
    try {
      var response = await Api.request(
        method: "get",
        url: "supervision.elements",
      );
      if (response != null) {
        var jsonArr = response["elements"];
        jsonArr.forEach((e) {
          elements.add(SupElement.fromJson(e));
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Request Error ${e.toString()}");
      }
      return [];
    }
    return elements;
  }

  //Show agent by station to supervize
  Future<List<User>> getStationAgents(id) async {
    var siteId = id;
    List<User> agents = [];
    try {
      var response = await Api.request(
        method: "get",
        url: "supervision.agents?id=$siteId",
      );
      if (response != null) {
        var jsonArr = response["agents"];
        jsonArr.forEach((e) {
          agents.add(User.fromJson(e));
        });
      }
    } catch (e) {
      tagsController.isLoading.value = false;
      if (kDebugMode) {
        print("Request Error ${e.toString()}");
      }
    }
    return agents;
  }

  //Start supervision
  Future<dynamic> startSupervison() async {
    var file = File(tagsController.face.value!.path);
    var latlng = await _getCurrentLocation();
    var data = {
      "site_id": tagsController.scannedSite.value.id,
      "matricule": tagsController.faceResult.value,
      "latlng": latlng
    };
    try {
      var response = await Api.request(
        method: "post",
        url: "supervision.start",
        body: data,
        files: {
          "photo": file,
        },
      );

      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"][0].toString();
        } else {
          var supervision = response["result"]["supervision"];
          localStorage.write("supervision", supervision);
          authController.refreshSupervision();
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

  Future<List<Map<String, dynamic>>> checkPending() async {
    List<Map<String, dynamic>> data = [];
    var siteId = authController.userSession.value!.siteId;
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
