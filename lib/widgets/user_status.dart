import 'dart:ui';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/global/modal.dart';
import '/global/store.dart';
import '/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserStatus extends StatelessWidget {
  final String name;
  const UserStatus({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final user = authController.userSession.value;

    return PopupMenuButton<int>(
      elevation: 10,
      offset: const Offset(0, 52),
      // Utilisation de shape pour garantir le borderRadius de 20
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: const Color(0xFFF0F0F0),
      surfaceTintColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 28.0,
              width: 28.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryMaterialColor,
                    primaryMaterialColor.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (user!.fullname ?? "U").substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: "Staatliches",
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
      onSelected: (value) {
        if (value == 1) {
          DGCustomDialog.showInteraction(context,
              message: "Etes-vous sûr de vouloir vous déconnecter ?",
              onValidated: () {
            localStorage.remove("user_session");
            Get.offAll(() => const LoginScreen());
            authController.refreshUser();
          });
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          enabled: false,
          child: Container(
            width: 240,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, size: 14, color: primaryColor),
                    ),
                    const SizedBox(width: 8),
                     Text(
                      "PROFIL AGENT CONNECTé".toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                 Divider(color: Colors.grey.shade300, height: 24),
                _buildInfoRow(Icons.person_outline, "Nom", user.fullname ?? "N/A"),
                _buildInfoRow(Icons.badge_outlined, "Matricule", user.matricule ?? "N/A"),
                _buildInfoRow(Icons.location_on_outlined, "Station", user.site?.name ?? "Non définie"),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 1, color: Colors.grey,),
        const PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.power_settings_new_rounded, size: 20, color: Colors.redAccent),
              SizedBox(width: 12),
              Text(
                'DÉCONNEXION',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontFamily: "Ubuntu",
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.black45),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Ubuntu",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
