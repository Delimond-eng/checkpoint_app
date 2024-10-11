import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global/controllers.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
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
            Text("Talkie walkie".toUpperCase()),
          ],
        ),
        actions: [
          Obx(
            () => CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                authController.userSession.value.fullname!.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ).marginAll(8.0),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Svg(
              path: "radio-3-line.svg",
              size: 40.0,
              color: primaryColor,
            ).paddingBottom(8.0),
            const Text(
              "Laissez votre doigt enfoncé sur le bouton pour parler et emettre en message sur ce canal privé !",
              textAlign: TextAlign.center,
            ).paddingBottom(8.0),
            const BtnSpeach()
          ],
        ).marginAll(15.0),
      ),
    );
  }
}

class BtnSpeach extends StatelessWidget {
  const BtnSpeach({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: 100.0,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          color: primaryColor,
          width: 2.0,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          gradient: LinearGradient(
            colors: [primaryColor, primaryMaterialColor.shade300],
          ),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(80.0),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(80.0),
            onTap: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.mic,
                  color: whiteColor,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
