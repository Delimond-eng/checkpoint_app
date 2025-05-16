import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';
import '../widgets/user_status.dart';

class PatrolPlanning extends StatefulWidget {
  const PatrolPlanning({super.key});

  @override
  State<PatrolPlanning> createState() => _PatrolPlanningState();
}

class _PatrolPlanningState extends State<PatrolPlanning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "PLANNING DE PATROUILLE",
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
              "Votre emploi du temps de patrouille. Le respect des horaires est essentiel pour éviter des pénalités.",
              style: TextStyle(
                color: primaryMaterialColor,
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ).paddingTop(10.0).paddingBottom(15.0),
            for (int i = 0; i < 6; i++) ...[const PlanningCard()]
          ],
        ),
      ),
    );
  }
}

class PlanningCard extends StatelessWidget {
  const PlanningCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: greyColor60,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_sharp,
                      size: 14.0,
                      color: primaryColor,
                    ),
                    Text(
                      "08:00 - 10:00",
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        color: darkColor,
                      ),
                    )
                  ],
                ),
              ),
            ).paddingRight(8.0),
            const Expanded(
              child: Text(
                "Patrouille matinale",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: darkColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
