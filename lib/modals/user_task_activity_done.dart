import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/svg.dart';
import 'utils.dart';

Future<void> showUserActivitiesDoneModal(context) async {
  showCustomModal(
    context,
    onClosed: () {},
    title: "Liste des tâches effectuées",
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          for (int i = 0; i < 5; i++) ...[
            DottedBorder(
              color: greyColor40,
              radius: const Radius.circular(12.0),
              strokeWidth: 1,
              borderType: BorderType.RRect,
              dashPattern: const [6, 3],
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  color: greyColor20,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Svg(
                          path: "check-double.svg",
                          color: primaryColor,
                        ).paddingRight(5.0),
                        const Expanded(
                          child: Text(
                            "The path provided below has to start and end with a slash",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: darkColor,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ).marginOnly(bottom: 5.0)
          ]
        ],
      ),
    ),
  );
}
