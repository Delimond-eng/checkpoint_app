import 'package:checkpoint_app/global/modal.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/screens/auth/login.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';
import '../widgets/submenu_button.dart';
import '../widgets/user_status.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "Paramètres",
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                SubMenuButton(
                  icon: Icons.history,
                  label: "Historique",
                  onPressed: () {},
                ).paddingBottom(10),
                SubMenuButton(
                  icon: Icons.data_saver_off_rounded,
                  label: "Synchronisations",
                  onPressed: () {},
                ).paddingBottom(10),
                SubMenuButton(
                  icon: Icons.logout,
                  label: "Déconnexion",
                  onPressed: () {
                    DGCustomDialog.showInteraction(context,
                        message:
                            "Etes-vous sûr de vouloir vous déconnecter de votre compte ?",
                        onValidated: () {
                      localStorage.remove("user_session");
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false);
                    });
                  },
                ).paddingBottom(10),
              ],
            ).paddingHorizontal(10.0),
          ],
        ),
      ),
    );
  }
}
