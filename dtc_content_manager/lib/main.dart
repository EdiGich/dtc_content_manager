// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtc_content_manager/views/login_page.dart';
import 'package:get_storage/get_storage.dart';
import 'views/offline_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/websocket_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal.shade50,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme, // Apply Poppins to light theme
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.teal),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            shape: WidgetStateProperty.resolveWith((states) {
              final isDarkMode = Theme.of(context).brightness == Brightness.dark;
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isDarkMode
                    ? const BorderSide(color: Colors.white70, width: 1)
                    : BorderSide.none,
              );
            }),
            elevation: WidgetStateProperty.all(5),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.teal),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey.shade900,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme, // Apply Poppins to dark theme
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.teal),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white70, width: 1), // Border in dark mode
              ),
            ),
            elevation: WidgetStateProperty.all(5),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      themeMode: ThemeService().theme,
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
  late WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();

    // Initialize WebSocket Service
    _webSocketService = WebSocketService(
      serverUrl: 'wss://codenaican.pythonanywhere.com/ws/notifications/',
    );
    _webSocketService.connect();

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
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConnectivityResult>(
      future: _initialConnectivity,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.teal.shade100, Colors.teal.shade50],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Checking Connection...',
                      style: TextStyle(fontSize: 16, color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ),
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

        return LoginPage();
      },
    );
  }
}

class ThemeService {
  final _key = 'isDarkMode';

  void saveTheme(bool isDarkMode) {
    GetStorage().write(_key, isDarkMode);
  }

  bool isDarkMode() {
    return GetStorage().read(_key) ?? false;
  }

  ThemeMode get theme => isDarkMode() ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    saveTheme(!isDarkMode());
    Get.changeThemeMode(isDarkMode() ? ThemeMode.dark : ThemeMode.light);
  }
}