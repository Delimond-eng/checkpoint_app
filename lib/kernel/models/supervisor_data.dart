class SupervisorDataResponse {
  final List<ElementModel> elements;
  final List<SiteModel> sites;

  SupervisorDataResponse({
    required this.elements,
    required this.sites,
  });

  factory SupervisorDataResponse.fromJson(Map<String, dynamic> json) {
    return SupervisorDataResponse(
      elements: List<ElementModel>.from(
          json["elements"].map((x) => ElementModel.fromJson(x))),
      sites:
          List<SiteModel>.from(json["sites"].map((x) => SiteModel.fromJson(x))),
    );
  }
}

class ElementModel {
  final int id;
  final String libelle;
  final String description;

  List<Map<String, dynamic>> checkTasks;

  ElementModel({
    required this.id,
    required this.libelle,
    required this.description,
    List<Map<String, dynamic>>? checkTasks,
  }) : checkTasks = checkTasks ??
            [
              {"label": "B", "isActive": false},
              {"label": "P", "isActive": false},
              {"label": "M", "isActive": false},
            ];

  void activateNote(String label) {
    final wasActive =
        checkTasks.firstWhere((t) => t["label"] == label)["isActive"];
    for (var task in checkTasks) {
      task["isActive"] = false;
    }
    // toggle si déjà actif, sinon active
    if (!wasActive) {
      checkTasks.firstWhere((t) => t["label"] == label)["isActive"] = true;
    }
  }

  String? get selectedNote {
    return checkTasks.firstWhere((t) => t["isActive"],
        orElse: () => {})["label"];
  }

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      id: json["id"],
      libelle: json["libelle"],
      description: json["description"],
    );
  }

  /// ✅ Méthode de clonage
  factory ElementModel.cloneFrom(ElementModel other) {
    return ElementModel(
      id: other.id,
      libelle: other.libelle,
      description: other.description,
      checkTasks: other.checkTasks
          .map((task) => Map<String, dynamic>.from(task))
          .toList(),
    );
  }
}

class SiteModel {
  final int siteId;
  final String siteCode;
  final String siteLibelle;
  final int sitePlanningId;
  final int planningId;
  final String planningTitle;
  final String planningDate;
  final String status;
  final int order;
  final int agentId;
  final List<AgentModel> agents;

  SiteModel({
    required this.siteId,
    required this.siteCode,
    required this.siteLibelle,
    required this.sitePlanningId,
    required this.planningId,
    required this.planningTitle,
    required this.planningDate,
    required this.status,
    required this.order,
    required this.agentId,
    required this.agents,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      siteId: json["site_id"],
      siteCode: json["site_code"],
      siteLibelle: json["site_liblle"], // attention à corriger ici si besoin
      sitePlanningId: json["site_planning_id"],
      planningId: json["planning_id"],
      planningTitle: json["planning_title"],
      planningDate: json["planning_date"],
      status: json["status"],
      order: json["order"],
      agentId: json["agent_id"],
      agents: List<AgentModel>.from(
          json["agents"].map((x) => AgentModel.fromJson(x))),
    );
  }
}

class AgentModel {
  final int id;
  final String matricule;
  final String? photo;
  final String fullname;
  final String password;
  final String role;
  final int agencyId;
  final int siteId;
  final int groupeId;
  final String status;
  final String createdAt;
  final String updatedAt;

  AgentModel({
    required this.id,
    required this.matricule,
    this.photo,
    required this.fullname,
    required this.password,
    required this.role,
    required this.agencyId,
    required this.siteId,
    required this.groupeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json["id"],
      matricule: json["matricule"],
      photo: json["photo"],
      fullname: json["fullname"],
      password: json["password"],
      role: json["role"],
      agencyId: json["agency_id"],
      siteId: json["site_id"],
      groupeId: json["groupe_id"],
      status: json["status"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
    );
  }
}
