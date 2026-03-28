import 'dart:ui';
import '/themes/app_theme.dart';
import 'package:flutter/material.dart';
import '../constants/styles.dart';
import 'svg.dart';

class HomeMenuBtn extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onPress;
  final Color color;
  final int badgeCount;
  final Color badgeColor;

  const HomeMenuBtn({
    super.key,
    required this.title,
    required this.icon,
    this.onPress,
    this.color = primaryMaterialColor,
    this.badgeCount = 0,
    this.badgeColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final btnSize = (screen.width - 60) / 3;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.0),
                  onTap: onPress,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.5),
                              color.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Svg(
                          path: "$icon.svg",
                          size: btnSize * 0.28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Staatliches',
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                          fontSize: btnSize * 0.11,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 22,
                minHeight: 22,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
