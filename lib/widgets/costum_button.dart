import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../constants/styles.dart';

class CostumButton extends StatelessWidget {
  final String title;
  final Color? labelColor;
  final Color? bgColor;
  final VoidCallback? onPress;

  const CostumButton({
    super.key,
    required this.title,
    this.onPress,
    this.labelColor,
    this.bgColor,
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
        child: Material(
          color: primaryMaterialColor.shade50.withOpacity(.2),
          child: InkWell(
            onTap: onPress,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(color: bgColor ?? Colors.transparent),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  color: labelColor ?? blackColor80,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
