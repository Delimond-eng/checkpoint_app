class Task {
  String? title;
  bool isActive = false;

  Task({this.title, this.isActive = false});
}

List<Task> taches = [
  Task(title: "Contrôler l'entrée principale"),
  Task(title: "Effectuer la ronde de surveillance"),
  Task(title: "Vérifier les caméras de sécurité"),
  Task(title: "Vérifier les extincteurs"),
  Task(title: "Contrôler les badges des visiteurs"),
  Task(title: "Surveiller le parking"),
  Task(title: "Signaler toute activité suspecte"),
  Task(title: "Faire le rapport de fin de poste"),
];
