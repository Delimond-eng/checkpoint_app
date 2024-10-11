import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                authController.userSession.value.fullname!.substring(0, 1),
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
    return FutureBuilder<List<Planning>>(
      future: HttpManager.getAllPlannings(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          if (snapshot.data!.isEmpty) {
            return emptyState();
          } else {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                var item = snapshot.data![index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item.libelle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18.0,
                                  ),
                            ).paddingBottom(2.0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Heures de patrouille")
                                    .paddingRight(10),
                                const Icon(
                                  Icons.arrow_right_alt_rounded,
                                  size: 17,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled_sharp,
                                      color: primaryColor,
                                      size: 16.0,
                                    ).paddingRight(6.0),
                                    Text(
                                      item.startTime!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    )
                                  ],
                                ).paddingRight(20.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: primaryColor,
                                      size: 16.0,
                                    ).paddingRight(6.0),
                                    Text(
                                      item.endTime!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(
                height: 8.0,
              ),
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
    );
  }
}
