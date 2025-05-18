import 'dart:io';

import 'package:checkpoint_app/kernel/services/recognition_service.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/user_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/styles.dart';
import '../widgets/submit_button.dart';

class EnrollFacePage extends StatefulWidget {
  const EnrollFacePage({super.key});

  @override
  State<EnrollFacePage> createState() => _EnrollFacePageState();
}

class _EnrollFacePageState extends State<EnrollFacePage> {
  final TextEditingController _matriculeController = TextEditingController();

  String result = '';
  bool isLoading = false;

  XFile? pickedImage;

  late FaceRecognitionController _controller;

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
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "Enrôlement visage",
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w900,
            color: whiteColor,
            fontFamily: 'Staatliches',
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          const UserStatus(name: "Gaston delimond").marginAll(8.0),
        ],
      ),
      body: controller.isModelInitializing
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Veuillez enroller le visage de l'agent avec 3 captures. vous devez positionner la caméra sur le visage de l'agent !",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                    ).paddingBottom(15.0),
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        if (isLoading) ...[
                          SizedBox(
                            height: 210.0,
                            width: 210.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 4.0,
                              color: primaryMaterialColor.shade300,
                            ),
                          ),
                        ],
                        DottedBorder(
                          color: primaryMaterialColor.shade500,
                          radius: const Radius.circular(110.0),
                          strokeWidth: 1.2,
                          borderType: BorderType.RRect,
                          dashPattern: const [6, 3],
                          child: CircleAvatar(
                            radius: 100.0,
                            backgroundColor: darkColor,
                            child: pickedImage != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100.0),
                                    ),
                                    child: Image.file(
                                      width: 200.0,
                                      height: 200.0,
                                      File(pickedImage!.path),
                                      alignment: Alignment.center,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Image.asset(
                                      "assets/images/profil-2.png",
                                      height: 50.0,
                                    ),
                                  ),
                          ).marginAll(4.0),
                        )
                      ],
                    ).paddingBottom(15.0),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: primaryMaterialColor.shade100,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: _matriculeController,
                              decoration: const InputDecoration(
                                hintText: "Matricule de l'agent",
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          )
                        ],
                      ).paddingHorizontal(8.0),
                    ).paddingBottom(10.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 55.0,
                      child: SubmitButton(
                        label: "Enroller",
                        loading: isLoading,
                        onPressed: () => enrollWithMultipleCaptures(controller),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> enrollWithMultipleCaptures(
      FaceRecognitionController controller) async {
    final name = _matriculeController.text.trim();
    if (name.isEmpty) {
      EasyLoading.showToast("Entrez le matricule de l'agent !");
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
          EasyLoading.showToast("Erreur de chargement du modèle !");
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
        setState(() {
          pickedImage = validImages.last;
        });
      } else {
        final distance =
            controller.euclideanDistance(referenceEmbedding, embedding);
        if (distance > 1.0) {
          feedback.add(
              "Image ${i + 1} : Visage différent détecté (distance = ${distance.toStringAsFixed(2)}). Enrôlement interrompu.");
          EasyLoading.showToast(
            "Visage différent détecté. Enrôlement interrompu",
          );
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
        EasyLoading.showToast(
          "Aucune image valide pour l'enrôlement.",
        );
      });
      return;
    }

    try {
      await controller.addKnownFaceFromMultipleImages(name, validImages);
      setState(() {
        isLoading = false;
        result =
            "${feedback.join('\n')}\n✅ $name enrôlé avec ${validImages.length} images valides.";
        EasyLoading.showSuccess(
            "Agent matricule $name enrôlé avec ${validImages.length} images valides.");
        _matriculeController.clear();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        result = "${feedback.join('\n')}\n Erreur lors de l'enrôlement : $e";
        EasyLoading.showToast(
          "Erreur lors de l'enrôlement.",
        );
      });
    }
  }
}
