import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../main.dart'; // This is where the notifications plugin is initialized

class WebSocketService {
  final String serverUrl;
  late WebSocketChannel _channel;
  final StreamController<String> _messageController = StreamController.broadcast();

  WebSocketService({required this.serverUrl});

  /// Connect to the WebSocket server
  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    print('Connected to WebSocket: $serverUrl');

    /// Listen to incoming messages
    _channel.stream.listen(
          (message) {
        // Add the message to the stream for subscribers
        _messageController.add(message);

        // Show a local notification
        _showNotification("New Notification", message);

        print('Received: $message');
      },
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket connection closed.');
      },
    );
  }

  /// Expose messages as a Stream
  Stream<String> get messages => _messageController.stream;

  /// Send a message
  void sendMessage(Map<String, dynamic> message) {
    final encodedMessage = json.encode(message);
    _channel.sink.add(encodedMessage);
    print('Sent: $encodedMessage');
  }

  /// Close the connection
  void disconnect() {
    _channel.sink.close();
    _messageController.close();
    print('Disconnected from WebSocket');
  }

  /// Show a local notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('channel_id', 'Notifications',
        channelDescription: 'Channel for receiving WebSocket notifications',
        importance: Importance.high,
        priority: Priority.high);

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }
}
