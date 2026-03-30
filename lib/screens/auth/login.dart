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

  initAppVesion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    int currentVersion = int.parse(packageInfo.buildNumber);
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

          // FILIGRANE AU CENTRE (Fixe par rapport à l'écran total)

          // Main Content
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal:15.0),
                child: Column(
                  children: [
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
                                    child: const Text(
                                      "Veuillez entrer vos identifiants pour continuer",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
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
                                    hintText: "Matricule agent",
                                    iconPath: "assets/icons/user.svg",
                                    inputType: TextInputType.text,
                                    controller: txtUserName,
                                  ),
                                  const SizedBox(height: 5.0),
                                  CustomField(
                                    hintText: "Mot de passe",
                                    iconPath: "assets/icons/key.svg",
                                    isPassword: true,
                                    controller: txtUserPass,
                                  ),
                                  const SizedBox(height: 5.0),
                                  CostumButton(
                                    title: "Se Connecter",
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
    setState(() {
      isLoading = true;
    });
    manager
        .login(uMatricule: txtUserName.text, uPass: txtUserPass.text)
        .then((res) {
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


  Widget oldScreen(context){
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            height: screenSize.height,
            width: screenSize.width,
            decoration: const BoxDecoration(
              color: Color(0xFF020005),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              0,
              (screenSize.height * .44),
              0,
              4,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/mamba-2.png",
                      height: 100.0,
                      fit: BoxFit.scaleDown,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      "SALAMA",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: whiteColor,
                        fontFamily: 'Staatliches',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Container(
                  height: screenSize.height,
                  decoration: const BoxDecoration(
                    color: scaffoldColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Column(
                      children: [
                        CustomField(
                          hintText: "Matricule agent",
                          iconPath: "assets/icons/user.svg",
                          controller: txtUserName,
                        ),
                        CustomField(
                          hintText: "Mot de passe",
                          iconPath: "assets/icons/key.svg",
                          isPassword: true,
                          controller: txtUserPass,
                        ),
                        SizedBox(
                          width: screenSize.width,
                          height: 55.0,
                          child: CostumButton(
                            onPress: _login,
                            isLoading: isLoading,
                            title: 'Connecter',
                            bgColor: primaryMaterialColor,
                            labelColor: whiteColor,
                          ),
                        ).marginOnly(bottom: 40)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
