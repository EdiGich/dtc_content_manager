import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
// import 'package:http_parser/http_parser.dart';


class NewsEventsService {
  final String baseUrl = 'http://10.0.2.2:8000/api/';
  final String authToken = GetStorage().read('authToken');


  Future<List<dynamic>> fetchNews() async {
    final String url = '${baseUrl}news/';
    // final token = GetStorage().read('authToken');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load news');
    }
  }

  //fetch all events
  Future<List<dynamic>> fetchEvents() async {
    final String url = '${baseUrl}events/';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load events');
    }
  }

  // Create a new event
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    // Build the URL as a string
    final String url = '${baseUrl}events/';
    final token = GetStorage().read('authToken') ?? ''; // Retrieve the auth token

    try {
      // Parse the URL into a Uri object
      final Uri uri = Uri.parse(url);

      // Prepare the multipart request
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token' // Include the authorization header
        ..fields['title'] = eventData['title']
        ..fields['description'] = eventData['description']
        ..fields['date'] = eventData['date']
        ..fields['time'] = eventData['time'];

      // Add the image file if it exists
      if (eventData['image'] != null) {
        final imageFile = File(eventData['image'].path);
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      // Send the request
      final response = await request.send();

      // Handle the response
      if (response.statusCode == 201) {
        print('Event created successfully');
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Failed to create event: $responseBody');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }




  // Update an existing event
  Future<bool> updateEvent(int eventId, Map<String, dynamic> updatedData) async {
    final String url = '${baseUrl}events/$eventId/';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      return true; // Event updated successfully
    } else {
      throw Exception('Failed to update event');
    }
  }

// Delete an event
  Future<bool> deleteEvent(int eventId) async {
    final String url = '${baseUrl}events/$eventId/';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      return true; // Event deleted successfully
    } else {
      throw Exception('Failed to delete event');
    }
  }
}
