import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class CostumIconButton extends StatelessWidget {
  final double size;
  final String svg;
  final Color? color;
  final bool isLoading;
  final VoidCallback onPress;
  const CostumIconButton({
    super.key,
    this.size = 50.0,
    this.isLoading = false,
    required this.svg,
    this.color,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: color ?? primaryMaterialColor.shade300,
      radius: Radius.circular(size),
      strokeWidth: 1,
      borderType: BorderType.RRect,
      dashPattern: const [6, 3],
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(size)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPress,
            borderRadius: BorderRadius.circular(size),
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(color: color ?? primaryMaterialColor),
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      height: 22.0,
                      width: 22.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: whiteColor,
                      ),
                    )
                  ] else
                    Svg(
                      path: svg,
                      size: 22.0,
                      color: whiteColor,
                    )
                ],
              ).paddingAll(5.0),
            ),
          ),
        ),
      ),
    );
  }
}
