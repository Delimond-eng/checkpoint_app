import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  FlutterTts flutterTts = FlutterTts();

  Future<void> initializeTts() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.5); // Ajuste la vitesse si nécessaire
    await flutterTts.setPitch(1.0); // Ajuste la tonalité si nécessaire
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }
}
