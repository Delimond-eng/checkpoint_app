import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Svg extends StatelessWidget {
  final String path;
  final double? size;
  final Color? color;
  const Svg({super.key, required this.path, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/svgs/$path",
      colorFilter: ColorFilter.mode(color ?? Colors.grey, BlendMode.srcIn),
      height: size ?? 22.0,
    );
  }
}
