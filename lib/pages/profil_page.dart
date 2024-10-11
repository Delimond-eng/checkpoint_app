import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/modal.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/modals/request_modal.dart';
import 'package:checkpoint_app/modals/signalement_modal.dart';
import 'package:checkpoint_app/screens/auth/login.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 25.0,
            ).paddingRight(5),
            Text("Mon profil".toUpperCase()),
          ],
        ),
        actions: [
          Obx(
            () => CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                authController.userSession.value.fullname!.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ).marginAll(8.0),
          )
        ],
      ),
      body: Obx(
        () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.blue,
                    child: Image.asset(
                      "assets/images/profil-2.png",
                      fit: BoxFit.scaleDown,
                      height: 60.0,
                    ),
                  ).paddingRight(10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authController.userSession.value.fullname!
                            .toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                              fontSize: 20.0,
                            ),
                        textAlign: TextAlign.center,
                      ).paddingBottom(5.0),
                      Text(
                        authController.userSession.value.matricule!,
                        textAlign: TextAlign.center,
                      ).paddingBottom(5.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.home,
                            size: 15.0,
                          ).paddingRight(5.0),
                          Text(
                            authController.userSession.value.site!.name!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Colors.blue),
                          )
                        ],
                      ).paddingBottom(10.0),
                    ],
                  )
                ],
              ).paddingBottom(20.0).paddingHorizontal(30.0),
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
      ),
    );
  }
}

class SubMenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  const SubMenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Card(
        margin: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 18.0,
                      ).paddingRight(8.0),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 17.0,
                    color: greyColor,
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
