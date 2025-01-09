// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtc_content_manager/views/login_page.dart';
import 'package:get_storage/get_storage.dart';
import 'views/offline_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


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
      home: ConnectivityWrapper(),
    );
  }
}

class ConnectivityWrapper extends StatefulWidget {
  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late Future<ConnectivityResult> _initialConnectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    // Initialize connectivity checks
    _initialConnectivity = Connectivity().checkConnectivity();
    _connectivityStream = Connectivity().onConnectivityChanged;

    // Listen for connectivity changes
    _connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConnectivityResult>(
      future: _initialConnectivity,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_isOffline || snapshot.data == ConnectivityResult.none) {
          return OfflinePage(
            retryCallback: () {
              setState(() {
                _initialConnectivity = Connectivity().checkConnectivity();
              });
            },
          );
        }

        return LoginPage(); // Replace with your app's main content
      },
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

