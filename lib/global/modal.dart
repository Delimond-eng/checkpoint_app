import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../themes/colors.dart';

void showCustomModal(context, {required Widget child, double? width}) {
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
        backgroundColor: Colors.black12,
        body: Center(
          child: SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0),
                  width: width ?? size.width,
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.zero,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      )
                    ],
                  ),
                  child: child,
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: ZoomIn(
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
                            Navigator.pop(context);
                          },
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/icons/backiii.svg",
                              height: 22.0,
                              colorFilter: const ColorFilter.mode(
                                primaryColor,
                                BlendMode.srcIn,
                              ),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

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
                      height: 70.0,
                      width: 70.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white.withOpacity(.5),
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
                height: 170.0,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
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
                              color: primaryColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
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
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Btn(
                            color: Colors.grey.shade700,
                            height: 40.0,
                            label: 'Non',
                            labelColor: Colors.white,
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
                            color: Colors.green.shade500,
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
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? primaryColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPressed!(),
          borderRadius: BorderRadius.circular(4.0),
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
    );
  }
}
