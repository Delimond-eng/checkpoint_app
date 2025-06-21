import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/supervisor_data.dart';
import 'package:checkpoint_app/modals/recognition_face_modal.dart';
import 'package:checkpoint_app/pages/supervisor_agent.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../widgets/user_status.dart';

class SupervisorPlanning extends StatefulWidget {
  const SupervisorPlanning({super.key});

  @override
  State<SupervisorPlanning> createState() => _SupervisorPlanningState();
}

class _SupervisorPlanningState extends State<SupervisorPlanning> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tagsController.isScanningModalOpen.value = false;
    tagsController.isLoading.value = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "SUPERVISION SITES",
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
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                "Veuillez sélectionner le site que vous êtes en train d'inspecter afin de poursuivre l'inspection.",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: primaryMaterialColor,
                      fontWeight: FontWeight.w500,
                    ),
              ).paddingBottom(15.0),
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var item = authController.supervisorSites[index];
                  return SupervisionPlanningSiteCard(
                    data: item,
                  );
                },
                separatorBuilder: (__, _) {
                  return const SizedBox(
                    height: 8,
                  );
                },
                itemCount: authController.supervisorSites.length,
              )
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          authController.refreshUser();
        },
        child: Obx(
          () => tagsController.isLoading.value
              ? const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    color: primaryMaterialColor,
                  ),
                )
              : const Icon(
                  CupertinoIcons.refresh,
                  color: primaryMaterialColor,
                ),
        ),
      ),
    );
  }
}

class SupervisionPlanningSiteCard extends StatelessWidget {
  final SiteModel data;
  const SupervisionPlanningSiteCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          onTap: () {
            if (authController.pendingSupervisionMap.isEmpty) {
              authController.selectedSupervisorAgents.value = data.agents;
              showRecognitionModal(
                context,
                key: "supervize-in",
                siteId: data.siteId,
                scheduleId: data.planningId,
              );
            } else {
              if (data.planningId.toString() ==
                  authController.pendingSupervisionMap["schedule_id"]) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupervisorAgent(),
                  ),
                );
              } else {
                EasyLoading.showInfo(
                    "Vous avez une supervision en cours et non cloturée !");
              }
            }
          },
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data.planningTitle),
                      Text(
                        data.planningDate,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(4.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Svg(
                              path: "supervision-3.svg",
                              size: 40.0,
                              color: primaryMaterialColor,
                            ).paddingRight(8.0),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.siteLibelle.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: "Staatliches",
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    data.siteCode,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: primaryMaterialColor.shade200,
                        size: 15.0,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
