import 'package:animate_do/animate_do.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:checkpoint_app/widgets/user_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/styles.dart';
import '../global/controllers.dart';
import '../kernel/services/recognition_service.dart';
import '../modals/activities_modal.dart';
import '../modals/recognition_face_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FaceRecognitionController _controller;

  List<String> activites = [
    "Étude du site et évaluation des besoins en vidéosurveillance",
    "Installation des caméras et câblage (coaxial, RJ45, fibre optique)",
    "Fixation des supports et orientation des caméras",
    "Configuration du DVR/NVR",
    "Maintenance préventive (nettoyage des caméras, test des connexions)",
    "Maintenance corrective (remplacement des câbles ou caméras défectueuses)",
    "Mise à jour logicielle du système (DVR/NVR ou application)",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller =
        Provider.of<FaceRecognitionController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.isModelInitializing && !_controller.isModelLoaded) {
        _controller.initializeModel();
        /* if (_controller.faces.isEmpty) {
          _controller.addKnownFacesFromRemoteAPI();
        } */
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 40.0,
            ).paddingRight(5.0),
            const Text(
              "Accueil",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w900,
                color: whiteColor,
                fontFamily: 'Staatliches',
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          const UserStatus(name: "Gaston delimond").marginAll(8.0),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _welcome(),
            for (int i = 0; i < activites.length; i++) ...[
              FadeInUp(
                child: DottedBorder(
                  color: greyColor5,
                  radius: const Radius.circular(12.0),
                  strokeWidth: 1,
                  borderType: BorderType.RRect,
                  dashPattern: const [6, 3],
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Container(
                      color: whiteColor,
                      child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            tagsController.isRecognitionLoading.value = true;
                            tagsController.face.value = null;
                            tagsController.faceResult.value = "";
                            showRecognitionModal(context);
                            tagsController.recognize(
                                _controller, ImageSource.camera);
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Svg(
                                  path: "timer-start.svg",
                                  color: primaryColor,
                                ).paddingRight(5.0),
                                Expanded(
                                  child: Text(
                                    activites[i],
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: darkColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).marginOnly(bottom: 5.0),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _welcome() {
    return FadeInUp(
      child: DottedBorder(
        color: primaryColor.withOpacity(.5),
        radius: const Radius.circular(12.0),
        strokeWidth: 1,
        borderType: BorderType.RRect,
        dashPattern: const [6, 3], // Optionnel, personnalise les pointillés
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            // Utilise padding plutôt que margin
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/task-illustration-1.png",
                  height: 80.0,
                ).paddingRight(8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bienvenue Gaston delimond",
                        style: TextStyle(
                          fontFamily: 'Staatliches',
                          color: secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "Veuillez sélectionner une activité que vous voulez lancer.",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 10.0,
                          color: primaryMaterialColor.shade400,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ).paddingBottom(20.0),
    );
  }

  Widget closeActivityMessage() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Commencez une nouvelle activité !",
              style: TextStyle(
                fontFamily: 'Staatliches',
                color: secondaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 22.0,
              ),
            ).paddingBottom(15.0),
            DottedBorder(
              color: secondaryColor.withOpacity(.5),
              radius: const Radius.circular(15.0),
              strokeWidth: 1,
              borderType: BorderType.RRect,
              dashPattern: const [6, 3],
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                child: Container(
                  height: 150.0,
                  width: 150.0,
                  color: whiteColor,
                  child: Material(
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0)),
                      onTap: () {
                        showActivitiesModal(context, _controller);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Svg(
                            path: "timer-start.svg",
                            color: primaryColor,
                            size: 40.0,
                          ).paddingBottom(10.0),
                          const Text(
                            "Lancer une activité",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                              color: secondaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
