import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts flutterTts = FlutterTts();

  Future<void> initializeTts() async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    bool isLangAvailable = await flutterTts.isLanguageAvailable("fr-FR");
    if (!isLangAvailable) {
      if (kDebugMode) {
        print("La langue fr-FR n'est pas disponible.");
      }
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }
}
