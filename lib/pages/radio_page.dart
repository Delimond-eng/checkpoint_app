import 'package:checkpoint_app/constants/styles.dart';
import 'package:checkpoint_app/kernel/services/talkie_walkie_service.dart';
import 'package:checkpoint_app/themes/app_theme.dart';
import 'package:checkpoint_app/widgets/svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global/controllers.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  final talkieWalkieInstance = TalkieWalkieService();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    talkieWalkieInstance.checkMicrophonePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 25.0,
            ).paddingRight(5),
            Text("Talkie walkie".toUpperCase()),
          ],
        ),
        actions: [
          Obx(
            () => CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                authController.userSession.value.fullname!.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ).marginAll(8.0),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Svg(
              path: "radio-3-line.svg",
              size: 40.0,
              color: primaryColor,
            ).paddingBottom(8.0),
            const Text(
              "Laissez votre doigt enfoncé sur le bouton pour parler et emettre en message sur ce canal privé !",
              textAlign: TextAlign.center,
            ).paddingBottom(8.0),
            BtnSpeach(
              isRecording: isRecording,
              /* onPressed: () async {
                final AudioPlayer player = AudioPlayer();
                await player.play(UrlSource(
                    "http://192.168.43.146:8000/storage/audios/9yg8K07EyERSpkYqq3qQ4Clz5benKcgXibHzajq6.ogg"));
              }, */
              onLongPress: (details) async {
                setState(() {
                  isRecording = true;
                });
                await talkieWalkieInstance.startRecording();
              },
              onLongPressUp: (details) async {
                setState(() {
                  isRecording = false;
                });
                var url = await talkieWalkieInstance.stopRecording();
                await talkieWalkieInstance.sendAudio(url!);
              },
            )
          ],
        ).marginAll(15.0),
      ),
    );
  }
}

class BtnSpeach extends StatelessWidget {
  final bool isRecording;
  final VoidCallback? onPressed;
  final Function(TapDownDetails details) onLongPress;
  final Function(TapUpDetails details) onLongPressUp;

  const BtnSpeach({
    super.key,
    required this.onLongPress,
    required this.onLongPressUp,
    this.isRecording = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: 100.0,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          width: 2.0,
          color: isRecording ? Colors.green : primaryColor,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          gradient: LinearGradient(
            colors: isRecording
                ? [Colors.green, Colors.green.shade300]
                : [primaryColor, primaryMaterialColor.shade300],
          ),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(80.0),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(80.0),
            onTapDown: onLongPress,
            onTapUp: onLongPressUp,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isRecording ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                  color: whiteColor,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
