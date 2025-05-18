import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/modal.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class UserStatus extends StatelessWidget {
  final String name;
  const UserStatus({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      elevation: 1,
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.white,
      child: Obx(
        () => Container(
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 35.0,
                      width: 35.0,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      child: Center(
                        child: Text(
                          authController.userSession.value.fullname!
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      onSelected: (value) {
        // Gère les actions ici
        if (value == 1) {
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
            authController.refreshUser();
          });
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 8, 2),
                child: Icon(
                  Icons.lock_outlined,
                  size: 15,
                  color: primaryMaterialColor,
                ),
              ),
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
