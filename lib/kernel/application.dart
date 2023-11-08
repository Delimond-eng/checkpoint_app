import 'package:checkpoint_app/screens/auth/login.dart';
import 'package:checkpoint_app/screens/home_screen.dart';
import 'package:checkpoint_app/themes/colors.dart';
import 'package:flutter/material.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Palette.kPrimarySwatch,
        scaffoldBackgroundColor: scaffoldColor,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
