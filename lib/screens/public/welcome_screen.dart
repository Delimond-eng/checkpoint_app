import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/pages/tasks_page.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:checkpoint_app/widgets/user_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

import '../../modals/request_modal.dart';
import '../../modals/signalement_modal.dart';
import '../../pages/announce_page.dart';
import '../../pages/patrol_planning.dart';
import '../../pages/profil_page.dart';
import '../../pages/qrcode_scanner_page.dart';
import '../../pages/setting_page.dart';
import '../../themes/colors.dart';
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

  /* Future<void> _initTalkieWalkieService() async {
    await TalkieWalkieService().initListening();
  } */

  /*  //ALL PAGES
  List<Widget> pages = [
    const HomePage(),
    const PlanningPage(),
    const RadioPage(),
    const ProfilPage()
  ];

  int currentPage = 0; */

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
          child: Column(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRcodeScannerPage(),
                        ),
                      );
                    },
                  ),
                  Badge(
                    label: const Text(
                      "0",
                      style: TextStyle(
                        color: lightColor,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: HomeMenuBtn(
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
                  ),
                ],
              ).paddingBottom(15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Badge(
                    label: const Text(
                      "0",
                      style: TextStyle(
                        color: lightColor,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: HomeMenuBtn(
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
                  Badge(
                    label: const Text(
                      "3",
                      style: TextStyle(
                        color: lightColor,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: HomeMenuBtn(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeMenuBtn(
                    icon: "face-2",
                    title: "Enrollement",
                    onPress: () {},
                  ),
                ],
              )
            ],
          ),
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
        )
        /* floatingActionButton: FloatingActionButton(
        backgroundColor: primaryMaterialColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRcodeScannerPage(),
            ),
          );
        },
        child: const Icon(
          CupertinoIcons.qrcode_viewfinder,
          color: lightColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Svg(path: "announce_line.svg", size: 23.0),
              activeIcon: Svg(
                path: "announce_line.svg",
                size: 23.0,
                color: primaryMaterialColor,
              ),
              label: 'Communiqués',
            ),
            BottomNavigationBarItem(
              icon: Svg(path: "timer-start.svg", size: 23.0),
              activeIcon: Svg(
                path: "timer-start-fill.svg",
                size: 23.0,
                color: primaryMaterialColor,
              ),
              label: 'Planning',
            ),
            BottomNavigationBarItem(
              icon: Svg(path: "radio-3-line.svg", size: 23.0),
              activeIcon: Svg(
                path: "radio-3-fill.svg",
                size: 23.0,
                color: primaryMaterialColor,
              ),
              label: 'Talkie walkie',
            ),
            BottomNavigationBarItem(
              icon: Svg(path: "user-1.svg", size: 23.0),
              activeIcon: Svg(
                path: "user-1.svg",
                size: 23.0,
                color: primaryMaterialColor,
              ),
              label: 'Profil',
            ),
          ],
          currentIndex: currentPage,
          onTap: (index) {
            setState(() {
              currentPage = index;
            });
          },
        ),
      ), */
        );
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
                    onPress: () {},
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: CostumButton(
                    title: "Clôturer",
                    bgColor: primaryMaterialColor,
                    labelColor: Colors.white,
                    onPress: () {},
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
                    onPress: () {},
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: CostumButton(
                    title: "Signer mon départ",
                    bgColor: primaryMaterialColor,
                    labelColor: Colors.white,
                    onPress: () {},
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
            _showBottonPatrolChoice(context);
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Patrouille en cours disponible",
                          style: TextStyle(
                            fontFamily: 'Staatliches',
                            color: primaryMaterialColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.0,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          "Veuillez cliquer ici pour clôturer ou poursuivre la patrouille en cours.",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
