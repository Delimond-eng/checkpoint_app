import 'package:http/http.dart' as http;

import 'dart:convert';

class Api {
  //static String baseUrl = 'http://192.168.1.196:8000/api';
  //static String baseUrl = 'http://10.0.2.2:8000/api';
  static String baseUrl = 'http://admin.salama-rdc.com/api';
  // ignore: slash_for_doc_comments
  /** 
    @param url: add url to endpoint
    @param method[post, get]
    @param body[Map<String, dynamic> body] to pass from endpoint
    @param headers[http Headers]
  **/
  static Future request(
      {String? method, String? url, Map<String, dynamic>? body}) async {
    late http.Response response;
    switch (method) {
      case "post":
        response = await http.post(
          Uri.parse("$baseUrl/$url"),
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'},
        );
        break;
      case "get":
        response = await http.get(
          Uri.parse("$baseUrl/$url"),
          headers: {'Content-Type': 'application/json'},
        );
        break;
      default:
        response = await http.get(
          Uri.parse("$baseUrl/$url"),
          headers: {'Content-Type': 'application/json'},
        );
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}
