import 'dart:math';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/face.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import 'database_helper.dart';

/// Fonction exécutée en arrière-plan pour préparer l'image
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

  final input = List.generate(
    1,
    (_) => List.generate(
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
  );

  return input;
}

class FaceRecognitionController extends ChangeNotifier {
  Interpreter? _interpreter;
  bool isModelLoaded = false;
  bool isModelInitializing = false;
  String? modelLoadingError;
  final Map<String, List<double>> _knownFaces = {};

  /// Charge le modèle
  Future<void> initializeModel() async {
    if (isModelLoaded || isModelInitializing) return;
    isModelInitializing = true;
    notifyListeners();

    try {
      _interpreter =
          await Interpreter.fromAsset('assets/models/facenet.tflite');
      await DatabaseHelper().init();
      final storedFaces = await DatabaseHelper().getAllFaces();

      if (kDebugMode) {
        print("faces ${storedFaces.length}");
      }
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

  Future<void> addKnownFaceFromMultipleImages(
      String matricule, List<XFile> images) async {
    List<List<double>> embeddings = [];

    for (XFile image in images) {
      final embedding = await getEmbedding(image);
      if (embedding == null) {
        throw Exception(
            "Visage non détecté dans l'image ${image.name}. Enrôlement interrompu.");
      }
      embeddings.add(embedding);
    }

    final averagedEmbedding = List<double>.filled(128, 0);
    for (final emb in embeddings) {
      for (int i = 0; i < emb.length; i++) {
        averagedEmbedding[i] += emb[i];
      }
    }
    for (int i = 0; i < averagedEmbedding.length; i++) {
      averagedEmbedding[i] /= embeddings.length;
    }

    _knownFaces[matricule] = averagedEmbedding;
    await DatabaseHelper().insertFace(
      FacePicture(matricule: matricule, embedding: averagedEmbedding),
    );

    notifyListeners();
  }

  List<double>? _normalize(List<double> input) {
    final norm = sqrt(input.fold(0, (sum, val) => sum + val * val));
    if (norm == 0) return null;
    return input.map((e) => e / norm).toList();
  }

  Future<List<double>?> getEmbedding(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );
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
    _interpreter!.run(input, output);

    return _normalize(List<double>.from(output[0]));
  }

  Future<String> recognizeFaceFromImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image == null) return "Opération annulée par l'utilisateur";
    tagsController.face.value = image;
    final embedding = await getEmbedding(image);
    if (embedding == null) return "Impossible d'obtenir l'empreinte";

    String? closestName;
    double minDistance = double.infinity;

    for (final entry in _knownFaces.entries) {
      final distance = euclideanDistance(entry.value, embedding);
      if (distance < minDistance) {
        minDistance = distance;
        closestName = entry.key;
      }
    }

    return (minDistance < 1.0) ? closestName! : "Inconnu";
  }

  double euclideanDistance(List<double> e1, List<double> e2) {
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      final diff = e1[i] - e2[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }
}
