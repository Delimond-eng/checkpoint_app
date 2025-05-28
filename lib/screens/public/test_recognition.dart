/* import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key});

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  final TextEditingController _nameController = TextEditingController();

  String result = '';
  bool isLoading = false;

  /* late FaceRecognitionController _controller; */

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller =
        Provider.of<FaceRecognitionController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.isModelInitializing && !_controller.isModelLoaded) {
        _controller.initializeModel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FaceRecognitionController>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Reconnaissance faciale")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: controller.isModelInitializing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.modelLoadingError != null)
                    Text(controller.modelLoadingError!,
                        style: const TextStyle(color: Colors.red)),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du visage à enregistrer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text("Enrôler avec plusieurs images"),
                    onPressed: () => enrollWithMultipleCaptures(controller),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera),
                    label: const Text("🔍 Reconnaître depuis la caméra"),
                    onPressed: () => recognize(controller, ImageSource.camera),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text("🔍 Reconnaître depuis la galerie"),
                    onPressed: () => recognize(controller, ImageSource.gallery),
                  ),
                  const SizedBox(height: 20),
                  if (isLoading) const CircularProgressIndicator(),
                  if (result.isNotEmpty)
                    Text(result,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Future<void> enrollWithMultipleCaptures(
      FaceRecognitionController controller) async {
    /*  final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => result = "Entrez un nom pour enregistrer.");
      return;
    }

    final picker = ImagePicker();
    List<XFile> validImages = [];
    List<String> feedback = [];

    setState(() {
      isLoading = true;
      result = "Capture en cours...";
    });

    // Assure que le modèle est chargé
    if (!controller.isModelLoaded) {
      try {
        await controller.initializeModel();
      } catch (e) {
        setState(() {
          isLoading = false;
          result = "Erreur de chargement du modèle : $e";
        });
        return;
      }
    }

    List<double>? referenceEmbedding;

    for (int i = 0; i < 3; i++) {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        feedback.add("Capture ${i + 1} : annulée.");
        break;
      }

      final embedding = await controller.getEmbedding(image);
      if (embedding == null) {
        feedback.add(
            "Image ${i + 1} : Aucun visage détecté. Enrôlement interrompu.");
        break;
      }

      if (referenceEmbedding == null) {
        // Première image : on fixe la référence
        referenceEmbedding = embedding;
        feedback.add("Image ${i + 1} : Visage détecté (référence)");
        validImages.add(image);
      } else {
        final distance =
            controller.euclideanDistance(referenceEmbedding, embedding);
        if (distance > 1.0) {
          feedback.add(
              "Image ${i + 1} :Visage différent détecté (distance = ${distance.toStringAsFixed(2)}). Enrôlement interrompu.");
          break;
        } else {
          feedback.add(
              "Image ${i + 1} :Visage cohérent (distance = ${distance.toStringAsFixed(2)})");
          validImages.add(image);
        }
      }
    }

    if (validImages.isEmpty) {
      setState(() {
        isLoading = false;
        result =
            "${feedback.join('\n')}\n Aucune image valide pour l'enrôlement.";
      });
      return;
    }

    try {
      await controller.addKnownFaceFromMultipleImages(name, validImages);
      setState(() {
        isLoading = false;
        result =
            "${feedback.join('\n')}\n✅ $name enrôlé avec ${validImages.length} images valides.";
        _nameController.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        result = "${feedback.join('\n')}\n Erreur lors de l'enrôlement : $e";
      });
    } */
  }

  /*  Future<void> recognize(
      FaceRecognitionController controller, ImageSource source) async {
    setState(() {
      isLoading = true;
      result = "Reconnaissance en cours...";
    });

    final output = await controller.recognizeFaceFromImage(source);

    setState(() {
      isLoading = false;
      result = "Résultat : $output";
    });
  } */
}
 */
