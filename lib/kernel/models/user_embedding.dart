import 'dart:typed_data';

class UserEmbedding {
  final String userId;
  final List<double> embedding;

  UserEmbedding({required this.userId, required this.embedding});

  /// Crée un UserEmbedding à partir d’une Map issue de la base de données.
  factory UserEmbedding.fromMap(Map<String, dynamic> map) {
    final Uint8List bytes = map['embedding'];
    // Le BLOB stocké est un Float32List sérialisé en Uint8List
    final floatList = bytes.buffer.asFloat32List();
    return UserEmbedding(
      userId: map['userId'],
      embedding: floatList.toList(),
    );
  }

  /// Convertit l’instance en Map pour insertion en base (embedding converti en BLOB)
  Map<String, dynamic> toMap() {
    final bytes = Float32List.fromList(embedding).buffer.asUint8List();
    return {
      'userId': userId,
      'embedding': bytes,
    };
  }
}
