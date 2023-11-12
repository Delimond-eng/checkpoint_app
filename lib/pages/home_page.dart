import 'package:animate_do/animate_do.dart';
import '/global/controllers.dart';
import '/global/modal.dart';
import '/kernel/services/http_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '/themes/colors.dart';
import '/widgets/tag_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final loading = ValueNotifier<bool>(false);
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
                        "PATROL TAG",
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
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${authController.userSession.value.nom!} ${authController.userSession.value.prenom}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            "Bienvenue agent !",
                            style: TextStyle(
                              color: Color(0xFF7560a9),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
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
                    child: Obx(
                      () => (tagsController.tags.isEmpty)
                          ? Column(
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
                                ValueListenableBuilder<bool>(
                                  valueListenable: loading,
                                  builder: (context, value, _) => SizedBox(
                                    width: screenSize.width - 20,
                                    height: 50.0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        disabledBackgroundColor:
                                            Colors.grey.shade700,
                                        elevation: 10.0,
                                      ),
                                      onPressed: showControlStartBottomSheet,
                                      child: value == true
                                          ? const Padding(
                                              padding: EdgeInsets.all(18.0),
                                              child: SpinKitThreeBounce(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Commencer la patrouille'
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: tagsController.tags.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      return TagCard(
                                        tagName: tagsController.tags[index]
                                            ['tag_name'],
                                        tag: tagsController.tags[index]
                                            ['tag_id'],
                                      );
                                    },
                                    separatorBuilder: (_, __) => const SizedBox(
                                      height: 8.0,
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => tagsController.patrolCode.value != 0
                                      ? Row(
                                          children: [
                                            Flexible(
                                              child: SizedBox(
                                                width: screenSize.width - 20,
                                                height: 50.0,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.orange,
                                                    elevation: 10.0,
                                                  ),
                                                  onPressed:
                                                      showControlStartBottomSheet,
                                                  child: const Text(
                                                    'Continuer la patrouille',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8.0,
                                            ),
                                            Flexible(
                                              child: SizedBox(
                                                width: screenSize.width - 20,
                                                height: 50.0,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                    elevation: 10.0,
                                                  ),
                                                  onPressed: () {
                                                    DGCustomDialog.showInteraction(
                                                        context,
                                                        message:
                                                            'Etes-vous sûr de vouloir clôturer la patrouille en cours  ?',
                                                        onValidated: () {
                                                      tagsController
                                                          .closePatrol();
                                                    });
                                                  },
                                                  child: const Text(
                                                    'Terminer la patrouille',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                )
                              ],
                            ),
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

      DGCustomDialog.showLoading(context);
      var manager = HttpManager();
      manager.savePatrol(tag: formattedTag).then((res) {
        DGCustomDialog.dismissLoding();
        if (res != null) {
          /**
          * CHECK IF TAG ISN'T EXIST
          */
          tagsController.addTag(formattedTag, res['nom']);
        } else {
          EasyLoading.showInfo("Echec de traitement des informations !");
          return;
        }
      });

      if (kDebugMode) {
        print(stringPayload);
      }
    });
  }

  //ALLOW TO START NEW CHECK POINT SESSION
  void showControlStartBottomSheet() async {
    var manager = HttpManager();
    loading.value = true;
    manager.startPatrol().then((res) {
      loading.value = false;
      if (res != 0) {
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
                        child:
                            Lottie.asset("assets/animations/nfc_scan_1.json"),
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
                      Obx(
                        () => Row(
                          children: [
                            if (tagsController.tags.isNotEmpty) ...[
                              ZoomIn(
                                child: Container(
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.greenAccent.withOpacity(.6),
                                      width: .7,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        tagsController.tags.length
                                            .toString()
                                            .padLeft(2, "0"),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.0,
                                          color: Colors.green,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                            ],
                            Flexible(
                              child: ZoomIn(
                                child: SizedBox(
                                  width: screenSize.width,
                                  height: 50.0,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      elevation: 10.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    onPressed: () {
                                      NfcManager.instance.stopSession();
                                      Navigator.pop(context);
                                      setState(() {});
                                    },
                                    child: Text(
                                      'Fermer'.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      } else {
        EasyLoading.showInfo("Echec de traitement, reéssayez ultérieurement !");
        return;
      }
    });
  }
}
