import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/themes/colors.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../constants/styles.dart';
import 'svg.dart';

class HomeMenuBtn extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onPress;

  const HomeMenuBtn({
    super.key,
    required this.title,
    required this.icon,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final btnSize = (screenWidth - 60) / 3;

    return DottedBorder(
      color: primaryMaterialColor.shade100,
      radius: const Radius.circular(12.0),
      strokeWidth: 1,
      borderType: BorderType.RRect,
      dashPattern: const [6, 3],
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          height: btnSize,
          width: btnSize,
          decoration: BoxDecoration(
            color: primaryMaterialColor.shade50.withOpacity(.3),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: onPress!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Svg(
                    path: "$icon.svg",
                    size: btnSize * 0.4, // Taille de l'icône responsive
                    color: primaryMaterialColor,
                  ).paddingBottom(8.0),
                  Text(
                    title,
                    style: TextStyle(
                      color: blackColor80,
                      fontWeight: FontWeight.w600,
                      fontSize: btnSize * 0.11, // Taille du texte responsive
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
