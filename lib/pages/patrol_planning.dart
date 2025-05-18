import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';
import '../kernel/models/planning.dart';
import '../widgets/svg.dart';
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
      body: Center(
        child: SingleChildScrollView(
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
              FutureBuilder<List<Planning>>(
                future: HttpManager.getAllPlannings(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    if (snapshot.data!.isEmpty) {
                      return emptyState();
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        padding: const EdgeInsets.all(10.0),
                        itemBuilder: (context, index) {
                          var item = snapshot.data![index];
                          return PlanningCard(
                            data: item,
                          );
                        },
                      );
                    }
                  } else {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [CircularProgressIndicator()],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
            size: 40.0,
            color: primaryColor,
          ).paddingBottom(10.0),
          const Text(
            "Aucun planning disponible !",
            style: TextStyle(
              color: primaryMaterialColor,
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
            ),
          )
        ],
      ),
    ).paddingTop(30.0);
  }
}

class PlanningCard extends StatelessWidget {
  final Planning? data;
  const PlanningCard({
    super.key,
    this.data,
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
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_sharp,
                      size: 14.0,
                      color: primaryColor,
                    ),
                    Text(
                      "${data!.startTime} - ${data!.endTime}",
                      style: const TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        color: darkColor,
                      ),
                    )
                  ],
                ),
              ),
            ).paddingRight(8.0),
            Expanded(
              child: Text(
                data!.libelle!,
                style: const TextStyle(
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
