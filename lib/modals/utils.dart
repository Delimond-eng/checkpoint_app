import 'package:animate_do/animate_do.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomModal(context,
    {required Widget child, required String title, VoidCallback? onClosed}) {
  var size = MediaQuery.of(context).size;
  showGeneralDialog(
    context: context,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      Tween<Offset> tween;
      tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
      return SlideTransition(
        position: tween.animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
    pageBuilder: (context, __, _) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 30.0, 10, 10),
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20.0,
                                    fontFamily: "Staatliches",
                                    letterSpacing: 1.0,
                                  ),
                            ).paddingRight(5),
                          ),
                          ZoomIn(
                            child: Container(
                              height: 30.0,
                              width: 30.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    onClosed!.call();
                                    Get.back();
                                  },
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.clear,
                                      size: 18.0,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).marginAll(10.0),
                      child
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
