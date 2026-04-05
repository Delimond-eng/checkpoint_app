class Patrol {
  final int? id;
  final int? scheduleId;
  final int? agentId;
  final int? siteId;
  final String? startedAt;
  final String? endedAt;

  Patrol({this.id, this.scheduleId, this.agentId, this.startedAt, this.endedAt, this.siteId});



  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'agent_id': agentId,
      'site_id': siteId,
      'started_at': startedAt,
      'ended_at': endedAt,
    };
  }

  factory Patrol.fromJson(Map<String, dynamic> json) {
    return Patrol(
        id: json["id"],
        scheduleId: json["schedule_id"],
        agentId: json["agent_id"],
        startedAt: json["started_at"],
        endedAt: json["ended_at"],
        siteId: json["site_id"]
    );
  }

}