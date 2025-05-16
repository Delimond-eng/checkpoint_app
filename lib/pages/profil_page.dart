import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/modal.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/modals/request_modal.dart';
import 'package:checkpoint_app/modals/signalement_modal.dart';
import 'package:checkpoint_app/screens/auth/login.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/submenu_button.dart';
import '../widgets/user_status.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "Profil",
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
            DottedBorder(
              color: primaryMaterialColor.shade100,
              radius: const Radius.circular(12.0),
              strokeWidth: 1,
              borderType: BorderType.RRect,
              dashPattern: const [6, 3],
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: blackColor,
                        child: Image.asset(
                          "assets/images/profil-2.png",
                          fit: BoxFit.scaleDown,
                          height: 60.0,
                        ),
                      ).marginOnly(right: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Gaston delimond",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: blackColor,
                                    fontFamily: "Staatliches",
                                    fontSize: 20.0,
                                  ),
                              textAlign: TextAlign.center,
                            ).paddingBottom(5.0),
                            const Text(
                              "034309403" /* authController.userSession.value.matricule! */,
                              textAlign: TextAlign.center,
                            ).paddingBottom(5.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  CupertinoIcons.home,
                                  size: 15.0,
                                ).paddingRight(5.0),
                                Text(
                                  "CARRIERE" /* authController.userSession.value.site!.name! */,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.blue),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ).paddingSymmetric(horizontal: 10.0, vertical: 10.0),
                ),
              ),
            ).marginAll(10.0),
            Column(
              children: [
                SubMenuButton(
                  icon: CupertinoIcons.bubble_left_bubble_right,
                  label: "Signalement",
                  onPressed: () {
                    showSignalementModal(context);
                  },
                ).paddingBottom(10),
                SubMenuButton(
                  icon: CupertinoIcons.captions_bubble,
                  label: "Requête",
                  onPressed: () {
                    showRequestModal(context);
                  },
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
                              builder: (context) => const LoginScreen()),
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
