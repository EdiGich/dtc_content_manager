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

  String filter = 'All';
  String searchQuery = '';

  final String messagesApiUrl = 'https://delicioustumainicaterers.pythonanywhere.com/api/messages/';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
        applyFilterAndSearch();
      });
    });
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
          applyFilterAndSearch();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void applyFilterAndSearch() {
    List<dynamic> tempList = messages;

    // Apply status filter, handling both string and integer status values
    if (filter == 'Read') {
      tempList = tempList.where((m) => m['status'] == '1' || m['status'] == 1).toList();
    } else if (filter == 'Not Read') {
      tempList = tempList.where((m) => m['status'] == '0' || m['status'] == 0).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      tempList = tempList.where((m) {
        final name = (m['name'] ?? 'Unknown Sender').toString().toLowerCase();
        final message = (m['message'] ?? 'No content').toString().toLowerCase();
        return name.contains(searchQuery.toLowerCase()) || message.contains(searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      filteredMessages = tempList;
    });
  }

  String formatDate(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMessages,
            tooltip: 'Refresh Messages',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filter = value;
                applyFilterAndSearch();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Messages')),
              const PopupMenuItem(value: 'Read', child: Text('Read Messages')),
              const PopupMenuItem(value: 'Not Read', child: Text('Not Read Messages')),
            ],
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Messages',
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.white,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              )
                  : hasError
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load messages',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchMessages,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : filteredMessages.isEmpty
                  ? const Center(
                child: Text(
                  'No messages available',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final message = filteredMessages[index];
                  final isRead = message['status'] == '1' || message['status'] == 1;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isRead
                            ? Colors.green.withOpacity(0.5)
                            : Colors.blue.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: isRead ? Colors.green : Colors.blue,
                            child: Text(
                              message['name']?[0] ?? '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          if (!isRead)
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        message['name'] ?? 'Unknown Sender',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      subtitle: Text(
                        message['message'] ?? 'No content',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      trailing: Text(
                        formatDate(message['sent_at'] ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessageDetailsPage(
                              message: message,
                              onStatusUpdated: fetchMessages, // Pass refresh callback
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}