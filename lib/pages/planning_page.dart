import '/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/styles.dart';
import '../global/controllers.dart';
import '../kernel/models/planning.dart';
import '../kernel/services/http_manager.dart';
import '../widgets/svg.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
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
            Text("Planning de patrouille".toUpperCase()),
          ],
        ),
        actions: [
          Obx(
            () => CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 30,
              child: Text(
                authController.userSession.value!.fullname!.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ).marginAll(8.0),
          )
        ],
      ),
      body: _bodyContent(),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Svg(
            path: "timer-start.svg",
            size: 80.0,
            color: primaryColor,
          ).paddingBottom(8.0),
          const Text("Pas d'information pour l'instant !")
        ],
      ),
    );
  }

  Widget _bodyContent() {
    return Obx(() {
      final plannings = tagsController.plannings;

      if (plannings.isEmpty) {
        return emptyState();
      }

      final nextPlanningId = tagsController.nextPlanning.value?.id;
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final todaySlashStr = DateFormat('dd/MM/yyyy').format(now);

      return ListView.separated(
        itemCount: plannings.length,
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, index) {
          var item = plannings[index];
          bool isNext = item.id == nextPlanningId;
          
          // Déterminer si le planning est passé pour aujourd'hui et non fait
          bool isPastToday = false;
          if ((item.date == todayStr || item.date == todaySlashStr) && item.endTime != null) {
            try {
              final endParts = item.endTime!.split(':');
              final endDateTime = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
              if (now.isAfter(endDateTime)) {
                isPastToday = true;
              }
            } catch (_) {}
          }

          return Stack(
            children: [
              Card(
                elevation: isNext ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: isNext 
                    ? const BorderSide(color: primaryMaterialColor, width: 2) 
                    : BorderSide(color: Colors.grey.shade200),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.libelle!.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    fontFamily: 'Staatliches',
                                    letterSpacing: 1,
                                    color: isNext ? primaryMaterialColor : const Color(0xFF16161E),
                                  ),
                            ),
                          ),
                          if (isNext)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryMaterialColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "À VENIR",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ).paddingBottom(8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                item.date ?? "",
                                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildTimeChip(context, item.startTime!, Icons.access_time_filled_rounded),
                              const SizedBox(width: 10),
                              _buildTimeChip(context, item.endTime!, Icons.access_time_rounded),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              if (isPastToday)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryMaterialColor.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(color: primaryMaterialColor.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, color: primaryMaterialColor, size: 12),
                        SizedBox(width: 4),
                        Text(
                          "NON EFFECTUÉE",
                          style: TextStyle(color: primaryMaterialColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(
          height: 12.0,
        ),
      );
    });
  }

  Widget _buildTimeChip(BuildContext context, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 14),
          const SizedBox(width: 5),
          Text(
            time,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16161E)),
          ),
        ],
      ),
    );
  }
}
