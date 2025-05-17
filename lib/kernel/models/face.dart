import 'dart:convert';

class FacePicture {
  final int? id;
  final String name;
  final List<double> embedding;
  final String? imagePath;

  FacePicture(
      {this.id, required this.name, required this.embedding, this.imagePath});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'embedding': jsonEncode(embedding),
        'image_path': imagePath
      };

  static FacePicture fromMap(Map<String, dynamic> map) => FacePicture(
        id: map['id'] as int?,
        name: map['name'] as String,
        embedding: List<double>.from(jsonDecode(map['embedding'])),
        imagePath: map['image_path'] as String?,
      );
}
