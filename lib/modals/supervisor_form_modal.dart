import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/supervisor_data.dart';
import 'package:checkpoint_app/themes/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showSupervisorFormModal(context) async {
  final agentId = authController.selectedAgentId.value;
  final elementList = authController.agentElementsMap[agentId]!;
  showCustomModal(
    context,
    onClosed: () {
      final allChecked =
          elementList.every((element) => element.selectedNote != null);
      if (!allChecked) {
        authController.supervisedAgent.remove(agentId);
        authController.supervisedAgent.refresh();
      }
    },
    title: "Elémenent à superviser",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Veuillez completer les éléments si dessous en guise de rapport !",
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: primaryMaterialColor),
          ).paddingBottom(8.0),
          ...elementList
              .map((e) => ElementCard(data: e).paddingBottom(4))
              .toList(),
          const SizedBox(
            height: 5.0,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            child: SubmitButton(
              label: "Valider",
              loading: false,
              onPressed: () async {
                final allChecked = elementList
                    .every((element) => element.selectedNote != null);
                if (allChecked) {
                  if (!authController.supervisedAgent.contains(agentId)) {
                    authController.supervisedAgent.add(agentId);
                    authController.supervisedAgent.refresh();
                    authController.update();
                    Get.back();
                  } else {
                    authController.supervisedAgent.add(agentId);
                    authController.supervisedAgent.refresh();
                    authController.update();
                    Get.back();
                  }
                } else {
                  authController.supervisedAgent.remove(agentId);
                  authController.supervisedAgent.refresh();
                  EasyLoading.showInfo(
                      "Veuillez completer tous les éléments pour valider !");
                  return;
                }
              },
            ),
          )
        ],
      ),
    ),
  );
}

class ElementCard extends StatefulWidget {
  final ElementModel data;
  const ElementCard({super.key, required this.data});

  @override
  State<ElementCard> createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: scaffoldColor,
        border: Border.all(
            color: const Color.fromARGB(255, 216, 224, 246), width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Gauche
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.libelle,
                    style: const TextStyle(
                      color: darkGreyColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ).paddingBottom(4.0),
                  Text(
                    widget.data.description,
                    style:
                        TextStyle(color: Colors.grey.shade800, fontSize: 8.0),
                  )
                ],
              ),
            ),
            // Droite : boutons B / P / M
            Row(
              children: widget.data.checkTasks.map((task) {
                return Row(
                  children: [
                    TaskCheck(
                      label: task["label"],
                      isActive: task["isActive"],
                      onActived: () {
                        setState(() {
                          widget.data.activateNote(task["label"]);
                        });
                      },
                    ),
                    const SizedBox(width: 5.0),
                  ],
                );
              }).toList(),
            ).paddingLeft(5.0),
          ],
        ),
      ),
    );
  }
}

class TaskCheck extends StatelessWidget {
  final String? label;
  final bool isActive;
  final VoidCallback onActived;
  const TaskCheck(
      {super.key, this.label, this.isActive = false, required this.onActived});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          width: 1.5,
          color: Colors.white,
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: onActived,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label!,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 10.0,
                  ),
                ).paddingBottom(3.0),
                if (isActive) ...[
                  AnimatedContainer(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      gradient: LinearGradient(
                        colors: [color, color.shade400],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    duration: const Duration(milliseconds: 100),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 10.0,
                          color: whiteColor,
                        )
                      ],
                    ),
                  ),
                ] else ...[
                  AnimatedContainer(
                    height: 25.0,
                    width: 25.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                        color: color,
                      ),
                    ),
                    duration: const Duration(milliseconds: 100),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  MaterialColor get color {
    if (label == "B") {
      return Colors.green;
    } else if (label == "P") {
      return Colors.amber;
    } else {
      return Colors.deepOrange;
    }
  }
}
