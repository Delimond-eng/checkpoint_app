import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class ImageService {
  /// Compresse une image pour atteindre un poids plume (~10-20 Ko)
  /// Idéal pour les envois serveurs rapides.
  static Future<File> compressForUpload(dynamic imageFile, {int targetWidth = 250}) async {
    File file;
    if (imageFile is XFile) {
      file = File(imageFile.path);
    } else {
      file = imageFile;
    }

    try {
      final bytes = await file.readAsBytes();
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return file;

      // Redimensionnement intelligent (garde le ratio)
      img.Image resized;
      if (decoded.width > decoded.height) {
        resized = img.copyResize(decoded, width: targetWidth);
      } else {
        resized = img.copyResize(decoded, height: targetWidth);
      }

      // Encodage JPG avec compression équilibrée
      final compressedBytes = img.encodeJpg(resized, quality: 60);
      
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/img_${DateTime.now().microsecondsSinceEpoch}.jpg');
      
      return await compressedFile.writeAsBytes(compressedBytes);
    } catch (e) {
      return file; // Retourne l'original en cas d'erreur
    }
  }
}
