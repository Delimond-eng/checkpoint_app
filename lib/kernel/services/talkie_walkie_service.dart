import 'dart:async';
import 'dart:io';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:checkpoint_app/global/controllers.dart';
import 'dart:convert';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

class TalkieWalkieService {
  late PusherChannelsClient client;
  late StreamSubscription connectionSubs;

  FlutterSoundRecorder recorder = FlutterSoundRecorder();

  Future<void> checkMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      // Permission granted
    } else {
      // Handle permission denied
    }
  }

  Future<void> initListening() async {
    PusherChannelsPackageLogger.enableLogs();

    const hostOptions = PusherChannelsOptions.fromHost(
      scheme: 'ws', // Utilise 'wss' pour SSL en production
      host: '192.168.43.146',
      key: 'asldkfjs', // Remplace par la vraie clé en production
      shouldSupplyMetadataQueries: true,
      metadata: PusherChannelsOptionsMetadata.byDefault(),
      port: 6001,
    );

    client = PusherChannelsClient.websocket(
        options: hostOptions,
        connectionErrorHandler: (exception, trace, refresh) async {
          print(exception);
          refresh();
        });
    final AudioPlayer player = AudioPlayer();
    final channel = client.publicChannel('talkie-walkie');
    channel.bind('audio.sent').listen((event) async {
      var res = jsonDecode(event.data);
      await player.release();
      if (res['sender'] != "app") {
        String url = res["audioUrl"].toString();
        url = url.replaceAll("127.0.0.1", "192.168.43.146");
        await player.play(AssetSource('sounds/walkie-talkie-off.mp3'));
        await Future.delayed(const Duration(seconds: 2));
        await player.play(UrlSource(url));
      }
    });
    connectionSubs = client.onConnectionEstablished.listen((_) {
      channel.subscribeIfNotUnsubscribed();
    });
    unawaited(client.connect());
  }

  Future<void> startRecording() async {
    try {
      // Vérifier et demander les permissions pour le microphone
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print("Permission microphone refusée");
        return;
      }

      // Initialiser le recorder
      await recorder.openRecorder();

      // Vérifier si l'enregistreur n'est pas déjà en cours
      if (!recorder.isRecording) {
        // Démarrer l'enregistrement avec un chemin personnalisé
        Directory tempDir = await getTemporaryDirectory();
        String path =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp4';

        await recorder.startRecorder(
          toFile: path,
          codec: Codec.aacMP4,
        );
      }
    } catch (e) {
      print('Erreur d\'enregistrement : $e');
    }
  }

  Future<String?> stopRecording() async {
    String? url;
    try {
      if (recorder.isRecording) {
        // Arrêter l'enregistrement
        url = await recorder.stopRecorder();
        // Fermer le recorder
        await recorder.closeRecorder();
      }
    } catch (e) {
      print('Erreur à l\'arrêt de l\'enregistrement : $e');
    }
    return url;
  }

  Future<void> sendAudio(String filePath) async {
    final AudioPlayer player = AudioPlayer();
    var agent = authController.userSession.value;
    try {
      var uri = Uri.parse("${Api.baseUrl}/send.talk");
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = agent.id!.toString();
      request.fields['sender'] = "app";
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));
      var response = await request.send();
      if (response.statusCode == 200) {
        await player.play(AssetSource('sounds/walkie-talkie-off.mp3'));
        print("Audio envoyé avec succès");
      }
    } catch (e) {
      print("error $e");
    }
  }
}
