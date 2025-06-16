import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              "Veuillez sélectionner l'agent que vous êtes en train de superviser.",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: primaryMaterialColor,
                    fontWeight: FontWeight.w500,
                  ),
            ).paddingBottom(15.0),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (__, _) {
                return const SupervisorAgentCard();
              },
              separatorBuilder: (__, _) {
                return const SizedBox(
                  height: 8,
                );
              },
              itemCount: 5,
            ),
            const SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 55.0,
              child: SubmitButton(
                label: "Cloturer supervision",
                loading: tagsController.isLoading.value,
                onPressed: () async {},
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SupervisorAgentCard extends StatelessWidget {
  final bool isActive;
  const SupervisorAgentCard({
    super.key,
    this.isActive = false,
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
                        child: Image.asset(
                          "assets/images/profil-2.png",
                          height: 40.0,
                          width: 40.0,
                        ),
                      ).paddingRight(8.0),
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gaston delimond",
                              style: TextStyle(
                                fontFamily: "Staatliches",
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "ST00002",
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 25.0,
                        width: 25.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            width: 2.0,
                            color: primaryMaterialColor.shade200,
                          ),
                        ),
                        child: isActive
                            ? Container(
                                margin: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryMaterialColor,
                                      primaryMaterialColor.shade200
                                    ],
                                  ),
                                ),
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
                              )
                            : const SizedBox.shrink(),
                      )
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
