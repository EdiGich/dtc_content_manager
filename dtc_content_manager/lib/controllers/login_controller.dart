// // lib/controllers/login_controller.dart

// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class LoginController extends GetxController {
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   final storage = const FlutterSecureStorage();

//   Future<void> login(String username, String password) async {
//     isLoading.value = true;
//     errorMessage.value = '';

//     final url = Uri.parse(
//         'http://127.0.0.1:8000/api/token/'); // Update with your backend URL

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'username': username,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         await storage.write(key: 'access_token', value: data['access']);
//         await storage.write(key: 'refresh_token', value: data['refresh']);

//         // Navigate to Dashboard
//         Get.offNamed('/dashboard');
//       } else {
//         final data = json.decode(response.body);
//         errorMessage.value = data['detail'] ?? 'Login failed';
//       }
//     } catch (e) {
//       errorMessage.value = 'An error occurred. Please try again.';
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

// lib/controllers/login_controller.dart

import 'package:get/get.dart';
import 'package:dtc_content_manager/services/auth_service.dart';
import 'package:dtc_content_manager/views/dashboard_page.dart';
import 'package:dtc_content_manager/views/login_page.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  final AuthService _authService = AuthService();
  final storage=GetStorage(); //the storage instance

  Future<void> login() async {
    isLoading.value = true;

    try {
      // Call the login method from AuthService
      final tokenData =
          await _authService.login(username.value, password.value);
      // Handle the token
      // ignore: avoid_print

      //storing of the token securely in GetStorage
      storage.write('authToken', tokenData['access']);

      //print('Token: ${tokenData['access']}');

      Get.snackbar('Login Success', 'You are now logged in');
      Get.off(DashboardPage());
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      // Clear the stored token
      await storage.remove('authToken');
      Get.snackbar('Logout Success', 'You have been logged out');
      Get.offAll(LoginPage()); // Navigate back to the login page
    } catch (e) {
      Get.snackbar('Logout Failed', e.toString());
    }
  }
}
