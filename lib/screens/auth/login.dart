import 'dart:ui';

import '/constants/styles.dart';
import '/global/controllers.dart';
import '/kernel/models/user.dart';
import '/widgets/costum_button.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/screens/public/welcome_screen.dart';
import '/widgets/costum_field.dart';
import 'package:flutter/material.dart';

import '/kernel/services/http_manager.dart';
import '/widgets/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final txtUserName = TextEditingController();
  final txtUserPass = TextEditingController();
  String version = "";

  @override
  void initState() {
    super.initState();
    initAppVesion();
  }

  @override
  void dispose() {
    txtUserName.dispose();
    txtUserPass.dispose();
    super.dispose();
  }

  initAppVesion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    int currentVersion = int.parse(packageInfo.buildNumber);
    if (!mounted) return;
    setState(() {
      version = currentVersion.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loginScreen(context);
  }

  Widget _loginScreen(context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // Dark Overlay
          Container(
            height: screenSize.height,
            width: screenSize.width,
            color: Colors.black87,
          ),

          // Main Content
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal:15.0),
                child: Column(
                  children: [
                    // Language Action
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => showLanguageSelector(context),
                        icon: const Icon(Icons.translate_rounded, color: Colors.white70),
                      ),
                    ),
                    
                    // Logo Central
                    Center(
                      child: Hero(
                        tag: 'logo',
                        child: Image.asset(
                          "assets/images/mamba-2.png",
                          height: screenSize.height * .15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "SALAMA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        fontFamily: 'Staatliches',
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: screenSize.width,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // MESSAGE EN GLACE BG
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Text(
                                      "credentials_msg".tr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white70,
                                        fontFamily: 'Ubuntu',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Inputs
                              Column(
                                children: [
                                  CustomField(
                                    hintText: "matricule".tr,
                                    iconPath: "assets/icons/user.svg",
                                    inputType: TextInputType.text,
                                    controller: txtUserName,
                                  ),
                                  const SizedBox(height: 5.0),
                                  CustomField(
                                    hintText: "password".tr,
                                    iconPath: "assets/icons/key.svg",
                                    isPassword: true,
                                    controller: txtUserPass,
                                  ),
                                  const SizedBox(height: 5.0),
                                  CostumButton(
                                    title: "login_btn".tr,
                                    bgColor: primaryColor,
                                    labelColor: Colors.white,
                                    isLoading: isLoading,
                                    onPress:  _login
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "© SALAMA DRC. Tous droits réservés.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (txtUserName.text.isEmpty && txtUserPass.text.isEmpty) {
      EasyLoading.showToast("Nom d'utilisateur et mot de passe requis !");
      return;
    }
    var manager = HttpManager();
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    manager
        .login(uMatricule: txtUserName.text, uPass: txtUserPass.text)
        .then((res) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (res is User) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
          (route) => false,
        );
      } else {
        EasyLoading.showInfo(res.toString());
        return;
      }
    });
  }
}
