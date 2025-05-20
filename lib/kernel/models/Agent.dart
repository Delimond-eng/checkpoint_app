import 'package:image_picker/image_picker.dart';

class Agent {
  String? nom;
  String? matricule;
  String? imagePath;
  XFile? file;

  Agent({this.nom, this.matricule, this.imagePath});

  Agent.fromJson(Map<String, dynamic> data) {
    nom = data["nom"];
    matricule = data["matricule"];
    imagePath = data["photo"];
  }
}
