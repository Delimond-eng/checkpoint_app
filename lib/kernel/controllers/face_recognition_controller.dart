import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import '/global/controllers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '/kernel/models/face.dart';
import '/kernel/services/database_helper.dart';
import 'package:http/http.dart' as http;

/// Traitement de l'image dans un Isolate pour ne pas bloquer l'UI
List<List<List<List<double>>>> processImage(Map<String, dynamic> args) {
  try {
    final Uint8List bytes = args['bytes'];
    final int left = args['left'];
    final int top = args['top'];
    final int width = args['width'];
    final int height = args['height'];

    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) return [];

    // Ajouter une marge de 10% pour inclure plus de détails du visage (oreilles, front)
    final int paddingW = (width * 0.1).toInt();
    final int paddingH = (height * 0.1).toInt();
    
    final int safeLeft = (left - paddingW).clamp(0, originalImage.width);
    final int safeTop = (top - paddingH).clamp(0, originalImage.height);
    final int safeWidth = (width + (paddingW * 2)).clamp(1, originalImage.width - safeLeft);
    final int safeHeight = (height + (paddingH * 2)).clamp(1, originalImage.height - safeTop);

    final cropped = img.copyCrop(originalImage, safeLeft, safeTop, safeWidth, safeHeight);
    // Redimensionnement carré exact pour FaceNet (112x112)
    final resized = img.copyResizeCropSquare(cropped, 112);

    return List.generate(
      1,
      (_) => List.generate(
        112,
        (y) => List.generate(
          112,
          (x) {
            final pixel = resized.getPixel(x, y);
            // Normalisation standard FaceNet [-1, 1]
            return [
              (img.getRed(pixel) - 127.5) / 128.0,
              (img.getGreen(pixel) - 127.5) / 128.0,
              (img.getBlue(pixel) - 127.5) / 128.0,
            ];
          },
        ),
      ),
    );
  } catch (e) {
    return [];
  }
}

class FaceRecognitionController extends GetxController {
  static FaceRecognitionController instance = Get.find();
  Interpreter? _interpreter;
  final isModelLoaded = false.obs;
  final isModelInitializing = false.obs;
  
  var isRecognitionLoading = false.obs;
  var faces = Rx<XFile?>(null);
  var faceResult = ''.obs;

  final Map<String, List<double>> _knownFaces = {};

  @override
  void onInit() {
    super.onInit();
    initializeModel();
  }

  Future<void> initializeModel() async {
    if (isModelLoaded.value || isModelInitializing.value) return;
    isModelInitializing.value = true;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/facenet.tflite');
      await reloadTemplates();
      isModelLoaded.value = true;
    } catch (e) {
      debugPrint('Erreur chargement modèle: $e');
    } finally {
      isModelInitializing.value = false;
    }
  }

  Future<void> reloadTemplates() async {
    try {
      await DatabaseHelper().init();
      final storedFaces = await DatabaseHelper().getAllFaces();
      _knownFaces.clear();
      for (final face in storedFaces) {
        _knownFaces[face.matricule] = face.embedding;
      }
    } catch (e) {
      debugPrint('Erreur rechargement templates: $e');
    }
  }

  Future<void> addKnownFaceFromImage(String matricule, XFile image) async {
    final embedding = await getEmbedding(image);
    if (embedding == null) {
      EasyLoading.showError("Visage non détecté");
      return;
    }
    _knownFaces[matricule] = embedding;
    await DatabaseHelper().insertFace(FacePicture(matricule: matricule, embedding: embedding));
  }

  /// Extrait le vecteur (embedding) du visage
  Future<List<double>?> getEmbedding(XFile imageFile) async {
    if (_interpreter == null) return null;

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
      
      final facesDetected = await faceDetector.processImage(inputImage);
      if (facesDetected.isEmpty) {
        await faceDetector.close();
        return null;
      }

      final face = facesDetected.first.boundingBox;
      final bytes = await imageFile.readAsBytes();
      await faceDetector.close();

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

      final List<double> result = List<double>.from(output[0]);
      
      // L2 Normalization (Indispensable pour la comparaison de distance)
      double sum = 0;
      for (var v in result) sum += v * v;
      double norm = sqrt(sum);
      return result.map((e) => e / (norm > 0 ? norm : 1.0)).toList();
    } catch (e) {
      debugPrint("Erreur getEmbedding: $e");
      return null;
    }
  }

  Future<String> recognizeFaceFromImage(XFile? image) async {
    if (image == null) return "Annulé";
    
    final embedding = await getEmbedding(image);
    if (embedding == null) return "Inconnu";

    String? closestMatricule;
    double minDistance = double.infinity;

    for (final entry in _knownFaces.entries) {
      final distance = euclideanDistance(entry.value, embedding);
      if (distance < minDistance) {
        minDistance = distance;
        closestMatricule = entry.key;
      }
    }

    // Seuil de 0.7 pour l'Euclidean L2 (FaceNet)
    if (closestMatricule != null && minDistance < 0.65) {
      return closestMatricule;
    }
    return "Inconnu";
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
