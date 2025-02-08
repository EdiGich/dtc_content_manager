import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late WebSocketService _webSocketService;
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();

    // Initialize WebSocket connection
    // _webSocketService = WebSocketService(serverUrl: 'ws://127.0.0.1:8000/ws/notifications/');
    _webSocketService = WebSocketService(serverUrl: 'wss://codenaican.pythonanywhere.com/ws/notifications/');

    _webSocketService.connect();

    // Listen to WebSocket messages
    _webSocketService.messages.listen((message) {
      setState(() {
        _messages.add(message);
      });
      print('Received: $message');
    });
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_messages[index]),
          );
        },
      ),
    );
  }
}
