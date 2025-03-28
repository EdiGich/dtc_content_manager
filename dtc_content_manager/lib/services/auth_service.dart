// lib/services/auth_service.dart

// ignore_for_file: prefer_const_constructors

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class AuthService extends GetxService {
//   final storage = FlutterSecureStorage();

//   Future<String?> getAccessToken() async {
//     return await storage.read(key: 'access_token');
//   }

//   Future<String?> getRefreshToken() async {
//     return await storage.read(key: 'refresh_token');
//   }

//   Future<void> refreshAccessToken() async {
//     final refreshToken = await getRefreshToken();
//     if (refreshToken == null) return;

//     final url = Uri.parse('http://127.0.0.1:8000/api/token/refresh/');

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'refresh': refreshToken}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         await storage.write(key: 'access_token', value: data['access']);
//       } else {
//         // Handle token refresh failure (e.g., force logout)
//         await storage.deleteAll();
//         Get.offAllNamed('/login');
//       }
//     } catch (e) {
//       // Handle error
//       await storage.deleteAll();
//       Get.offAllNamed('/login');
//     }
//   }

//   init() {}
// }

// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {

  final String baseUrl =
      // 'http://10.0.2.2:8000/api/token/';
      'https://codenaican.pythonanywhere.com/api/token/';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
}
