class User {
  String? agentId;
  String? nom;
  String? postnom;
  String? prenom;
  String? code;
  String? telephone;
  String? fonction;
  String? grade;
  String? username;
  String? password;
  String? statutAgent;
  String? siteId;
  String? dateEnregistrement;

  User(
      {this.agentId,
      this.nom,
      this.postnom,
      this.prenom,
      this.code,
      this.telephone,
      this.fonction,
      this.grade,
      this.username,
      this.password,
      this.statutAgent,
      this.siteId,
      this.dateEnregistrement});

  User.fromJson(Map<String, dynamic> json) {
    agentId = json['agent_id'];
    nom = json['nom'];
    postnom = json['postnom'];
    prenom = json['prenom'];
    code = json['code'];
    telephone = json['telephone'];
    fonction = json['fonction'];
    grade = json['grade'];
    username = json['username'];
    password = json['password'];
    statutAgent = json['statut_agent'];
    siteId = json['site_id'];
    dateEnregistrement = json['date_enregistrement'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent_id'] = agentId;
    data['nom'] = nom;
    data['postnom'] = postnom;
    data['prenom'] = prenom;
    data['code'] = code;
    data['telephone'] = telephone;
    data['fonction'] = fonction;
    data['grade'] = grade;
    data['username'] = username;
    data['password'] = password;
    data['statut_agent'] = statutAgent;
    data['site_id'] = siteId;
    data['date_enregistrement'] = dateEnregistrement;
    return data;
  }
}
