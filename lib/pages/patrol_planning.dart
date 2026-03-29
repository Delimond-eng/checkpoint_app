import 'dart:ui';
import '/global/controllers.dart';
import '/kernel/services/http_manager.dart';
import '/kernel/services/local_db_service.dart';
import '/pages/mobile_qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../constants/styles.dart';
import '../kernel/models/planning.dart';
import '../widgets/user_status.dart';

class PatrolPlanning extends StatefulWidget {
  const PatrolPlanning({super.key});

  @override
  State<PatrolPlanning> createState() => _PatrolPlanningState();
}

class _PatrolPlanningState extends State<PatrolPlanning> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    // On lance la mise à jour serveur de manière silencieuse
    tagsController.fetchAnnouncesAndPlannings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B0B0F), Color(0xFF16161E)],
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
                const SizedBox(height: 25),
                const Text(
                  "PLANNING",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryMaterialColor, fontFamily: 'Staatliches', letterSpacing: 2),
                ),
                const Text(
                  "MES PATROUILLES",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Staatliches'),
                ),
                const SizedBox(height: 10),
                Text(
                  "Consultez et débutez vos missions planifiées.",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Ubuntu'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                child: Obx(() {
                  final list = tagsController.plannings;
                  
                  if (list.isEmpty) {
                    return _buildEmptyState();
                  }

                  final groupedPlannings = _groupPlanningsByDate(list);
                  final dates = groupedPlannings.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final dateStr = dates[index];
                      final dayPlannings = groupedPlannings[dateStr]!;
                      return _buildDateGroup(dateStr, dayPlannings);
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Planning>> _groupPlanningsByDate(List<Planning> plannings) {
    Map<String, List<Planning>> grouped = {};
    for (var p in plannings) {
      if (p.date != null) {
        if (!grouped.containsKey(p.date)) grouped[p.date!] = [];
        grouped[p.date!]!.add(p);
      }
    }
    return grouped;
  }

  bool _isPastDate(String dateStr) {
    try {
      DateTime date;
      if (dateStr.contains('/')) {
        date = DateFormat('dd/MM/yyyy').parse(dateStr);
      } else {
        date = DateTime.parse(dateStr);
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return date.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  String _humanizeDate(String dateStr) {
    try {
      DateTime date;
      if (dateStr.contains('/')) {
        date = DateFormat('dd/MM/yyyy').parse(dateStr);
      } else {
        date = DateTime.parse(dateStr);
      }
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime tomorrow = today.add(const Duration(days: 1));
      final DateTime targetDate = DateTime(date.year, date.month, date.day);

      if (targetDate == today) return "Aujourd'hui";
      if (targetDate == yesterday) return "Hier";
      if (targetDate == tomorrow) return "Demain";

      String formatted = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildDateGroup(String dateStr, List<Planning> plannings) {
    final isPast = _isPastDate(dateStr);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPast ? Colors.grey.withOpacity(0.1) : primaryMaterialColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _humanizeDate(dateStr),
                style: TextStyle(
                  color: isPast ? Colors.grey : primaryMaterialColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Divider(color: Colors.grey.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 15),
        ...plannings.asMap().entries.map((entry) {
          return _buildTimelineItem(entry.value, entry.key == plannings.length - 1, isPast);
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTimelineItem(Planning planning, bool isLast, bool isPast) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isPast ? Colors.grey.shade300 : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isPast ? Colors.grey : primaryMaterialColor, width: 2),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.withOpacity(0.2))),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Opacity(
              opacity: isPast ? 0.6 : 1.0,
              child: GestureDetector(
                onTap: isPast ? null : () => _confirmStartPatrol(planning),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: isPast ? Colors.grey : primaryMaterialColor),
                              const SizedBox(width: 6),
                              Text(
                                "${planning.startTime} - ${planning.endTime}",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Ubuntu', color: isPast ? Colors.grey : const Color(0xFF16161E)),
                              ),
                            ],
                          ),
                          if (isPast)
                            const Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey)
                          else
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        planning.libelle ?? "Mission sans libellé",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isPast ? Colors.grey : const Color(0xFF16161E), fontFamily: 'Ubuntu'),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            planning.site?.name ?? "Site non défini",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontFamily: 'Ubuntu'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStartPatrol(Planning planning) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const Text("DÉBUTER LA RONDE ?", style: TextStyle(fontFamily: 'Staatliches', fontSize: 22, letterSpacing: 1.5)),
              const SizedBox(height: 15),
              Text("Voulez-vous commencer la ronde pour : ${planning.libelle} ?", textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Ubuntu', fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Get.back(), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text("ANNULER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        tagsController.planningId.value = planning.id.toString();
                        Get.back(); Get.back();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MobileQrScannerPage()));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryMaterialColor, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text("DÉMARRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text("Aucun planning disponible", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Ubuntu')),
        ],
      ),
    );
  }
}
