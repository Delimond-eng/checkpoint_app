import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';
import '../widgets/user_status.dart';

class AnnouncePage extends StatefulWidget {
  const AnnouncePage({super.key});

  @override
  State<AnnouncePage> createState() => _AnnouncePageState();
}

class _AnnouncePageState extends State<AnnouncePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkColor,
        title: const Text(
          "Communiqués",
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
            const SizedBox(
              height: 10.0,
            ),
            for (int i = 0; i < 5; i++) ...[
              const AnnounceCard().paddingBottom(8.0),
            ]
          ],
        ),
      ),
    );
  }
}

class AnnounceCard extends StatelessWidget {
  const AnnounceCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          "assets/images/mamba-2.png",
          height: 40.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Avis aux nouveaux agents.",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primaryMaterialColor.shade900,
                ),
              ).paddingLeft(5.0).paddingBottom(5.0),
              const BubbleSpecialOne(
                text:
                    'Il est porté à la connaissance de tous les agents de se présenter demain matin ?',
                isSender: false,
                color: greyColor60,
                textStyle: TextStyle(fontSize: 15.0, color: darkColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
