import 'package:checkpoint_app/kernel/models/user.dart';

class Planning {
  int? id;
  String? libelle;
  String? startTime;
  String? endTime;
  int? siteId;
  int? agencyId;
  Site? site;

  Planning(
      {this.id,
      this.libelle,
      this.startTime,
      this.endTime,
      this.siteId,
      this.site,
      this.agencyId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'libelle': libelle,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory Planning.fromJson(Map<String, dynamic> json) {
    return Planning(
        id: json['id'],
        libelle: json['libelle'],
        startTime: json['start_time'].toString().substring(0, 5),
        endTime: json['end_time'].toString().substring(0, 5),
        siteId: json['site_id'],
        agencyId: json['agency_id'],
        site: Site.fromJson(json['site']));
  }
}
