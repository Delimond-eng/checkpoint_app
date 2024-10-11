import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/pages/home_page.dart';
import 'package:checkpoint_app/pages/planning_page.dart';
import 'package:checkpoint_app/pages/profil_page.dart';
import 'package:checkpoint_app/pages/radio_page.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../pages/qrcode_scanner_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  //ALL PAGES
  List<Widget> pages = [
    const HomePage(),
    const PlanningPage(),
    const RadioPage(),
    const ProfilPage()
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.elementAt(currentPage),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRcodeScannerPage(),
            ),
          );
        },
        child: const Icon(CupertinoIcons.qrcode_viewfinder),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Svg(path: "announce_line.svg", size: 23.0),
              activeIcon: Svg(
                path: "announce_line.svg",
                size: 23.0,
                color: primaryColor,
              ),
              label: 'Communiqués',
            ),
            BottomNavigationBarItem(
              icon: Svg(path: "timer-start.svg", size: 23.0),
              activeIcon: Svg(
                path: "timer-start-fill.svg",
                size: 23.0,
                color: primaryColor,
              ),
              label: 'Planning',
            ),
            BottomNavigationBarItem(
              icon: Svg(path: "radio-3-line.svg", size: 23.0),
              activeIcon: Svg(
                path: "radio-3-fill.svg",
                size: 23.0,
                color: primaryColor,
              ),
              label: 'Talkie walkie',
            ),
            BottomNavigationBarItem(
              icon: Svg(path: "user-1.svg", size: 23.0),
              activeIcon: Svg(
                path: "user-1.svg",
                size: 23.0,
                color: primaryColor,
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
      ),
      /* bottomNavigationBar: BottomNavigationBar(
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        backgroundColor: Colors.black,
        elevation: 2.0,
        iconSize: 20.0,
        selectedItemColor: secondaryLightColor,
        showUnselectedLabels: true,
        unselectedItemColor: semiLightColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: secondaryLightColor,
          fontWeight: FontWeight.w600,
          fontSize: 11.0,
        ),
        unselectedFontSize: 11.0,
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          color: Colors.grey[600],
        ),
        items: [
          BottomNavigationBarItem(
            activeIcon: JelloIn(
              child: SvgPicture.asset(
                "assets/icons/nfc-tag.svg",
                height: 22,
                colorFilter: const ColorFilter.mode(
                  secondaryLightColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            icon: SvgPicture.asset(
              "assets/icons/nfc-tag.svg",
              height: 22,
              colorFilter: const ColorFilter.mode(
                semiLightColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Patrouille",
          ),
          BottomNavigationBarItem(
            activeIcon: JelloIn(
              child: SvgPicture.asset(
                "assets/icons/events.svg",
                height: 22.0,
                colorFilter: const ColorFilter.mode(
                  secondaryLightColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            icon: SvgPicture.asset(
              "assets/icons/events.svg",
              height: 22.0,
              colorFilter: const ColorFilter.mode(
                semiLightColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Evénements",
          ),
          BottomNavigationBarItem(
            activeIcon: JelloIn(
              child: SvgPicture.asset(
                "assets/icons/user.svg",
                height: 22.0,
                colorFilter: const ColorFilter.mode(
                  secondaryLightColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            icon: SvgPicture.asset(
              "assets/icons/user.svg",
              height: 22.0,
              colorFilter: const ColorFilter.mode(
                semiLightColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            activeIcon: JelloIn(
              child: SvgPicture.asset(
                "assets/icons/settings.svg",
                height: 22.0,
                colorFilter: const ColorFilter.mode(
                  secondaryLightColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            icon: SvgPicture.asset(
              "assets/icons/settings.svg",
              height: 22.0,
              colorFilter: const ColorFilter.mode(
                semiLightColor,
                BlendMode.srcIn,
              ),
            ),
            label: "Paramètres",
          ),
        ],
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
      ), */
    );
  }
}
