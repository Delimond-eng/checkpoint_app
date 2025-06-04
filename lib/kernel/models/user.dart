class User {
  int? id;
  String? matricule;
  String? fullname;
  String? password;
  int? agencyId;
  int? siteId;
  String? status;
  String? role;
  String? photo;
  Site? site;

  User(
      {this.id,
      this.matricule,
      this.fullname,
      this.password,
      this.agencyId,
      this.siteId,
      this.status,
      this.role,
      this.site,
      this.photo});

  // Factory method to create an instance of Agent from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      matricule: json['matricule'],
      fullname: json['fullname'],
      photo: json['photo'].toString().replaceAll("127.0.0.1", "192.168.4.47"),
      password: json['password'],
      agencyId: json['agency_id'],
      siteId: json['site_id'],
      status: json['status'],
      role: json['role'],
      site: json['site'] != null ? Site.fromJson(json['site']) : Site(),
    );
  }

  // Method to convert Agent object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricule': matricule,
      'fullname': fullname,
      'photo': photo,
      'password': password,
      'agency_id': agencyId,
      'site_id': siteId,
      'status': status,
      'role': role,
      'site': site!.toJson(),
    };
  }
}

class Site {
  int? id;
  String? name;
  String? code;
  String? adresse;
  String? latlng;
  String? phone;
  int? agencyId;
  String? status;

  Site({
    this.id,
    this.name,
    this.code,
    this.adresse,
    this.latlng,
    this.phone,
    this.agencyId,
    this.status,
  });

  // Factory method to create an instance of Site from JSON
  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      adresse: json['adresse'],
      latlng: json['latlng'],
      phone: json['phone'],
      agencyId: json['agency_id'],
      status: json['status'],
    );
  }

  // Method to convert Site object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'adresse': adresse,
      'latlng': latlng,
      'phone': phone,
      'agency_id': agencyId,
      'status': status,
    };
  }
}
