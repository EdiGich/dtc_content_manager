// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtc_content_manager/views/login_page.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DTC Content Manager',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeService().theme, // Control theme mode
      home: LoginPage(),
    );
  }
}

class ThemeService {
  final _key = 'isDarkMode';

  // Save theme mode
  void saveTheme(bool isDarkMode) {
    GetStorage().write(_key, isDarkMode);
  }

  // Load theme mode
  bool isDarkMode() {
    return GetStorage().read(_key) ?? false;
  }

  // Get current theme mode
  ThemeMode get theme => isDarkMode() ? ThemeMode.dark : ThemeMode.light;

  // Toggle theme
  void switchTheme() {
    saveTheme(!isDarkMode());
    Get.changeThemeMode(isDarkMode() ? ThemeMode.dark : ThemeMode.light);
  }
}

