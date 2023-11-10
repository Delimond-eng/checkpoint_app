import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '/screens/auth/login.dart';
import '/themes/colors.dart';
import 'package:flutter/material.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Palette.kPrimarySwatch,
        scaffoldBackgroundColor: scaffoldColor,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      builder: EasyLoading.init(),
    );
  }
}
