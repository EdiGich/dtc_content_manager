import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtc_content_manager/services/auth_service.dart';
import 'package:dtc_content_manager/views/dashboard_page.dart';
import 'package:dtc_content_manager/views/login_page.dart';
import 'package:dtc_content_manager/views/offline_page.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  final AuthService _authService = AuthService();
  final storage = GetStorage();

  Future<void> login() async {
    isLoading.value = true;

    try {
      // Add timeout to the AuthService login call
      final tokenData = await _authService.login(username.value, password.value).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Server timed out'),
      );

      // Store the token securely in GetStorage
      await storage.write('authToken', tokenData['access']);

      Get.snackbar(
        'Login Success',
        'You are now logged in',
        backgroundColor: Colors.teal,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.off(() => DashboardPage());
    } on SocketException catch (e) {
      // Network error (e.g., no internet)
      _handleServerOffline('No internet connection. Please check your network.');
      // print('SocketException: $e');
    } on TimeoutException catch (e) {
      // Server timeout (e.g., server too slow)
      _handleServerOffline('Server is taking too long to respond. Please try again later.');
      // print('TimeoutException: $e');
    } catch (e) {
      // Handle server unreachable or unexpected response
      String errorMessage;
      if (e.toString().contains('<html') || e.toString().contains('Coming Soon')) {
        errorMessage = 'Requested server is not reachable. Please try again later.';
        Get.snackbar(
          'Login Failed',
          errorMessage,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // _handleServerOffline(errorMessage); // Redirect to OfflinePage
      } else if (e.toString().contains('401')) {
        errorMessage = 'Invalid username or password.';
        Get.snackbar(
          'Login Failed',
          errorMessage,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        errorMessage = 'Login failed: ${e.toString()}';
        Get.snackbar(
          'Login Failed',
          errorMessage,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      // print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await storage.remove('authToken');
      Get.snackbar(
        'Logout Success',
        'You have been logged out',
        backgroundColor: Colors.teal,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      // print('Logout error: $e');
    }
  }

  void _handleServerOffline(String message) {
    Get.snackbar(
      'Server Unavailable',
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
    Get.to(() => OfflinePage(retryCallback: _retryLogin));
  }

  void _retryLogin() {
    Get.back(); // Close OfflinePage
    login(); // Retry login
  }
}