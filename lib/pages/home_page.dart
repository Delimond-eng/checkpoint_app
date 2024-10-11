import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/announce.dart';
import 'package:checkpoint_app/kernel/services/http_manager.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final loading = ValueNotifier<bool>(false);
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
            Text("Communiqués".toUpperCase()),
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
      body: _bodyContent(),
    );
  }

  Widget _bodyContent() {
    return FutureBuilder<List<Announce>>(
      future: HttpManager.getAllAnnounces(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Svg(
                    path: "announce_line.svg",
                    size: 70.0,
                    color: primaryColor,
                  ).paddingBottom(8.0),
                  const Text("Pas de communiqué pour l'instant !")
                ],
              ),
            );
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
                        Text(
                          item.title!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0,
                              ),
                        ).paddingBottom(8.0),
                        Text(
                          item.content!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width,
                          color: greyColor.withOpacity(.3),
                        ).paddingVertical(8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "new",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: whiteColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryMaterialColor.shade50,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 15.0,
                                    ).paddingRight(5.0),
                                    Text(
                                      item.createdAt!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    )
                                  ],
                                ),
                              ),
                            ),
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
