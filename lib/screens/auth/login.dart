import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/screens/public/welcome_screen.dart';
import 'package:checkpoint_app/widgets/costum_field.dart';
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
    var screenSize = MediaQuery.of(context).size;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
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
          if (!isKeyboardVisible)
            Positioned(
              bottom: 10.0,
              child: Text(
                "Salama plateforme version $version",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
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
        faceRecognitionController.enrollUserFaceFromUrl();
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
