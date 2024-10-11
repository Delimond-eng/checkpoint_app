class Area {
  int? siteId;
  String? libelle;
  int? id;

  Area({
    this.siteId,
    this.libelle,
    this.id,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      siteId: json['site_id'],
      libelle: json['libelle'],
      id: json['id'],
    );
  }
}
