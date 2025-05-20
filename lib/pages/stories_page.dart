import 'package:animate_do/animate_do.dart';
import 'package:checkpoint_app/modals/user_task_activity_done.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:checkpoint_app/widgets/user_status.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
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
              "HISTORIQUE",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Text(
              "L'historique de vos activités lancés.",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: primaryColor,
                fontSize: 13.0,
              ),
            ).paddingBottom(10.0),
            for (int i = 0; i < 5; i++) ...[
              FadeInUp(
                child: DottedBorder(
                  color: greyColor5,
                  radius: const Radius.circular(12.0),
                  strokeWidth: 1,
                  borderType: BorderType.RRect,
                  dashPattern: const [6, 3],
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Container(
                      color: whiteColor,
                      child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showUserActivitiesDoneModal(context);
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Svg(
                                  path: "timer-start.svg",
                                  color: primaryColor,
                                ).paddingRight(5.0),
                                const Expanded(
                                  child: Text(
                                    "The path provided below has to start and end with a slash",
                                    style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
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
              )
            ],
          ],
        ),
      ),
    );
  }
}
