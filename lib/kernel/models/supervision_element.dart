class SupElement {
  final int id;
  final String libelle;
  final String description;
  final int active;

  SupElement({
    required this.id,
    required this.libelle,
    required this.description,
    required this.active,
  });

  factory SupElement.fromJson(Map<String, dynamic> json) {
    return SupElement(
      id: json['id'],
      libelle: json['libelle'],
      description: json['description'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'description': description,
      'active': active,
    };
  }
}
