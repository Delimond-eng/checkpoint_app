class ScanningResult {
  int? agentId;
  int? areaId;
  String? comment;
  String? latlng;
  String? distance;
  int? patrolId;
  int? id;

  ScanningResult(
      {this.agentId,
      this.areaId,
      this.comment,
      this.latlng,
      this.distance,
      this.patrolId,
      this.id});

  ScanningResult.fromJson(Map<String, dynamic> json) {
    agentId = json['agent_id'];
    areaId = json['area_id'];
    comment = json['comment'];
    latlng = json['latlng'];
    distance = json['distance'];
    patrolId = json['patrol_id'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['agent_id'] = agentId;
    data['area_id'] = areaId;
    data['comment'] = comment;
    data['latlng'] = latlng;
    data['distance'] = distance;
    data['patrol_id'] = patrolId;
    data['id'] = id;
    return data;
  }
}
