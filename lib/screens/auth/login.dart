import 'package:flutter_easyloading/flutter_easyloading.dart';

import '/screens/public/welcome_screen.dart';
import 'package:checkpoint_app/themes/colors.dart';
import 'package:checkpoint_app/widgets/costum_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

import '/kernel/services/http_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loading = ValueNotifier<bool>(false);
  final txtUserName = TextEditingController();
  final txtUserPass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: screenSize.height * .6,
            width: screenSize.width,
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              4,
              (screenSize.height * .32),
              4,
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
                    SvgPicture.asset(
                      "assets/icons/nfc-1.svg",
                      height: 80.0,
                      colorFilter: const ColorFilter.mode(
                        scaffoldColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    const Text(
                      "PATROL TAG",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: lightColor,
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        CustomField(
                          hintText: "Nom d'utilisateur",
                          iconPath: "assets/icons/user.svg",
                          controller: txtUserName,
                        ),
                        CustomField(
                          hintText: "Mot de passe",
                          iconPath: "assets/icons/key.svg",
                          isPassword: true,
                          controller: txtUserPass,
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: loading,
                          builder: (context, val, _) => SizedBox(
                            width: screenSize.width,
                            height: 60.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                disabledBackgroundColor: Colors.grey.shade700,
                                elevation: 10.0,
                              ),
                              onPressed: val == true
                                  ? null
                                  : () {
                                      if (txtUserName.text.isEmpty &&
                                          txtUserPass.text.isEmpty) {
                                        EasyLoading.showToast(
                                            "Nom d'utilisateur et mot de passe requis !");
                                        return;
                                      }
                                      var manager = HttpManager();
                                      manager
                                          .login(
                                              uName: txtUserName.text,
                                              uPass: txtUserPass.text)
                                          .then((res) {
                                        if (res) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WelcomeScreen(),
                                            ),
                                            (route) => false,
                                          );
                                        } else {
                                          EasyLoading.showToast(
                                              "Nom d'utilisateur ou mot de passe erroné !");
                                          return;
                                        }
                                      });
                                    },
                              child: val == true
                                  ? const SpinKitWave(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'CONNECTER',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
