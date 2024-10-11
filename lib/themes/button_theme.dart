import 'package:flutter/material.dart';

import '../constants/styles.dart';

ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(16.0),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 32),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadius)),
    ),
  ),
);

OutlinedButtonThemeData outlinedButtonTheme(
    {Color borderColor = blackColor10}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(16.0),
      minimumSize: const Size(double.infinity, 32),
      side: BorderSide(width: 1.5, color: borderColor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadius)),
      ),
    ),
  );
}

final textButtonThemeData = TextButtonThemeData(
  style: TextButton.styleFrom(foregroundColor: primaryColor),
);
