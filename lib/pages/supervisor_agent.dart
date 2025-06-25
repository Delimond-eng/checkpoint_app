import 'package:cached_network_image/cached_network_image.dart';
import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/global/store.dart';
import 'package:checkpoint_app/kernel/models/supervisor_data.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:checkpoint_app/modals/recognition_face_modal.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../modals/supervisor_form_modal.dart';
import '../widgets/submit_button.dart' show SubmitButton;
import '../widgets/user_status.dart';

class SupervisorAgent extends StatefulWidget {
  const SupervisorAgent({super.key});

  @override
  State<SupervisorAgent> createState() => _SupervisorAgentState();
}

class _SupervisorAgentState extends State<SupervisorAgent> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tagsController.isScanningModalOpen.value = false;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "LISTE DES AGENTS",
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
      body: Obx(
        () => authController.selectedSupervisorAgents.isEmpty
            ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Aucun agent disponible pour le site sélectionné !",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: primaryMaterialColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 55.0,
                        child: SubmitButton(
                          label: "Fermer & cloturer",
                          loading: tagsController.isLoading.value,
                          onPressed: () async {},
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            "Veuillez sélectionner l'agent que vous êtes en train de superviser.",
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: primaryMaterialColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ).paddingBottom(15.0),
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var data = authController
                                  .selectedSupervisorAgents[index];
                              return SupervisorAgentCard(
                                data: data,
                              );
                            },
                            separatorBuilder: (__, _) {
                              return const SizedBox(
                                height: 8,
                              );
                            },
                            itemCount:
                                authController.selectedSupervisorAgents.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 20.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 55.0,
                      child: SubmitButton(
                        label: "Cloturer supervision",
                        loading: tagsController.isLoading.value,
                        onPressed: () async {
                          showRecognitionModal(context, key: "supervize-out",
                              onValidate: () {
                            closeAndSend();
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Future<void> closeAndSend() async {
    List<Map<String, dynamic>> elements = [];
    authController.agentElementsMap.forEach((id, elementList) {
      for (var element in elementList) {
        elements.add({
          "presence_id": authController.pendingSupervisionMap["id"],
          "element_id": element.id,
          "note": element.selectedNote,
          "agent_id": authController.userSession.value.id,
        }); // adapte selon les champs de ElementModel
      }
    });
    if (kDebugMode) {
      print("ELEMENT : $elements");
    }
    final manager = HttpManager();
    var planningId = authController.pendingSupervisionMap["schedule_id"];
    var siteId = authController.pendingSupervisionMap["site_id"];
    tagsController.isLoading.value = true;
    manager.makeSupervision(siteId, planningId, elements: elements).then((res) {
      tagsController.isLoading.value = false;
      if (res is String) {
        EasyLoading.showInfo("Echec de traitement de la requête !");
      } else {
        localStorage.remove("pending_supervision");
        EasyLoading.showSuccess("La supervision clotûrée avec succès !");
        authController.refreshPendingSupervisionMap();
        authController.refreshUser();
        authController.agentElementsMap = {};
        Get.back();
      }
    });
  }
}

class SupervisorAgentCard extends StatelessWidget {
  final AgentModel data;
  const SupervisorAgentCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {
            authController.selectedAgentId.value = data.id;
            if (!authController.agentElementsMap.containsKey(data.id)) {
              authController.agentElementsMap[data.id] =
                  authController.supervisorElements.map((element) {
                return ElementModel.cloneFrom(element);
              }).toList();
            }
            showSupervisorFormModal(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40.0),
                        child: data.photo != null
                            ? CachedNetworkImage(
                                height: 40.0,
                                width: 40.0,
                                fit: BoxFit.cover,
                                imageUrl: data.photo!
                                    .replaceAll("127.0.0.1", "192.168.211.223"),
                                placeholder: (context, url) => Image.asset(
                                  "assets/images/profil-2.png",
                                  height: 40.0,
                                  width: 40.0,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/images/profil-2.png",
                                  height: 40.0,
                                  width: 40.0,
                                ),
                              )
                            : Image.asset(
                                "assets/images/profil-2.png",
                                height: 40.0,
                                width: 40.0,
                              ),
                      ).paddingRight(8.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.fullname.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: "Staatliches",
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              data.matricule,
                            ),
                          ],
                        ),
                      ),
                      Obx(() => Container(
                            height: 30.0,
                            width: 30.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.lightBlue,
                              ),
                            ),
                            child: authController.supervisedAgent
                                    .contains(data.id)
                                ? Container(
                                    margin: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.lightBlue,
                                        ],
                                      ),
                                    ),
                                    child: const Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_rounded,
                                          size: 14.0,
                                          color: whiteColor,
                                        )
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
