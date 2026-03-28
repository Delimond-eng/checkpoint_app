class Supervision {
  int? siteId;
  int? supervisorId;
  String? latlng;
  String? startedAt;
  String? generalComment;
  int? id;

  Supervision({
    this.siteId,
    this.supervisorId,
    this.latlng,
    this.startedAt,
    this.generalComment,
    this.id,
  });

  Supervision.fromJson(Map<String, dynamic> json) {
    siteId = int.parse(json['site_id']);
    supervisorId = json['supervisor_id'];
    latlng = json['latlng'];
    startedAt = json['started_at'];
    generalComment = json['general_comment'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['site_id'] = siteId;
    data['supervisor_id'] = supervisorId;
    data['latlng'] = latlng;
    data['started_at'] = startedAt;
    data['general_comment'] = generalComment;
    data['id'] = id;
    return data;
  }
}
