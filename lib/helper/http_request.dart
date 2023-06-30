// import 'dart:convert';

import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

class ApiClient extends GetConnect implements GetxService {
  final String baseUri;
  String token = '';
  late Map<String, String> _mainheaders;
  ApiClient({required this.baseUri}) {
    baseUrl = baseUri;
    timeout = const Duration(seconds: 30);
    _mainheaders = {
      'Content-type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    };
  }

  Future<Response> getData(String uri) async {
    try {
      Response response = await get(uri);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
}

// class HttpRequest {
//   static Future<dynamic> getRequests(Uri url) async {
//     // http.Response response = await http.get(url);
//     var link = await http.get(url);

//     http.Response response = link;

//     try {
//       if (response.statusCode == 200) {
//         String jsonData = response.body;
//         print("This is the response body $jsonData");
//         var decodedData = jsonDecode(jsonData);
//         print("This is the decodededJson: $decodedData");
//         return decodedData;
//       } else {
//         return 'failed';
//       }
//     } catch (e) {
//       return 'failed';
//     }
//   }
// }
