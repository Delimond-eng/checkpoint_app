import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RealtimeDataProvider<T> {
  final StreamController<T> _dataStreamController = StreamController<T>();
  late Stream<T> dataStream;
  final String baseURL = "http://salama.uco.rod.mybluehost.me/api";

  RealtimeDataProvider({required String url}) {
    dataStream = _dataStreamController.stream;
    _init(url);
  }

  void _init(String url) {
    Duration fetchInterval =
        const Duration(seconds: 5); // Intervalle de rafraîchissement

    Stream.periodic(fetchInterval).listen((_) async {
      try {
        final response = await http.get(
          Uri.parse("$baseURL$url"),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          _dataStreamController.add(data as T);
        } else {
          throw Exception('Erreur lors de la récupération des données');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Erreur : $e');
        }
      }
    });
  }

  void dispose() {
    _dataStreamController.close();
  }
}
