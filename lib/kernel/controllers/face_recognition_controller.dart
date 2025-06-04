import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '/kernel/models/face.dart';
import '/kernel/services/database_helper.dart';

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

class FaceRecognitionController extends GetxController {
  static FaceRecognitionController instance = Get.find();
  Interpreter? _interpreter;
  final isModelLoaded = false.obs;
  final isModelInitializing = false.obs;
  final modelLoadingError = RxnString();

  var isRecognitionLoading = false.obs;
  var faces = Rx<XFile?>(null);
  var faceResult = ''.obs;
  var recognitionKey = ''.obs;

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
      _interpreter =
          await Interpreter.fromAsset('assets/models/facenet.tflite');
      await DatabaseHelper().init();

      final storedFaces = await DatabaseHelper().getAllFaces();
      for (final face in storedFaces) {
        _knownFaces[face.matricule] = face.embedding;
      }
      isModelLoaded.value = true;
      modelLoadingError.value = null;
    } catch (e) {
      modelLoadingError.value = 'Erreur de chargement du modèle: $e';
    } finally {
      isModelInitializing.value = false;
    }
  }

  //Add unknow face
  Future<void> addKnownFaceFromImage(String matricule, XFile image) async {
    final embedding = await getEmbedding(image);
    if (embedding == null) {
      EasyLoading.showInfo(
          "Visage non détecté dans l'image ${image.name}. Enrôlement interrompu.");
      throw Exception(
          "Visage non détecté dans l'image ${image.name}. Enrôlement interrompu.");
    }

    _knownFaces[matricule] = embedding;

    await DatabaseHelper().insertFace(
      FacePicture(matricule: matricule, embedding: embedding),
    );
  }

  Future<void> recognize(XFile? image) async {
    isRecognitionLoading.value = true;
    try {
      if (image == null) {
        faceResult.value = "Annulé";
        return;
      }

      faces.value = image;
      final result = await recognizeFaceFromImage(image);

      faceResult.value = result;
    } catch (e) {
      faceResult.value = "Erreur : $e";
    } finally {
      isRecognitionLoading.value = false;
    }
  }

  /// Normalisation de l'empreinte
  List<double>? _normalize(List<double> input) {
    final norm = sqrt(input.fold(0, (sum, val) => sum + val * val));
    if (norm == 0) return null;
    return input.map((e) => e / norm).toList();
  }

  /// Récupération de l'empreinte faciale à partir de l'image
  Future<List<double>?> getEmbedding(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faceDetector = FaceDetector(
        options:
            FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
      );

      final faces = await faceDetector.processImage(inputImage);
      if (faces.isEmpty) return null;

      final face = faces.first.boundingBox;
      final bytes = await imageFile.readAsBytes();

      // Traitement dans un isolate (compute)
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
    } catch (e) {
      if (kDebugMode) print("Erreur dans getEmbedding : $e");
      return null;
    }
  }

  /// Reconnaissance faciale à partir d'une image
  Future<dynamic> recognizeFaceFromImage(XFile? image) async {
    try {
      if (image == null) {
        EasyLoading.showInfo("Opération annulée par l'utilisateur");
        return null;
      }

      final embedding = await getEmbedding(image);
      if (embedding == null) {
        EasyLoading.showInfo("Impossible d'obtenir l'empreinte du visage");
        return null;
      }

      String? closestName;
      double minDistance = double.infinity;

      for (final entry in _knownFaces.entries) {
        final distance = euclideanDistance(entry.value, embedding);
        if (distance < minDistance) {
          minDistance = distance;
          closestName = entry.key;
        }
      }
      return (minDistance < 0.7) ? closestName! : "Inconnu";
    } catch (e) {
      return null;
    }
  }

  /// Distance Euclidienne
  double euclideanDistance(List<double> e1, List<double> e2) {
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      final diff = e1[i] - e2[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }
}
