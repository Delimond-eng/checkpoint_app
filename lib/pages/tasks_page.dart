import 'package:checkpoint_app/themes/app_theme.dart';
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
        backgroundColor: darkColor,
        title: const Text(
          "Tâches",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Text(
              "Vous devez cocher un ou plusieurs de vos tâches déjà effectuées puis valider !",
              style: TextStyle(
                color: primaryMaterialColor,
                fontWeight: FontWeight.w500,
                fontSize: 12.0,
              ),
            ).paddingTop(10.0).paddingBottom(15.0),
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
      floatingActionButton: tasks.isNotEmpty
          ? FloatingActionButton(
              heroTag: "btnLight",
              elevation: 10.0,
              backgroundColor: Colors.green,
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
    return DottedBorder(
      color: greyColor80,
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
                          fontWeight:
                              task.isActive ? FontWeight.w600 : FontWeight.w500,
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
    ).marginOnly(bottom: 8.0);
  }
}
