import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/pages/home_page.dart';
import 'package:checkpoint_app/pages/stories_page.dart';
import 'package:checkpoint_app/pages/tasks_page.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _selectedPage = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TaskPage(),
    const StoriesPage()
  ];

  @override
  void initState() {
    super.initState();
  }

  void onPageChanged(index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedPage),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onPageChanged,
        currentIndex: _selectedPage,
        selectedLabelStyle: const TextStyle(
          fontFamily: "Staatliches",
          fontWeight: FontWeight.w900,
        ),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: const TextStyle(
          fontFamily: "Staatliches",
        ),
        items: const [
          BottomNavigationBarItem(
            activeIcon: Svg(
              path: "menu-2.svg",
              size: 24.0,
              color: primaryColor,
            ),
            icon: Svg(
              path: "menu-2.svg",
              size: 24.0,
              color: Colors.grey,
            ),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            activeIcon: Svg(
              path: "tasks-2.svg",
              size: 24,
              color: primaryColor,
            ),
            icon: Svg(
              path: "tasks-2.svg",
              size: 24,
              color: Colors.grey,
            ),
            label: "Mes tâches",
          ),
          BottomNavigationBarItem(
            activeIcon: Svg(
              path: "hisory.svg",
              size: 24.0,
              color: primaryColor,
            ),
            icon: Svg(
              path: "history.svg",
              size: 24.0,
              color: Colors.grey,
            ),
            label: "Historique",
          ),
        ],
      ),
    );
  }

  /* void _showBottonPatrolChoice(BuildContext context) {
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
                          builder: (context) => const QRcodeScannerPage(),
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
                    onPress: () async {
                      Navigator.pop(context);
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
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } */
}
