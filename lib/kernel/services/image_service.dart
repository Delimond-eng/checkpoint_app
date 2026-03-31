import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class ImageService {
  /// Compresse une image pour atteindre un poids plume (~10-20 Ko)
  /// Idéal pour les envois serveurs rapides.
  static Future<File> compressForUpload(dynamic imageFile, {int targetWidth = 300}) async {
    File file = imageFile is XFile ? File(imageFile.path) : imageFile;

    try {
      final bytes = await file.readAsBytes();
      
      // Décodage de l'image
      img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return file;

      // 1. Redressement automatique via les tags EXIF
      decoded = img.bakeOrientation(decoded);

      // 2. Correction manuelle pour Android : 
      // Si l'image est toujours en paysage (largeur > hauteur), on force une rotation portrait.
      // C'est un correctif classique pour les capteurs mobiles qui ne tagguent pas bien l'EXIF.
      if (decoded.width > decoded.height) {
        decoded = img.copyRotate(decoded, 90);
      }

      // 3. Redimensionnement proportionnel (fixe la largeur)
      img.Image resized = img.copyResize(decoded, width: targetWidth);

      // Encodage final en JPG
      final compressedBytes = img.encodeJpg(resized, quality: 75);
      
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      return await compressedFile.writeAsBytes(compressedBytes);
    } catch (e) {
      return file; 
    }
  }
}
