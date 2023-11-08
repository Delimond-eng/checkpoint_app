import 'package:checkpoint_app/themes/colors.dart';
import 'package:checkpoint_app/widgets/dashline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  ValueNotifier<String> result = ValueNotifier("");
  ValueNotifier<bool> scannig = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: screenSize.height * .4,
            width: screenSize.width,
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/nfc-1.svg",
                          height: 22.0,
                          colorFilter: const ColorFilter.mode(
                            scaffoldColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        const Text(
                          "CHECK POINT APP",
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            color: lightColor,
                            fontFamily: 'Staatliches',
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const DashedLine(
                  color: Color(0xFF7b63d7),
                  height: .5,
                  space: EdgeInsets.symmetric(horizontal: 15.0, vertical: 2.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 40.0,
                        width: 40.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: scaffoldColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/user.svg',
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                secondaryColor,
                                BlendMode.srcIn,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gaston Delimond",
                            style: TextStyle(
                              color: Color.fromARGB(255, 190, 174, 231),
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Bienvenue agent !",
                            style: TextStyle(
                              color: Color(0xFF7560a9),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: screenSize.width,
                  height: screenSize.height * .737,
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FutureBuilder<bool>(
                          future: NfcManager.instance.isAvailable(),
                          builder: (context, ss) => ss.data != true
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/nfc-3.svg",
                                        height: 40.0,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.red,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        'NfcManager.isAvailable(): ${ss.data}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: secondaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ValueListenableBuilder<bool>(
                                  builder: (context, value, __) {
                                    if (!value && result.value.isEmpty) {
                                      return scanStartMessage();
                                    } else {
                                      return scanLoading();
                                    }
                                  },
                                  valueListenable: scannig,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: secondaryColor,
        child: SvgPicture.asset(
          "assets/icons/nfc-2.svg",
          height: 30,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget scanLoading() {
    return ValueListenableBuilder<String>(
      valueListenable: result,
      builder: (context, value, _) {
        if (value.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset("assets/animations/nfc_scan_1.json"),
              const Text(
                'Veuillez approcher le dispositif près de la puce nfc pour scanner !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset("assets/animations/nfc_scan_1.json"),
              Text(
                'Pointage effectué avec succès : $value !',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget scanStartMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/icons/idea.svg",
          height: 40.0,
          colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
        ),
        const Text(
          'Veuillez appuyer sur le bouton en bas à droite de votre écran pour lancer le pointage !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            color: secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
