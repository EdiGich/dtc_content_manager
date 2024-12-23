import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AdminGalleryManagementPage extends StatefulWidget {
  @override
  _AdminGalleryManagementPageState createState() =>
      _AdminGalleryManagementPageState();
}

class _AdminGalleryManagementPageState
    extends State<AdminGalleryManagementPage> {
  List galleryItems = [];
  bool isLoading = true; // Added loading state
  bool hasError = false; // Added error state

  final storage = GetStorage(); // Initialize GetStorage

  @override
  void initState() {
    super.initState();
    fetchGalleryItems();
  }

  Future<void> fetchGalleryItems() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Fetch the JWT token from GetStorage
      // Retrieve token from GetStorage
      final storage = GetStorage();
      String? token = storage.read('authToken'); // Use GetStorage to read the token

      // If no token found, return error - checks if the token exists
      if (token == null) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print('Token not found in storage.');
        return;
      }

      // Send API request
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/galleryitem/manage/'),
        headers: {
          'Authorization': 'Bearer $token',  // Include JWT token in the headers
        },
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Gallery Items: $data");  // Print the response data

        setState(() {
          galleryItems = json.decode(response.body);
          isLoading = false; // Data has been successfully fetched
        });
      } else {
        // Handle HTTP errors
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print('Error: Failed to load gallery items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Network error: $e');
    }
  }

  Future<void> deleteGalleryItem(int id) async {
    if (id == null) {
      // Handle case where ID is null
      print("Item ID is null. Cannot delete.");
      Get.snackbar('Error', 'Failed to delete item. ID not found.');
      return;
    }
    // String? token = storage.read('authToken'); // Read token from GetStorage

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/galleryitem/manage/$id/'),
      headers: {
        // 'Authorization': 'Bearer $token', // Send token in the header
        'Authorization': 'Bearer ${storage.read('authToken')}',
      },
    );

    if (response.statusCode == 204) {
      // If successfully deleted, remove item from list
      setState(() {
        galleryItems.removeWhere((item) => item['id'] == id);
      });
      Get.snackbar('Success', 'Item deleted successfully.');
    } else {
      // Handle error here (optional)
      print('Failed to delete item');
      Get.snackbar('Error', 'Failed to delete item.');
    }
  }

  Future<void> editGalleryItem(int id, Map<String, dynamic> newData) async {
    String? token = storage.read('authToken'); // Read token from GetStorage

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/api/galleryitem/manage/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Send token in the header
      },
      body: json.encode(newData),
    );

    if (response.statusCode == 200) {
      // Update the gallery item in the list
      setState(() {
        final index = galleryItems.indexWhere((item) => item['id'] == id);
        galleryItems[index] = json.decode(response.body);
      });
    } else {
      // Handle error here (optional)
      print('Failed to edit item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Gallery Management'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : hasError
          ? Center(child: Text('Failed to load gallery items')) // Show error message
          : galleryItems.isEmpty
          ? Center(child: Text('No gallery items found')) // Show when list is empty
          : ListView.builder(
        itemCount: galleryItems.length,
        itemBuilder: (context, index) {
          final item = galleryItems[index];

          return ListTile(
            leading: Image.network(
                'http://10.0.2.2:8000${item['image']}'),
            title: Text(item['title'] ?? 'No title'),
            subtitle: Text(item['description'] ?? 'No description'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Open edit dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        final titleController = TextEditingController(
                            text: item['title']);
                        final descriptionController =
                        TextEditingController(
                            text: item['description']);
                        return AlertDialog(
                          title: Text('Edit Gallery Item'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: titleController,
                                decoration: InputDecoration(
                                    labelText: 'Title'),
                              ),
                              TextField(
                                controller: descriptionController,
                                decoration: InputDecoration(
                                    labelText: 'Description'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final newData = {
                                  'title': titleController.text,
                                  'description':
                                  descriptionController.text,
                                };
                                editGalleryItem(item['id'], newData);
                                Navigator.of(context).pop();
                              },
                              child: Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (item['id'] != null) {
                      deleteGalleryItem(item['id']);
                    } else {
                      Get.snackbar('Error', 'Item ID is missing.');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
