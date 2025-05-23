import 'dart:io';
import 'dart:math';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/face.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import 'database_helper.dart';

/// Fonction isolée pour prétraiter une image
List<List<List<List<double>>>> processImage(Map<String, dynamic> args) {
  final Uint8List bytes = args['bytes'];
  final int left = args['left'];
  final int top = args['top'];
  final int width = args['width'];
  final int height = args['height'];

  final originalImage = img.decodeImage(bytes);
  if (originalImage == null) return [];

  final cropped = img.copyCrop(originalImage, left, top, width, height);
  final resized = img.copyResizeCropSquare(cropped, 112);

  return [
    List.generate(
      112,
      (y) => List.generate(
        112,
        (x) {
          final pixel = resized.getPixel(x, y);
          return [
            (img.getRed(pixel) - 128) / 128.0,
            (img.getGreen(pixel) - 128) / 128.0,
            (img.getBlue(pixel) - 128) / 128.0,
          ];
        },
      ),
    ),
  ];
}

class FaceRecognitionController extends ChangeNotifier {
  Interpreter? _interpreter;
  bool isModelLoaded = false;
  bool isModelInitializing = false;
  String? modelLoadingError;

  List<FacePicture> faces = [];
  final Map<String, List<double>> _knownFaces = {};

  /// Initialisation du modèle
  Future<void> initializeModel() async {
    if (isModelLoaded || isModelInitializing) return;

    isModelInitializing = true;
    notifyListeners();

    try {
      _interpreter =
          await Interpreter.fromAsset('assets/models/facenet.tflite');
      await DatabaseHelper().init();

      final storedFaces = await DatabaseHelper().getAllFaces();
      faces = storedFaces;
      for (final face in storedFaces) {
        _knownFaces[face.matricule] = face.embedding;
      }

      isModelLoaded = true;
      modelLoadingError = null;
    } catch (e) {
      modelLoadingError = "Erreur de chargement du modèle: $e";
    }

    isModelInitializing = false;
    notifyListeners();
  }

  /// Ajoute un visage à partir de plusieurs images
  Future<void> addKnownFaceFromMultipleImages(
      String matricule, List<XFile> images) async {
    final embeddings = <List<double>>[];

    for (final image in images) {
      final embedding = await getEmbedding(image);
      if (embedding == null) {
        throw Exception("Visage non détecté dans l'image ${image.name}.");
      }
      embeddings.add(embedding);
    }

    final averagedEmbedding = _averageEmbeddings(embeddings);

    _knownFaces[matricule] = averagedEmbedding;
    await DatabaseHelper().insertFace(
      FacePicture(matricule: matricule, embedding: averagedEmbedding),
    );

    notifyListeners();
  }

  /// Moyenne de plusieurs vecteurs d’embedding
  List<double> _averageEmbeddings(List<List<double>> embeddings) {
    final result = List.filled(128, 0.0);

    for (final emb in embeddings) {
      for (int i = 0; i < emb.length; i++) {
        result[i] += emb[i];
      }
    }

    for (int i = 0; i < result.length; i++) {
      result[i] /= embeddings.length;
    }

    return result;
  }

  /// Ajoute des visages à partir d'une API distante
  Future<void> addKnownFacesFromRemoteAPI() async {
    tagsController.isLoading.value = true;
    final agents = await HttpManager.getAllAgents();
    final tempDir = await getTemporaryDirectory();

    for (final item in agents) {
      String? url = item.imagePath;

      final matricule = item.matricule;

      url = url!.replaceAll("127.0.0.1", "192.168.4.4");
      try {
        final imageResponse = await http.get(Uri.parse(url));
        if (imageResponse.statusCode != 200) continue;

        final path = "${tempDir.path}/$matricule.jpg";
        final file = File(path)..writeAsBytesSync(imageResponse.bodyBytes);
        final xfile = XFile(file.path);
        final embedding = await getEmbedding(xfile);
        if (embedding == null) {
          if (kDebugMode) print("Visage non détecté pour $matricule");
          continue;
        }
        _knownFaces[matricule!] = embedding;
        await DatabaseHelper().insertFace(
          FacePicture(matricule: matricule, embedding: embedding),
        );
      } catch (e) {
        if (kDebugMode) print("Erreur de traitement pour $matricule: $e");
      } finally {
        tagsController.isLoading.value = false;
      }
    }
  }

  /// Normalisation d’un vecteur
  List<double>? _normalize(List<double> input) {
    final norm = sqrt(input.fold(0, (sum, val) => sum + val * val));
    return (norm == 0) ? null : input.map((e) => e / norm).toList();
  }

  /// Génère l'embedding à partir d’un fichier image
  Future<List<double>?> getEmbedding(XFile imageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );

    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) return null;

    final face = faces.first.boundingBox;
    final bytes = await imageFile.readAsBytes();

    final input = await compute(processImage, {
      'bytes': bytes,
      'left': face.left.toInt(),
      'top': face.top.toInt(),
      'width': face.width.toInt(),
      'height': face.height.toInt(),
    });

    if (input.isEmpty) return null;

    final output = List.filled(128, 0.0).reshape([1, 128]);
    _interpreter?.run(input, output);

    return _normalize(List<double>.from(output[0]));
  }

  /// Reconnaît un visage à partir d'une image capturée
  Future<String> recognizeFaceFromImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image == null) return "Opération annulée par l'utilisateur";

    tagsController.face.value = image;
    final embedding = await getEmbedding(image);

    if (embedding == null) return "Inconnu";

    String? closestName;
    double minDistance = double.infinity;

    print("#############Faces : ${_knownFaces.length}");

    for (final entry in _knownFaces.entries) {
      final distance = euclideanDistance(entry.value, embedding);
      if (distance < minDistance) {
        minDistance = distance;
        closestName = entry.key;
      }
    }

    return (minDistance < 1.0) ? closestName! : "Inconnu";
  }

  /// Calcule la distance euclidienne entre deux vecteurs
  double euclideanDistance(List<double> e1, List<double> e2) {
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      final diff = e1[i] - e2[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }
}
