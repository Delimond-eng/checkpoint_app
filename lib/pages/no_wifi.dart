import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:flutter/material.dart';

import '../constants/styles.dart';

class NoWifi extends StatelessWidget {
  const NoWifi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/no-wifi.png",
              height: 100.0,
              width: 100.0,
            ).paddingBottom(15.0),
            Text(
              "Aucune connexion réseau n'a été détectée!",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: primaryMaterialColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
