import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

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
      throw Exception('Failed to load events');
    }
  }

  // Create a new event
  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    final String url = '${baseUrl}events/';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(eventData),
    );

    if (response.statusCode == 201) {
      return true; // Event created successfully
    } else {
      throw Exception('Failed to create event');
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
