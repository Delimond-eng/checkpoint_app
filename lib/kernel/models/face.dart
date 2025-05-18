import 'dart:convert';

class FacePicture {
  final int? id;
  final String matricule;
  final List<double> embedding;
  final String? imagePath;

  FacePicture(
      {this.id,
      required this.matricule,
      required this.embedding,
      this.imagePath});

  Map<String, dynamic> toMap() => {
        'id': id,
        'matricule': matricule,
        'embedding': jsonEncode(embedding),
        'image_path': imagePath
      };

  static FacePicture fromMap(Map<String, dynamic> map) => FacePicture(
        id: map['id'] as int?,
        matricule: map['matricule'] as String,
        embedding: List<double>.from(jsonDecode(map['embedding'])),
        imagePath: map['image_path'] as String?,
      );
}
