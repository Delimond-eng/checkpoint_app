import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '/widgets/dashline.dart';
import '/themes/colors.dart';
import '/widgets/tag_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<List<String>> results = ValueNotifier([]);
  ValueNotifier<bool> scanning = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
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
          Column(
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
              Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
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
                        color: Colors.green,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/user.svg',
                            height: 22,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
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
                            color: Colors.green,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Bienvenue agent !",
                          style: TextStyle(
                            color: Color(0xFF7560a9),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height * .737,
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  decoration: BoxDecoration(
                    color: scaffoldColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: results,
                      builder: (context, values, __) {
                        if (values.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FutureBuilder<bool>(
                                future: NfcManager.instance.isAvailable(),
                                builder: (context, ss) => ss.data != true
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Lottie.asset(
                                                "assets/animations/nfc_fail.json"),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            const Text(
                                              'Veuillez activer l\'option NFC pour utiliser cette application ',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: secondaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : scanStartMessage(),
                              ),
                              const SizedBox(
                                height: 40.0,
                              ),
                              SizedBox(
                                width: screenSize.width - 20,
                                height: 50.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    elevation: 10.0,
                                  ),
                                  onPressed: showControlStartBottomSheet,
                                  child: Text(
                                    'Commencer la patrouille'.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: values.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    return TagCard(
                                      index: index,
                                      tag: values[index],
                                    );
                                  },
                                  separatorBuilder: (_, __) => const SizedBox(
                                    height: 8.0,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: screenSize.width - 20,
                                height: 50.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    elevation: 10.0,
                                  ),
                                  onPressed: showControlStartBottomSheet,
                                  child: Text(
                                    'Continuer la patrouille'.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget scanStartMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/icons/idea.svg",
          height: 80.0,
          colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Veuillez appuyer sur le bouton en bas pour lancer la patrouille des points tags !',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.red,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Future<void> startReadTagSession() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      /**
       * reinit result
      */

      /**
       * data
      */
      var data = tag.data;
      var payload = data["ndef"]["cachedMessage"]["records"][0]["payload"];
      var stringPayload = String.fromCharCodes(payload);

      /**
       * FORMAT TAG
      */
      String formattedTag = stringPayload.substring(3);

      /**
       * CHECK IF TAG ISN'T EXIST
      */
      if (results.value.isEmpty || !results.value.contains(formattedTag)) {
        results.value.add(formattedTag);
      }
      if (kDebugMode) {
        print(stringPayload);
      }
    });
  }

  //ALLOW TO START NEW CHECK POINT SESSION
  void showControlStartBottomSheet() async {
    /**
     * Start read tags session
    */
    startReadTagSession();
    var screenSize = MediaQuery.of(context).size;

    /**
     * OPEN LOADING BOTTOM SHEET
    */
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Lottie.asset("assets/animations/nfc_scan_1.json"),
                  ),
                  const Text(
                    'Faites la patrouille du site en scannant chaque point tag du site!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    width: screenSize.width,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        elevation: 10.0,
                      ),
                      onPressed: () {
                        NfcManager.instance.stopSession();
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: Text(
                        'Terminer la patrouille en cours'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
