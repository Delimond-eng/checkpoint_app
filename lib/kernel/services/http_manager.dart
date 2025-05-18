import 'dart:io';

import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/announce.dart';
import 'package:checkpoint_app/kernel/models/planning.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:checkpoint_app/kernel/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

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
    try {
      var data = {
        "site_id": authController.userSession.value.siteId,
        "agency_id": authController.userSession.value.agencyId,
        "patrol_id": patrolId != 0 ? patrolId : null,
        "matricule": tagsController.faceResult.value,
        "scan": {
          "agent_id": authController.userSession.value.id,
          "area_id": tagsController.scannedArea.value.id,
          "comment": comment,
          "latlng": latlng,
        }
      };
      var response = await Api.request(
        url: "patrol.scan",
        method: "post",
        body: data,
        files: {
          "photo": File(
            tagsController.face.value!.path,
          ),
        },
      );
      if (response != null) {
        if (response.containsKey("errors")) {
          return response["errors"].toString();
        } else {
          if (localStorage.read("patrol_id") == null) {
            localStorage.write("patrol_id", response["result"]["id"]);
          }
          tagsController.refreshPending();
          return "success";
        }
      } else {
        return response["errors"].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
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
          return response["errors"].toString();
        } else {
          if (localStorage.read("patrol_id") == null) {
            localStorage.write("patrol_id", response["result"]["id"]);
          }
          tagsController.refreshPending();
          return "success";
        }
      } else {
        return response["errors"].toString();
      }
    } catch (e) {
      return "Echec de traitement de la requête !";
    }
  }

  //Presence signal
  Future<dynamic> checkPresence() async {
    var latlng = await _getCurrentLocation();
    try {
      Map<String, dynamic> data = {
        "matricule": tagsController.faceResult.value,
        "heure": "${DateTime.now().hour}:${DateTime.now().minute}",
        "status_photo": "success",
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
          return response["errors"].toString();
        } else {
          return "success";
        }
      } else {
        return response["errors"].toString();
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
          return response["errors"].toString();
        } else {
          localStorage.remove("patrol_id");
          tagsController.refreshPending();
          return response["result"];
        }
      } else {
        return response["errors"].toString();
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
          return response["errors"].toString();
        } else {
          return response["result"];
        }
      } else {
        return response["errors"].toString();
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
          return response["errors"].toString();
        } else {
          return response["result"];
        }
      } else {
        return response["errors"].toString();
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
      print("Request Error ${e.toString()}");
    }
    return plannings;
  }

  // Fonction pour récupérer la position actuelle
  Future<dynamic> _getCurrentLocation() async {
    try {
      // Vérification des permissions
      await _checkPermission();
      // Obtention de la position actuelle
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
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
