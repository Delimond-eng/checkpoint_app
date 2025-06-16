import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/themes/app_theme.dart';

import 'package:flutter/material.dart';

import '../widgets/submit_button.dart';
import 'utils.dart';

Future<void> showSupervisorFormModal(context) async {
  showCustomModal(
    context,
    onClosed: () {
      //tagsController.isScanningModalOpen.value = false;
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
          for (int i = 0; i < 5; i++) ...[
            const ElementCard().paddingBottom(5.0),
          ],
          const SizedBox(
            height: 5.0,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 55.0,
            child: SubmitButton(
              label: "Valider",
              loading: false,
              onPressed: () async {},
            ),
          )
        ],
      ),
    ),
  );
}

class ElementCard extends StatelessWidget {
  const ElementCard({
    super.key,
  });

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Placeat nemo corporis.".toUpperCase(),
                    style: const TextStyle(
                      color: darkGreyColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ).paddingBottom(4.0),
                  Text(
                    "Lorem ipsum dolor sit amet consectetur, adipisicing elit.",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 8.0,
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                const TaskCheck(
                  label: "B",
                ).paddingRight(5.0),
                const TaskCheck(
                  label: "P",
                ).paddingRight(5.0),
                const TaskCheck(
                  label: "M",
                ),
              ],
            ).paddingLeft(5.0)
          ],
        ),
      ),
    );
  }
}

class TaskCheck extends StatelessWidget {
  final String? label;
  final bool isActive;
  const TaskCheck({super.key, this.label, this.isActive = false});

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
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label!,
              style: const TextStyle(
                fontFamily: "Staatliches",
                fontWeight: FontWeight.w800,
                fontSize: 12.0,
              ),
            ).paddingBottom(3.0),
            if (isActive) ...[
              AnimatedContainer(
                height: 25.0,
                width: 25.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade200],
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
                    color: Colors.blue.shade300,
                  ),
                ),
                duration: const Duration(milliseconds: 100),
              )
            ]
          ],
        ),
      ),
    );
  }
}
