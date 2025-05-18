import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';
import '../kernel/models/announce.dart';
import '../widgets/svg.dart';
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
      body: FutureBuilder<List<Announce>>(
        future: HttpManager.getAllAnnounces(),
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
                  return AnnounceCard(
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
                children: [
                  CircularProgressIndicator(
                    color: primaryMaterialColor,
                  )
                ],
              ),
            );
          }
        },
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
            path: "notify.svg",
            size: 40.0,
            color: primaryColor,
          ).paddingBottom(10.0),
          const Text(
            "Aucun communiqué disponible !",
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

class AnnounceCard extends StatelessWidget {
  final Announce? data;
  const AnnounceCard({super.key, this.data});

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
                data!.title!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primaryMaterialColor.shade900,
                ),
              ).paddingLeft(5.0).paddingBottom(5.0),
              BubbleSpecialOne(
                text: data!.content!,
                isSender: false,
                color: greyColor60,
                textStyle: const TextStyle(fontSize: 15.0, color: darkColor),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 12.0,
                    color: Colors.blue,
                  ).paddingRight(5.0),
                  Text(
                    data!.createdAt!,
                    style: const TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ).marginOnly(right: 20.0)
            ],
          ),
        ),
      ],
    );
  }
}
