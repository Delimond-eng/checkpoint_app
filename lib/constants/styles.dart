import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those mean opacity

const Color primaryColor = Color(0xFFd40200); // Nouvelle couleur primaire

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFFD40200, <int, Color>{
  50: Color(0xFFFFE5E5),
  100: Color(0xFFFFB8B8),
  200: Color(0xFFFF8A8A),
  300: Color(0xFFFF5C5C),
  400: Color(0xFFFF3838),
  500: Color(0xFFD40200), // Couleur primaire
  600: Color(0xFFBF0200),
  700: Color(0xFFA30200),
  800: Color(0xFF880100),
  900: Color(0xFF5B0100),
});

// Les autres couleurs restent inchangées

const Color scaffoldColor = Color.fromARGB(255, 233, 237, 247);
const Color darkColor = Color(0xFF020005);

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whiteColor80 = Color(0xFFCCCCCC);
const Color whiteColor60 = Color(0xFF999999);
const Color whiteColor40 = Color(0xFF666666);
const Color whiteColor20 = Color(0xFF333333);
const Color whiteColor10 = Color(0xFF191919);
const Color whiteColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
const Color greyColor80 = Color(0xFFC6C4CF);
const Color greyColor60 = Color(0xFFD4D3DB);
const Color greyColor40 = Color(0xFFE3E1E7);
const Color greyColor20 = Color(0xFFF1F0F3);
const Color greyColor10 = Color(0xFFF8F8F9);
const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 10.0;
const double defaultBorderRadius = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Mot de passe requis.'),
  MinLengthValidator(8,
      errorText: 'Le mot de passe doit comporter au moins 8 caractères.'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText:
          'Les mots de passe doivent contenir au moins un caractère spécial.')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email est requis.'),
  EmailValidator(errorText: "Saisissez une adresse e-mail valide."),
]);

final phoneValidator = MultiValidator([
  RequiredValidator(errorText: "Numéro de téléphone requis."),
  MinLengthValidator(9,
      errorText: "Le Numéro de téléphone doit comporter au moins 9 chiffres.")
]);

const pasNotMatchErrorText = "Les mots de passe ne correspondent pas.";
