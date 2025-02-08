import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class MessageDetailsPage extends StatelessWidget {
  final Map<String, dynamic> message;

  const MessageDetailsPage({required this.message});

  // Function to update the status of the message
  void updateMessageStatus(BuildContext context, int messageId, int newStatus) async {
    // final String updateUrl = 'http://10.0.2.2:8000/api/messages/$messageId/';
    final String updateUrl = 'http://codenaican.pythonanywhere.coms/api/messages/$messageId/';

    final token = GetStorage().read('authToken');

    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Message marked as "${newStatus == 1 ? 'Read' : 'Not Read'}".',
              style: const TextStyle(fontSize: 16),
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print('Failed to update message status: ${response.body}');
      }
    } catch (e) {
      print('Error updating message status: $e');
    }
  }

  // Function to launch a phone dialer
  void launchDialer(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is unavailable.')),
      );
      return;
    }
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer.')),
      );
    }
  }

  // Function to launch the email app
  void launchEmailApp(BuildContext context, String? emailAddress) async {
    if (emailAddress == null || emailAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email address is unavailable.')),
      );
      return;
    }
    final Uri url = Uri(scheme: 'mailto', path: emailAddress);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${message['name'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${message['email'] ?? 'Not provided'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Phone: ${message['phone'] ?? 'Not provided'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Message:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message['message'] ?? 'No content available.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => launchDialer(context, message['phone']),
                  child: const Text('Call'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => launchEmailApp(context, message['email']),
                  child: const Text('Email'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => updateMessageStatus(context, message['id'], 1), // Mark as read
                  child: const Text('Mark as Read'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => updateMessageStatus(context, message['id'], 0), // Mark as unread
                  child: const Text('Mark as Unread'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
