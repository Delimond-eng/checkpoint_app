import '/kernel/models/user.dart';

class Planning {
  int? id;
  String? libelle;
  String? date;
  String? startTime;
  String? endTime;
  int? siteId;
  int? agencyId;
  Site? site;

  Planning(
      {this.id,
      this.libelle,
      this.date,
      this.startTime,
      this.endTime,
      this.siteId,
      this.site,
      this.agencyId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'libelle': libelle,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory Planning.fromJson(Map<String, dynamic> json) {
    String? start = json['start_time']?.toString();
    String? end = json['end_time']?.toString();
    
    return Planning(
        id: json['id'],
        date: json['date'],
        libelle: json['libelle'],
        startTime: (start != null && start.length >= 5) ? start.substring(0, 5) : start,
        endTime: (end != null && end.length >= 5) ? end.substring(0, 5) : end,
        siteId: json['site_id'],
        agencyId: json['agency_id'],
        site: json['site'] != null ? Site.fromJson(json['site']) : null);
  }
}
