import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/modals/close_patrol_modal.dart';
import 'package:checkpoint_app/pages/enroll_face_page.dart';
import 'package:checkpoint_app/pages/tasks_page.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:checkpoint_app/widgets/user_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../modals/recognition_face_modal.dart' show showRecognitionModal;
import '../../modals/request_modal.dart';
import '../../modals/signalement_modal.dart';
import '../../pages/announce_page.dart';
import '../../pages/mobile_qr_scanner.dart' show MobileQrScannerPage;
import '../../pages/patrol_planning.dart';
import '../../pages/profil_page.dart';
import '../../pages/setting_page.dart';
import '../../pages/supervisor_home.dart';
import '../../widgets/home_menu_btn.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: darkColor,
          title: Row(
            children: [
              Image.asset(
                "assets/images/mamba-2.png",
                height: 35.0,
              ).paddingRight(8.0),
              const Text(
                "SALAMA",
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
          child: Obx(() {
            return Column(
              children: [
                _btnPatrolPending().paddingBottom(20.0).paddingTop(10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HomeMenuBtn(
                      icon: "presence",
                      title: "Présence",
                      onPress: () {
                        _showBottonPresenceChoice(context);
                      },
                    ),
                    HomeMenuBtn(
                      icon: "qrcode",
                      title: "Patrouille",
                      onPress: () {
                        if (authController.userSession.value.role == 'guard') {
                          if (tagsController.patrolId.value != 0) {
                            _showBottonPatrolChoice(context);
                          } else {
                            EasyLoading.showInfo(
                                "Veuillez sélectionner votre planning de patrouille !");
                          }
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupervisorHome(),
                            ),
                          );
                        }
                      },
                    ),
                    HomeMenuBtn(
                      icon: "planning",
                      title: "Planning",
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatrolPlanning(),
                          ),
                        );
                      },
                    ),
                  ],
                ).paddingBottom(15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HomeMenuBtn(
                      icon: "tasks",
                      title: "Tâches",
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaskPage(),
                          ),
                        );
                      },
                    ),
                    HomeMenuBtn(
                      icon: "request-2",
                      title: "Requêtes",
                      onPress: () {
                        showRequestModal(context);
                      },
                    ),
                    HomeMenuBtn(
                      icon: "incident",
                      title: "Signalements",
                      onPress: () {
                        showSignalementModal(context);
                      },
                    ),
                  ],
                ).paddingBottom(15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HomeMenuBtn(
                      icon: "notify",
                      title: "Communiqués",
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnnouncePage(),
                          ),
                        );
                      },
                    ),
                    HomeMenuBtn(
                      icon: "user-1",
                      title: "Profil",
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilPage(),
                          ),
                        );
                      },
                    ),
                    HomeMenuBtn(
                      icon: "settings",
                      title: "Paramètres",
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ).paddingBottom(15.0),
                if (authController.userSession.value.role == 'supervisor') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HomeMenuBtn(
                        icon: "face-2",
                        title: "Enrôlement",
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EnrollFacePage(),
                            ),
                          );
                        },
                      ).paddingRight(15.0),
                      HomeMenuBtn(
                        icon: "qrcode",
                        title: "Completer zone",
                        onPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupervisorHome(),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ]
              ],
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryMaterialColor.shade500,
          tooltip: "Appuyez longtemps pour déclencher un alèrte !",
          elevation: 10,
          onPressed: () {
            /* Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QRcodeScannerPage(),
              ),
            ); */
          },
          child: Image.asset(
            "assets/icons/sirene.png",
            height: 35.0,
          ),
        ));
  }

  void _showBottonPatrolChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: 90.0,
            child: Row(
              children: [
                Expanded(
                  child: CostumButton(
                    bgColor: primaryMaterialColor.shade100,
                    title: "Poursuivre",
                    onPress: () {
                      Get.back();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileQrScannerPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: CostumButton(
                    title: "Clôturer",
                    bgColor: primaryMaterialColor,
                    labelColor: Colors.white,
                    onPress: () {
                      Get.back();
                      showClosePatrolModal(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBottonPresenceChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: 90.0,
            child: Row(
              children: [
                Expanded(
                  child: CostumButton(
                    bgColor: primaryMaterialColor.shade100,
                    title: "Signer mon arrivée",
                    onPress: () {
                      Navigator.pop(context);
                      showRecognitionModal(context);
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: CostumButton(
                    title: "Signer mon départ",
                    bgColor: primaryMaterialColor,
                    labelColor: Colors.white,
                    onPress: () {
                      Navigator.pop(context);
                      showRecognitionModal(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _btnPatrolPending() {
    return DottedBorder(
      color: primaryMaterialColor.shade100,
      radius: const Radius.circular(12.0),
      strokeWidth: 1,
      borderType: BorderType.RRect,
      dashPattern: const [6, 3], // Optionnel, personnalise les pointillés
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          onTap: () {
            if (authController.userSession.value.role == 'guard') {
              if (tagsController.patrolId.value != 0) {
                _showBottonPatrolChoice(context);
              } else {
                EasyLoading.showInfo(
                    "Veuillez sélectionner votre planning de patrouille !");
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupervisorHome(),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: Container(
              // Utilise padding plutôt que margin
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/patrol_illustration.png",
                    height: 80.0,
                  ).paddingRight(8.0),
                  if (authController.userSession.value.role == 'guard') ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tagsController.patrolId.value != 0) ...[
                            const Text(
                              "Patrouille en cours disponible",
                              style: TextStyle(
                                fontFamily: 'Staatliches',
                                color: primaryMaterialColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              "Veuillez cliquer ici pour clôturer ou poursuivre la patrouille en cours.",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 10.0,
                              ),
                            ),
                          ] else ...[
                            Text(
                              "Bienvenue agent ${authController.userSession.value.fullname}",
                              style: const TextStyle(
                                fontFamily: 'Staatliches',
                                color: primaryMaterialColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              "Veuillez cliquer pour commencer une nouvelle patrouille.",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 10.0,
                              ),
                            ),
                          ]
                        ],
                      ),
                    )
                  ] else ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bienvenue Superviseur ${authController.userSession.value.fullname} !",
                            style: const TextStyle(
                              fontFamily: 'Staatliches',
                              color: primaryMaterialColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Text(
                            "Vous pouvez completer les zones de patrouille et aussi enrôler les visages des agents.",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
