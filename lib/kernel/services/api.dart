import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Api {
  static String baseUrl = 'http://salama.uco.rod.mybluehost.me/api';

  /// Fonction pour faire des requêtes HTTP (GET, POST, PUT, DELETE, UPLOAD)
  static Future<dynamic> request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, File>? files,
  }) async {
    final fullUrl = Uri.parse('$baseUrl/$url');
    headers ??= {'Content-Type': 'application/json'};
    http.Response response;

    try {
      if (files != null && files.isNotEmpty) {
        // Pour l'envoi de fichiers (multipart)
        var request = http.MultipartRequest(method.toUpperCase(), fullUrl);
        // Ajoute les headers (sauf Content-Type, géré automatiquement)
        request.headers.addAll(headers);
        // Ajoute les champs texte
        if (body != null) {
          request.fields.addAll(
              body.map((key, value) => MapEntry(key, value.toString())));
        }

        // Ajoute les fichiers
        for (var entry in files.entries) {
          var fileStream = http.MultipartFile.fromBytes(
            entry.key,
            await entry.value.readAsBytes(),
            filename: entry.value.path.split("/").last,
          );
          request.files.add(fileStream);
        }
        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Pour les requêtes normales (JSON)
        switch (method.toLowerCase()) {
          case 'post':
            response = await http.post(
              fullUrl,
              headers: headers,
              body: jsonEncode(body ?? {}),
            );
            break;
          case 'get':
          default:
            response = await http.get(fullUrl, headers: headers);
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print("Erreur ${response.statusCode}: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la requête : $e');
      }
      return null;
    }
  }
}
