import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  ValueNotifier<bool> scannig = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check point application"),
      ),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) => ss.data != true
              ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
              : Flex(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  direction: Axis.vertical,
                  children: [
                    ValueListenableBuilder<bool>(
                      builder: (context, value, __) {
                        if (!value) {
                          return Flexible(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              constraints: const BoxConstraints.expand(),
                              child: Center(
                                child: ValueListenableBuilder<dynamic>(
                                  valueListenable: result,
                                  builder: (context, value, _) {
                                    if (value == null) {
                                      return const Text(
                                          "Press button to read nfc tag !");
                                    } else {
                                      return Text(
                                        '${value ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Lottie.asset(
                            "assets/animations/nfc_scan_1.json",
                          );
                        }
                      },
                      valueListenable: scannig,
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tagRead,
        child: const Icon(Icons.nfc),
      ),
    );
  }

  void _tagRead() {
    scannig.value = true;
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var data = tag.data;
      var payload = data["ndef"]["cachedMessage"]["records"][0]["payload"];
      var stringPayload = String.fromCharCodes(payload);
      result.value = stringPayload.substring(3);
      NfcManager.instance.stopSession();
      scannig.value = false;
      if (kDebugMode) {
        print(stringPayload);
      }
    });
  }
}
