// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtc_content_manager/views/login_page.dart';
import 'package:get_storage/get_storage.dart';
import 'views/offline_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/websocket_service.dart'; // Added for WebSocket Service
import 'views/notifications_page.dart';

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize local notifications
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
  late WebSocketService _webSocketService; // WebSocket Service instance

  @override
  void initState() {
    super.initState();

    // Initialize WebSocket Service
    _webSocketService = WebSocketService(
      serverUrl: 'wss://codenaican.pythonanywhere.com/ws/notifications/', // WebSocket URL
    );
    _webSocketService.connect();
    // serverUrl: 'ws://127.0.0.1:8000/ws/notifications/',

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
  void dispose() {
    _webSocketService.disconnect(); // Disconnect WebSocket when widget is disposed
    super.dispose();
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
    ); // FutureBuilder
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
