class Task {
  String? title;
  bool isActive = false;

  Task({this.title, this.isActive = false});
}

List<Task> taches = [
  Task(
      title:
          "Effectuer le câblage vidéo et alimentation (coaxial, RJ45, etc.)"),
  Task(title: "Installer et configurer le DVR/NVR"),
  Task(
      title:
          "Configurer les notifications d'alerte (email, application mobile)"),
  Task(title: "Faire des tests de vision nocturne (caméras IR)"),
  Task(
      title:
          "Effectuer un test de coupure de courant et de basculement sur onduleur"),
  Task(title: "Nettoyer régulièrement les lentilles des caméras"),
  Task(title: "Mettre à jour le firmware des caméras et du DVR/NVR"),
  Task(title: "Assurer une maintenance préventive régulière"),
  Task(title: "Dépanner les problèmes d'image, de réseau ou d'enregistrement"),
];
