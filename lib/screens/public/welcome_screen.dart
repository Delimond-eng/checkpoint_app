import 'package:animate_do/animate_do.dart';
import 'package:checkpoint_app/themes/colors.dart';
import 'package:flutter_svg/svg.dart';

import '/pages/home_page.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  //ALL PAGES
  List<Widget> pages = [
    const HomePage(),
    const Center(
      child: Text("Events"),
    ),
    const Center(
      child: Text("User"),
    ),
    const Center(
      child: Text("Config"),
    )
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages.elementAt(currentPage),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}
