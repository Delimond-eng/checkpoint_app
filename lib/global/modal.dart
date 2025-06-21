import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../themes/colors.dart';

class DGCustomDialog {
  /*Dismiss Loading modal */
  static dismissLoding() {
    Get.back();
  }

  /* Open loading modal */
  static showLoading(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.black12,
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.white.withOpacity(.5),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitFadingCircle(
                            color: secondaryColor,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /* Open dialog interaction with user */
  static showInteraction(BuildContext context,
      {String? message, Function? onValidated}) {
    showGeneralDialog(
        barrierDismissible: false,
        barrierColor: Colors.black12,
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
        pageBuilder: (context, _, __) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                height: 180.0,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Confirmation",
                            style: TextStyle(
                              color: primaryMaterialColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 25.0,
                              fontFamily: "Staatliches",
                            ),
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  message!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ),
                            ],
                          ).paddingBottom(10.0),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Btn(
                            color: primaryMaterialColor.shade100,
                            height: 40.0,
                            label: 'Non',
                            labelColor: darkColor,
                            onPressed: () {
                              Future.delayed(const Duration(milliseconds: 100));
                              Get.back();
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Flexible(
                          child: Btn(
                            height: 40.0,
                            label: 'Oui',
                            color: primaryMaterialColor,
                            labelColor: Colors.white,
                            onPressed: () {
                              Get.back();
                              Future.delayed(const Duration(milliseconds: 100));
                              onValidated!.call();
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class Btn extends StatelessWidget {
  final Color? color;
  final bool? isOutlined;
  final String? label;
  final Color? labelColor;
  final Function? onPressed;
  final double? height;

  const Btn({
    super.key,
    this.color,
    this.isOutlined = false,
    this.label,
    this.onPressed,
    this.labelColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: primaryMaterialColor.shade200,
      radius: const Radius.circular(12.0),
      strokeWidth: 1,
      borderType: BorderType.RRect,
      dashPattern: const [6, 3],
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color ?? primaryMaterialColor,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onPressed!(),
              borderRadius: BorderRadius.circular(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label!,
                    style: TextStyle(
                      color: labelColor ?? Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
