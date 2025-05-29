import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Api {
  //static String baseUrl = 'http://salama.uco.rod.mybluehost.me/api';
  static String baseUrl = 'http://192.168.11.223:8000/api';

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
        // --- Gérer Multipart (photo + données imbriquées)
        var request = http.MultipartRequest(method.toUpperCase(), fullUrl);
        request.headers.addAll(headers);

        if (body != null) {
          for (var entry in body.entries) {
            if (entry.value is Map) {
              // Pour les sous-objets comme "scan"
              (entry.value as Map).forEach((subKey, subValue) {
                if (subValue != null) {
                  request.fields['${entry.key}[$subKey]'] = subValue.toString();
                }
              });
            } else {
              if (entry.value != null) {
                request.fields[entry.key] = entry.value.toString();
              }
            }
          }
        }
        // Ajouter les fichiers
        for (var entry in files.entries) {
          var fileBytes = await entry.value.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            entry.key,
            fileBytes,
            filename: entry.value.path.split("/").last,
          );
          request.files.add(multipartFile);
        }
        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // --- Gérer POST normal (JSON)
        switch (method.toLowerCase()) {
          case 'post':
            response = await http.post(
              fullUrl,
              headers: headers,
              body: jsonEncode(body ?? {}),
            );
            break;
          case 'get':
            response = await http.get(fullUrl, headers: headers);
            break;
          case 'put':
            response = await http.put(
              fullUrl,
              headers: headers,
              body: jsonEncode(body ?? {}),
            );
            break;
          default:
            throw Exception("Méthode HTTP non prise en charge : $method");
        }
      }

      if (kDebugMode) {
        print(response.body);
      }
      // --- Réponse OK
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print("Erreur HTTP ${response.statusCode}: ${response.body}");
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
