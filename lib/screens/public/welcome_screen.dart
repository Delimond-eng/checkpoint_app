import 'dart:ui';
import '/constants/styles.dart';
import '/global/controllers.dart';
import '/pages/enroll_face_page.dart';
import '/pages/mobile_qr_scanner_011.dart';
import '/pages/supervisor_agent.dart';
import '/widgets/costum_button.dart';
import '/widgets/user_status.dart';
import '/kernel/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../modals/recognition_face_modal.dart' show showRecognitionModal;
import '../../modals/request_modal.dart';
import '../../modals/signalement_modal.dart';
import '../../pages/announce_page.dart';
import '../../pages/mobile_qr_scanner.dart' show MobileQrScannerPage;
import '../../pages/patrol_planning.dart';
import '../../pages/profil_page.dart';
import '../../pages/supervisor_planning.dart';
import '../../pages/supervisor_qrcode_completer.dart';
import '../../kernel/models/planning.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tagsController.fetchAnnouncesAndPlannings();
      SyncService.instance.start();
    });
  }

  String _formatNextPatrol(Planning? planning) {
    if (planning == null || planning.date == null || planning.startTime == null) {
      return "En attente de nouveau planning...";
    }
    
    try {
      DateTime date;
      if (planning.date!.contains('/')) {
        date = DateFormat('dd/MM/yyyy').parse(planning.date!);
      } else {
        date = DateTime.parse(planning.date!);
      }

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime tomorrow = today.add(const Duration(days: 1));
      final DateTime targetDate = DateTime(date.year, date.month, date.day);

      String timeStr = planning.startTime!.replaceAll(':', 'h');
      
      if (targetDate == today) {
        return "Aujourd'hui à $timeStr";
      } else if (targetDate == tomorrow) {
        return "Demain à $timeStr";
      } else {
        String formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
        return "${formattedDate[0].toUpperCase()}${formattedDate.substring(1)} à $timeStr";
      }
    } catch (e) {
      return "${planning.date} à ${planning.startTime}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.userSession.value;
    final isGuard = user!.role?.toLowerCase() == 'guard';
    final isSupervisor = user.role?.toLowerCase() == 'supervisor';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F), // Dark Header Background
      body: Obx(() {
        // Détection des changements réactifs
        final hasPatrol = tagsController.hasActivePatrol;
        final hasSupervision = authController.pendingSupervision.value != null;

        return Column(
          children: [
            // Dark Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
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
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/mamba-2.png",
                        height: 32.0,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "SALAMA",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Staatliches',
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      const UserStatus(name: ""),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _btnPatrolPending(),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    clipBehavior: Clip.none,
                    children: [
                      _buildHeaderAction(
                        icon: Icons.face_retouching_natural_rounded,
                        label: "Présence",
                        color: Colors.blueAccent,
                        onTap: () => _showBottonPresenceChoice(context),
                      ),
                      _buildHeaderAction(
                        icon: Icons.qr_code_scanner_rounded,
                        label: "RONDE",
                        color: Colors.orangeAccent,
                        enabled: isGuard,
                        badge: hasPatrol ? "!" : null,
                        onTap: () {
                          if (hasPatrol) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MobileQrScannerPage()));
                          } else {
                            EasyLoading.showToast("Veuillez sélectionner votre planning !");
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PatrolPlanning()));
                          }
                        },
                      ),
                      _buildHeaderAction(
                        icon: Icons.event_note_rounded,
                        label: "Planning",
                        color: Colors.tealAccent,
                        enabled: isGuard,
                        // Utilisation directe du .value pour forcer la réactivité du badge
                        badge: tagsController.pendingPlanningCount.value > 0 ? "${tagsController.pendingPlanningCount.value}" : null,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatrolPlanning())),
                      ),
                      _buildHeaderAction(
                        icon: Icons.shield_outlined,
                        label: "Supervision",
                        color: Colors.amberAccent,
                        enabled: isSupervisor,
                        badge: hasSupervision ? "!" : null,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SupervisorAgent()));
                        },
                      ),
                      _buildHeaderAction(
                        icon: Icons.description_rounded,
                        label: "Requêtes",
                        color: Colors.purpleAccent,
                        onTap: () => showRequestModal(context),
                      ),
                      _buildHeaderAction(
                        icon: Icons.report_problem_rounded,
                        label: "Alertes",
                        color: Colors.redAccent,
                        onTap: () => showSignalementModal(context),
                      ),
                      _buildHeaderAction(
                        icon: Icons.notifications_active_rounded,
                        label: "Annonces",
                        color: Colors.yellowAccent,
                        badge: tagsController.announceCount.value > 0 ? "${tagsController.announceCount.value}" : null,
                        badgeColor: Colors.redAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnnouncePage())),
                      ),
                      _buildHeaderAction(
                        icon: Icons.add_location_alt_rounded,
                        label: "Zone +",
                        color: Colors.deepOrangeAccent,
                        enabled: isSupervisor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupervisorQRCODECompleter())),
                      ),
                      _buildHeaderAction(
                        icon: Icons.add_location_rounded,
                        label: "Station +",
                        color: Colors.deepOrangeAccent,
                        enabled: isSupervisor,
                        onTap: () =>Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MobileQrScannerPage011(
                              isStationGps: true,
                            ),
                          ),
                        ),
                      ),
                      _buildHeaderAction(
                        icon: Icons.face_rounded,
                        label: "Visage +",
                        color: Colors.cyanAccent,
                        enabled: isSupervisor,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EnrollFacePage())),
                      ),
                      _buildHeaderAction(
                        icon: Icons.person_rounded,
                        label: "Profil",
                        color: Colors.blueGrey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // White Dashboard Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!isSupervisor)...[
                            const Text(
                              "Tableau de bord",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16161E),
                                fontFamily: 'Ubuntu',
                              ),
                            ),
                            const Spacer(),
                          ]
                          else...[
                            const Expanded(child: Padding(
                              padding: EdgeInsets.only(top: 15, bottom: 5),
                              child: Text(
                                "Cliquez sur le bouton « Superviser les agents », puis scannez le QR code de la station afin de procéder à l’inspection des agents.",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Ubuntu',
                                ),
                              ),
                            )),
                          ],
                          IconButton(
                            onPressed: () async {
                              EasyLoading.show(status: 'Synchronisation...');
                              await tagsController.fetchAnnouncesAndPlannings();
                              await SyncService.instance.syncPendingActions();
                              EasyLoading.showSuccess("Données à jour");
                            },
                            icon: const Icon(Icons.sync_rounded, color: primaryMaterialColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      if (isSupervisor) ...[
                        _btnSuperviseAgents(),
                        const SizedBox(height: 20),
                      ] else ...[
                        const Text(
                          "DÉTAILS OPÉRATIONNELS",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2, fontFamily: 'Ubuntu'),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          Icons.location_on_rounded, 
                          "Site d'affectation", 
                          user.site?.name ?? "Non défini",
                          Colors.blue
                        ),
                        _buildInfoCard(
                          Icons.access_time_filled_rounded, 
                          "Prochaine patrouille", 
                          _formatNextPatrol(tagsController.nextPlanning.value), 
                          Colors.orange
                        ),
                      ],

                      const Text(
                        "POINTAGE DE PRÉSENCE",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2, fontFamily: 'Ubuntu'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPresenceActionRowCard(
                              icon: Icons.login_rounded,
                              title: "Signer l'arrivée",
                              color: Colors.green,
                              onTap: () {
                                tagsController.isLoading.value = false;
                                showRecognitionModal(context, key: "check-in");
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildPresenceActionRowCard(
                              icon: Icons.logout_rounded,
                              title: "Signer le départ",
                              color: primaryColor,
                              onTap: () {
                                tagsController.isLoading.value = false;
                                showRecognitionModal(context, key: "check-out");
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPresenceActionRowCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: 'Staatliches',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAction({required IconData icon, required String label, required Color color, VoidCallback? onTap, String? badge, Color badgeColor = Colors.blueAccent, bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: enabled ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: enabled ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
                ),
                child: Icon(icon, color: enabled ? Colors.white : Colors.white24, size: 22),
              ),
              if (enabled && badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: badgeColor, 
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0B0B0F), width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (!enabled)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Color(0xFF16161E), shape: BoxShape.circle),
                    child: const Icon(Icons.lock_rounded, color: Colors.white38, size: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: enabled ? Colors.white : Colors.white24, fontSize: 9, fontFamily: 'Ubuntu'),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, fontFamily: 'Ubuntu')),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16161E), fontFamily: 'Ubuntu')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnPatrolPending() {
    final hasPatrol = tagsController.hasActivePatrol;
    final user = authController.userSession.value;
    final isGuard = user!.role?.toLowerCase() == 'guard';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isGuard) {
                  if (hasPatrol) {
                    _showBottonPatrolChoice(context);
                  } else {
                    EasyLoading.showToast("Veuillez sélectionner votre planning !");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PatrolPlanning()));
                  }
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SupervisorQRCODECompleter()));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: hasPatrol ? Colors.orangeAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasPatrol ? Icons.shield_rounded : Icons.verified_user_rounded,
                            color: hasPatrol ? Colors.orangeAccent : Colors.greenAccent,
                            size: 30,
                          ),
                        ),
                        if (hasPatrol)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bienvenue, ${user.fullname?.split(' ')[0] ?? 'Agent'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Staatliches',
                              letterSpacing: 1.6
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasPatrol 
                              ? (tagsController.isOfflinePatrolActive.value ? "Patrouille active (Mode Hors-ligne)." : "Une patrouille est en cours d'exécution.")
                              : (isGuard ? "Veuillez consulter votre planning de patrouille." : "Statut disponible pour supervision."),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                              fontFamily: 'Ubuntu',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnSuperviseAgents() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SupervisorAgent()));
          },
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 32),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SUPERVISER LES AGENTS",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Staatliches',
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Cliquez pour scanner une station dans la laquelle vs faite la supervision",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.blueAccent, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottonPatrolChoice(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                const Text("PATROUILLE", style: TextStyle(color: Colors.black87, fontFamily: 'Staatliches', fontSize: 24, letterSpacing: 1.5)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: CostumButton(bgColor: Colors.grey.shade100, title: "Poursuivre", labelColor: Colors.black87, onPress: () { Get.back(); Navigator.push(context, MaterialPageRoute(builder: (context) => const MobileQrScannerPage())); })),
                    const SizedBox(width: 12.0),
                    Expanded(child: CostumButton(title: "Clôturer", bgColor: primaryMaterialColor, labelColor: Colors.white, onPress: () { Get.back(); Navigator.push(context, MaterialPageRoute(builder: (context) => const MobileQrScannerPage())); })),
                  ],
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                const Text(
                  "POINTAGE DE PRÉSENCE",
                  style: TextStyle(color: Colors.black87, fontFamily: 'Staatliches', fontSize: 24, letterSpacing: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CostumButton(
                        bgColor: Colors.grey.shade100,
                        title: "Signer mon arrivée",
                        labelColor: Colors.black87,
                        onPress: () {
                          tagsController.isLoading.value = false;
                          Get.back();
                          showRecognitionModal(context, key: "check-in");
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
                          tagsController.isLoading.value = false;
                          Get.back();
                          showRecognitionModal(context, key: "check-out");
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
