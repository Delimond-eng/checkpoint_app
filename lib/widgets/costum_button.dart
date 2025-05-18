import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../constants/styles.dart';

class CostumButton extends StatelessWidget {
  final String title;
  final Color? labelColor;
  final Color? bgColor;
  final Color? borderColor;
  final VoidCallback? onPress;
  final bool isLoading;

  const CostumButton(
      {super.key,
      required this.title,
      this.onPress,
      this.labelColor,
      this.bgColor,
      this.borderColor,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: borderColor ?? primaryMaterialColor.shade200,
      radius: const Radius.circular(12.0),
      strokeWidth: 1,
      borderType: BorderType.RRect,
      dashPattern: const [6, 3],
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Material(
          color: primaryMaterialColor.shade50.withOpacity(.2),
          child: InkWell(
            onTap: isLoading ? null : onPress,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(color: bgColor ?? Colors.transparent),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        color: labelColor ?? Colors.white,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ] else
                    Text(
                      title,
                      style: TextStyle(
                        color: labelColor ?? blackColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Staatliches",
                        letterSpacing: 1,
                        fontSize: 13.0,
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
