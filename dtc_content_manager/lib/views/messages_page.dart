import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'MessageDetailsPage.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<dynamic> messages = [];
  List<dynamic> filteredMessages = [];
  bool isLoading = true;
  bool hasError = false;

  String filter = 'All'; // Filter options: 'All', 'Read', 'Not Read'

  // API URL
  // final String messagesApiUrl = 'http://10.0.2.2:8000/api/messages/';
  final String messagesApiUrl = 'http://codenaican.pythonanywhere.com/api/messages/';
  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final token = GetStorage().read('authToken');
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse(messagesApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        setState(() {
          messages = decodedData;
          applyFilter();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void applyFilter() {
    setState(() {
      if (filter == 'All') {
        filteredMessages = messages;
      } else if (filter == 'Read') {
        filteredMessages = messages.where((m) => m['status'] == '1').toList();
      } else if (filter == 'Not Read') {
        filteredMessages = messages.where((m) => m['status'] == '0').toList();
      }
    });
  }

  String formatDate(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filter = value;
                applyFilter();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Messages'),
              ),
              const PopupMenuItem(
                value: 'Read',
                child: Text('Read Messages'),
              ),
              const PopupMenuItem(
                value: 'Not Read',
                child: Text('Not Read Messages'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text('Failed to load messages'))
          : filteredMessages.isEmpty
          ? const Center(child: Text('No messages available'))
          : ListView.builder(
        itemCount: filteredMessages.length,
        itemBuilder: (context, index) {
          final message = filteredMessages[index];
          final isRead = message['status'] == '1';

          return Container(
            color: isRead
                ? Colors.green.shade100 // Light green for Read
                : Colors.blue.shade100, // Light blue for Not Read
            child: Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(
                  message['name'] ?? 'Unknown Sender',
                  style: TextStyle(
                    fontWeight: isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  message['message'] ?? 'No content',
                  style: TextStyle(
                    fontWeight: isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  formatDate(message['sent_at'] ?? ''),
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageDetailsPage(
                          message: message),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
