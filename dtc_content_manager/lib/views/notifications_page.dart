import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late WebSocketService _webSocketService;
  List<String> _messages = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _webSocketService = WebSocketService(
      serverUrl: 'wss://delicioustumainicaterers.pythonanywhere.com/ws/notifications/',
    );

    _webSocketService.connect();

    _webSocketService.messages.listen(
          (message) {
        setState(() {
          _messages.add(message);
          _isConnected = true;
        });
        print('Received: $message');
      },
      onError: (error) {
        setState(() {
          _isConnected = false;
        });
        print('Stream Error: $error');
      },
      onDone: () {
        setState(() {
          _isConnected = false;
        });
        print('Stream Done');
      },
    );
  }

  void _reconnect() {
    _webSocketService.disconnect();
    _initializeWebSocket();
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
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reconnect,
            tooltip: 'Reconnect',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No notifications yet'))
                : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(_messages[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}