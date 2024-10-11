// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/announce.dart';
import 'package:checkpoint_app/kernel/models/planning.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:checkpoint_app/kernel/services/api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';

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
      print(e);
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
        "scan": {
          "agent_id": authController.userSession.value.id,
          "area_id": tagsController.scannedArea.value.id,
          "comment": comment,
          "latlng": latlng
        }
      };
      var response = await Api.request(
        url: "patrol.scan",
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

  //Complete Area
  Future<dynamic> completeArea() async {
    var latlng = await _getCurrentLocation();
    try {
      var data = {
        "area_id": tagsController.scannedArea.value.id,
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

  //close pending patrol
  Future<dynamic> stopPendingPatrol(String? comment) async {
    var patrolId = localStorage.read("patrol_id");
    var data = {"patrol_id": patrolId, "comment_text": comment!};
    try {
      var response = await Api.request(
        url: "patrol.close",
        method: "post",
        body: data,
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
    String fileName = basename(file.path); // Récupère le nom du fichier
    String ext =
        extension(file.path).toLowerCase(); // Récupère l'extension du fichier

    // Déterminer le type MIME basé sur l'extension du fichier
    MediaType? mediaType;

    if (ext == '.jpg' || ext == '.jpeg') {
      mediaType = MediaType('image', 'jpeg');
    } else if (ext == '.png') {
      mediaType = MediaType('image', 'png');
    } else if (ext == '.mp4') {
      mediaType = MediaType('video', 'mp4');
    } else {
      return "Format de fichier non supporté";
    }

    // Créer la requête multipart
    var uri = Uri.parse("${Api.baseUrl}/signalement.create"); // URL de ton API
    var request = http.MultipartRequest('POST', uri);

    // Ajouter les champs de données
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['site_id'] =
        authController.userSession.value.siteId.toString();
    request.fields['agent_id'] = authController.userSession.value.id.toString();
    request.fields['agency_id'] =
        authController.userSession.value.agencyId.toString();

    // Ajouter le fichier à la requête multipart avec le bon type MIME
    request.files.add(
      await http.MultipartFile.fromPath(
        'media',
        file.path,
        filename: fileName,
        contentType: mediaType, // Ajout du type MIME approprié
      ),
    );

    try {
      // Envoyer la requête
      var response = await request.send();
      // Lire la réponse
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse["status"] == "success") {
          return decodedResponse;
        } else {
          return "Une erreur est survenue lors de la transmission de données !";
        }
      } else {
        return "Échec de traitement de la requête !";
      }
    } catch (e) {
      print(e);
      return "Échec de traitement de la requête";
    }
  }

  //load announces
  static Future<List<Announce>> getAllAnnounces() async {
    var user = authController.userSession.value;
    List<Announce> announces = [];
    try {
      var response = await Api.request(
        url: "announces.load?site_id=${user.siteId}&agency_id=${user.agencyId}",
      );
      if (response != null) {
        var jsonArr = response["announces"];
        jsonArr.forEach((e) {
          announces.add(Announce.fromJson(e));
        });
      }
    } catch (e) {
      print("Request Error ${e.toString()}");
    }
    return announces;
  }

  //load announces
  static Future<List<Planning>> getAllPlannings() async {
    var user = authController.userSession.value;
    List<Planning> plannings = [];
    try {
      var response = await Api.request(
        url: "schedules.all?site_id=${user.siteId}&agency_id=${user.agencyId}",
      );
      if (response != null) {
        var jsonArr = response["schedules"];
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
      return "${position.latitude}:${position.longitude}";
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
