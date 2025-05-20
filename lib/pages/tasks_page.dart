import 'package:animate_do/animate_do.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';
import '../kernel/models/task.dart';
import '../widgets/user_status.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 40.0,
            ).paddingRight(5.0),
            const Text(
              "Mes Tâches",
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w900,
                color: whiteColor,
                fontFamily: 'Staatliches',
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          const UserStatus(name: "Gaston delimond").marginAll(8.0),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _welcome(),
              for (var task in taches) ...[
                TaskCardItem(
                  task: task,
                  onChecked: () {
                    setState(() {
                      task.isActive = !task.isActive;
                      if (task.isActive) {
                        tasks.add(task);
                      } else {
                        int index = tasks.indexOf(task);
                        tasks.removeAt(index);
                      }
                    });
                  },
                )
              ]
            ],
          ),
        ),
      ),
      floatingActionButton: tasks.isNotEmpty
          ? FloatingActionButton(
              heroTag: "btnLight",
              elevation: 10.0,
              backgroundColor: secondaryColor,
              onPressed: () async {},
              child: const Icon(
                Icons.check_rounded,
                color: whiteColor,
                size: 22.0,
              ),
            )
          : null,
    );
  }

  Widget _welcome() {
    return FadeInUp(
      child: DottedBorder(
        color: primaryColor.withOpacity(.5),
        radius: const Radius.circular(12.0),
        strokeWidth: 1,
        borderType: BorderType.RRect,
        dashPattern: const [6, 3], // Optionnel, personnalise les pointillés
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            // Utilise padding plutôt que margin
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/task-illustration-1.png",
                  height: 80.0,
                ).paddingRight(8.0),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenue Gaston delimond",
                        style: TextStyle(
                          fontFamily: 'Staatliches',
                          color: primaryMaterialColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        "Veuillez completer vos tâches effectuées.",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ).paddingBottom(20.0),
    );
  }
}

class TaskCardItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onChecked;
  const TaskCardItem({
    super.key,
    required this.task,
    this.onChecked,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: DottedBorder(
        color: greyColor5,
        radius: const Radius.circular(12.0),
        strokeWidth: 1,
        borderType: BorderType.RRect,
        dashPattern: const [6, 3],
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            color: Colors.white,
            child: Material(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              color: Colors.transparent,
              child: InkWell(
                onTap: onChecked,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: task.isActive
                                ? primaryMaterialColor
                                : greyColor80,
                            width: 1,
                          ),
                        ),
                        height: 30.0,
                        width: 30.0,
                        child: Container(
                          margin: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: task.isActive
                                ? primaryMaterialColor
                                : Colors.transparent,
                          ),
                          child: Svg(
                            path: "check-double.svg",
                            size: 12.0,
                            color:
                                task.isActive ? whiteColor : Colors.transparent,
                          ).marginAll(3.0),
                        ),
                      ).paddingRight(5.0),
                      Expanded(
                        child: Text(
                          task.title!,
                          style: TextStyle(
                            decoration: task.isActive
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            fontSize: 14.0,
                            fontWeight: task.isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: darkColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ).marginOnly(bottom: 5.0),
    );
  }
}
