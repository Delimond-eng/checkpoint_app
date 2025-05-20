import 'package:animate_do/animate_do.dart';
import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/kernel/models/user.dart';
import 'package:checkpoint_app/kernel/services/recognition_service.dart';
import 'package:checkpoint_app/widgets/costum_button.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
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

  late FaceRecognitionController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller =
        Provider.of<FaceRecognitionController>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.isModelInitializing && !_controller.isModelLoaded) {
        _controller.initializeModel();
        setState(() => isLoading = true);
        _controller
            .addKnownFacesFromRemoteAPI()
            .then((res) => setState(() => isLoading = false));
      }
    });
  }

  Future<void> loadAgent() async {
    setState(() => isLoading = true);

    HttpManager.getAllAgents().then((agents) {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: headerColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ZoomIn(
                    child: Image.asset(
                      "assets/images/logo.png",
                      height: MediaQuery.of(context).size.width * .4,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  FadeInUp(
                    child: const Text(
                      "RD TASKS",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w900,
                        color: whiteColor,
                        fontFamily: 'Staatliches',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              ZoomIn(
                child: Container(
                  decoration: BoxDecoration(
                    color: scaffoldColor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
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
                            title: "Connecter",
                            bgColor: secondaryColor,
                            isLoading: isLoading,
                            labelColor: whiteColor,
                            onPress: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
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
        EasyLoading.showToast(res.toString());
        return;
      }
    });
  }
}
