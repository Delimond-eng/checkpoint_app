import 'package:flutter/material.dart';

const primaryColor = Color(0xFF331778);
const secondaryColor = Color(0xFF4d2a9a);
const secondaryLightColor = Color.fromARGB(255, 135, 94, 224);
const scaffoldColor = Color(0xFFe9e5fb);
const lightColor = Color(0xFFf9f6fe);
const semiLightColor = Color(0xFFafa3d6);

class Palette {
  static const MaterialColor kPrimarySwatch = MaterialColor(
    0xFF331778, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xFF331778), //10%
      100: Color(0xFF331778), //20%
      200: Color(0xFF331778), //30%
      300: Color(0xFF331778), //40%
      400: Color(0xFF331778), //50%
      500: Color(0xFF331778), //60%
      600: Color(0xFF331778), //70%
      700: Color(0xFF331778), //80%
      800: Color(0xFF331778), //90%
      900: Color(0xFF331778), //100%
    },
  );
}
