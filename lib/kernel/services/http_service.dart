// ignore_for_file: unnecessary_null_comparison

import 'package:dio/dio.dart';

class HttpService {
  //[baseURL]
  static String baseURL = 'http://backend.chezyo.net';

  //String [url]  request url
  static Future<dynamic> getRequest(String url) async {
    var dioInstance = Dio();
    try {
      var results = await dioInstance.get('$baseURL/$url');
      if (results != null) {
        if (results.statusCode == 200) {
          return results.data;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //String [url] http request url
  //Map<String,dynamic> [data] http post data body
  static Future<dynamic> postRequest(String url,
      {required Map<String, dynamic> data}) async {
    var dioInstance = Dio();
    try {
      var results = await dioInstance.post('$baseURL/$url', data: data);
      if (results != null) {
        if (results.statusCode == 200) {
          return results.data;
        } else {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
