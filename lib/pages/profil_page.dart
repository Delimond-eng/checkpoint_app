import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/global/modal.dart';
import '/global/store.dart';
import '/modals/request_modal.dart';
import '/modals/signalement_modal.dart';
import '/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/user_status.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _getRoleLabel(String? role) {
    if (role == null) return "agent".tr.toUpperCase();
    switch (role.toLowerCase()) {
      case 'guard':
        return "guard".tr;
      case 'supervisor':
        return "supervision".tr;
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.userSession.value!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F), 
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B0B0F),
                    Color(0xFF16161E),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const UserStatus(name: ""),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "my_account".tr.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryMaterialColor,
                      fontFamily: 'Staatliches',
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    "agent_profile".tr.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Staatliches',
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryMaterialColor.withOpacity(0.2), width: 3),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          child: ClipOval(
                            child: user.photo != null && user.photo!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: user.photo!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Image.asset(
                                      "assets/images/profil-2.png",
                                      fit: BoxFit.cover,
                                    ),
                                    errorWidget: (context, url, error) => Image.asset(
                                      "assets/images/profil-2.png",
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    "assets/images/profil-2.png",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullname?.toUpperCase() ?? "agent".tr.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16161E),
                                  fontFamily: 'Staatliches',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getRoleLabel(user.role).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "professional_details".tr.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2, fontFamily: 'Ubuntu'),
                  ),
                  const SizedBox(height: 15),

                  _buildInfoTile(Icons.badge_rounded, "matricule".tr, user.matricule ?? "N/A"),
                  _buildInfoTile(Icons.location_on_rounded, "current_station".tr, user.site?.name ?? "N/A"),
                  _buildInfoTile(Icons.business_center_rounded, "agency".tr, "MAMBA SECURITY"),

                  const SizedBox(height: 10),

                  Text(
                    "account_actions".tr.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2, fontFamily: 'Ubuntu'),
                  ),
                  const SizedBox(height: 15),

                  _buildActionTile(
                    icon: Icons.description_rounded,
                    title: "make_request".tr,
                    color: Colors.purple,
                    onTap: () => showRequestModal(context),
                  ),
                  _buildActionTile(
                    icon: Icons.report_problem_rounded,
                    title: "incident_sign".tr,
                    color: Colors.red,
                    onTap: () => showSignalementModal(context),
                  ),
                  _buildActionTile(
                    icon: Icons.logout_rounded,
                    title: "deconnexion".tr,
                    color: Colors.grey.shade700,
                    onTap: () {
                      DGCustomDialog.showInteraction(context,
                          message: "confirm_logout".tr,
                          onValidated: () {
                            localStorage.remove("user_session");
                            Get.offAll(() => const LoginScreen());
                          });
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryMaterialColor.withOpacity(0.7)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontFamily: 'Ubuntu')),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF16161E), fontFamily: 'Ubuntu')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 15),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, fontFamily: 'Ubuntu')),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 20, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
