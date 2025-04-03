import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AdminGalleryManagementPage extends StatefulWidget {
  @override
  _AdminGalleryManagementPageState createState() => _AdminGalleryManagementPageState();
}

class _AdminGalleryManagementPageState extends State<AdminGalleryManagementPage> {
  List galleryItems = [];
  bool isLoading = true;
  bool hasError = false;

  final storage = GetStorage();

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
      String? token = storage.read('authToken');
      if (token == null) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print('Token not found in storage.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://codenaican.pythonanywhere.com/api/galleryitem/manage/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          galleryItems = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        print('Error: Failed to load gallery items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Network error: $e');
    }
  }

  Future<void> deleteGalleryItem(int id) async {
    if (id == null) {
      print("Item ID is null. Cannot delete.");
      Get.snackbar('Error', 'Failed to delete item. ID not found.');
      return;
    }

    final response = await http.delete(
      Uri.parse('https://codenaican.pythonanywhere.com/api/galleryitem/manage/$id/'),
      headers: {'Authorization': 'Bearer ${storage.read('authToken')}'},
    );

    if (response.statusCode == 204) {
      setState(() {
        galleryItems.removeWhere((item) => item['id'] == id);
      });
      Get.snackbar('Success', 'Item deleted successfully.');
    } else {
      print('Failed to delete item: ${response.statusCode} - ${response.body}');
      Get.snackbar('Error', 'Failed to delete item.');
    }
  }

  Future<void> editGalleryItem(int id, Map<String, dynamic> newData) async {
    String? token = storage.read('authToken');

    final response = await http.put(
      Uri.parse('https://codenaican.pythonanywhere.com/api/galleryitem/manage/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(newData),
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = galleryItems.indexWhere((item) => item['id'] == id);
        galleryItems[index] = json.decode(response.body);
      });
      Get.snackbar('Success', 'Item updated successfully.');
    } else {
      print('Failed to edit item: ${response.statusCode} - ${response.body}');
      Get.snackbar('Error', 'Failed to edit item.');
    }
  }

  // New method for showing deletion confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Confirm Deletion',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          content: Text(
            'Are you sure you want to delete "${item['title'] ?? 'this item'}"? This action cannot be undone.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel deletion
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).hintColor)),
            ),
            TextButton(
              onPressed: () {
                if (item['id'] != null) {
                  deleteGalleryItem(item['id']); // Proceed with deletion
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  Get.snackbar('Error', 'Item ID is missing.');
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Management'),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                'Failed to load gallery items',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchGalleryItems,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : galleryItems.isEmpty
            ? const Center(
          child: Text(
            'No gallery items found',
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: galleryItems.length,
          itemBuilder: (context, index) {
            final item = galleryItems[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://codenaican.pythonanywhere.com${item['image']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50),
                  ),
                ),
                title: Text(item['title'] ?? 'No title'),
                subtitle: Text(item['description'] ?? 'No description'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.teal),
                      onPressed: () => _showEditDialog(context, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirmationDialog(context, item), // Show confirmation dialog
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    final titleController = TextEditingController(text: item['title']);
    final descriptionController = TextEditingController(text: item['description']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Edit Gallery Item',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).hintColor)),
            ),
            TextButton(
              onPressed: () {
                final newData = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                };
                editGalleryItem(item['id'], newData);
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }
}