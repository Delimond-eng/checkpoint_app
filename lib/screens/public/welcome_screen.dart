import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/pages/enroll_face_page.dart';
import 'package:checkpoint_app/pages/supervisor_agent.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:checkpoint_app/widgets/user_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../global/store.dart';
import '../../modals/recognition_face_modal.dart' show showRecognitionModal;
import '../../modals/request_modal.dart';
import '../../modals/signalement_modal.dart';
import '../../pages/announce_page.dart';
import '../../pages/mobile_qr_scanner.dart' show MobileQrScannerPage;
import '../../pages/patrol_planning.dart';
import '../../pages/profil_page.dart';
import '../../pages/supervisor_planning.dart';
import '../../pages/supervisor_qrcode_completer.dart';

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
    final isGuard =
        authController.userSession.value.role!.toLowerCase() == 'guard';
    final isSupervisor =
        authController.userSession.value.role!.toLowerCase() == 'supervisor';

    // Liste des boutons
    final List<Widget> menuButtons = [
      HomeMenuBtn(
        icon: "presence",
        title: "Présence",
        onPress: () {
          _showBottonPresenceChoice(context);
        },
      ),
      if (isGuard) ...[
        HomeMenuBtn(
          icon: "qrcode",
          title: "Patrouille",
          onPress: () {
            if (tagsController.patrolId.value != 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileQrScannerPage(),
                ),
              );
            } else {
              EasyLoading.showToast(
                  "Veuillez sélectionner votre planning de patrouille !");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatrolPlanning(),
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
      ] else ...[
        HomeMenuBtn(
          icon: "supervision-3",
          title: "Supervision",
          onPress: () {
            if (authController.pendingSupervisionMap.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupervisorPlanning(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupervisorAgent(),
                ),
              );
            }
          },
        ),
      ],
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
      if (isSupervisor) ...[
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
        ),
        HomeMenuBtn(
          icon: "qrcode",
          title: "Completer zone",
          onPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SupervisorQRCODECompleter(),
              ),
            );
          },
        ),
      ]
    ];
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
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: menuButtons,
                )
              ],
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryMaterialColor.shade500,
          tooltip: "Appuyez longtemps pour déclencher un alèrte !",
          elevation: 10,
          onPressed: () {
            localStorage.remove("patrol_id");
            tagsController.refreshPending();
            /* 
            EasyLoading.showToast("Ce service n'est pas encore disponible !"); */
            //HttpManager().sendData().then((res) => {});
            /* FirebaseService.showLocalNotification("Nouvelle notification Test",
                "Ceci est un nouvelle notification test...");
            FirebaseService.readMessage(
                "Ceci est un nouvelle notification test"); */
            /* Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QRcodeScannerPage(),
              ),
            ); */
            print(authController.pendingSupervisionMap);
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileQrScannerPage(),
                        ),
                      );
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
                      tagsController.isLoading.value = false;
                      Get.back();
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
                      tagsController.isLoading.value = false;
                      Get.back();
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
                EasyLoading.showToast(
                    "Veuillez sélectionner votre planning de patrouille !");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatrolPlanning(),
                  ),
                );
              }
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupervisorQRCODECompleter(),
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
