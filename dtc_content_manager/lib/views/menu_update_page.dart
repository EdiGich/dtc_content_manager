import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class MenuUpdatePage extends StatefulWidget {
  @override
  _MenuUpdatePageState createState() => _MenuUpdatePageState();
}

class _MenuUpdatePageState extends State<MenuUpdatePage> {
  List menuItems = [];
  bool isLoading = true;
  bool hasError = false;

  // URL for your Django API endpoint
  final String menuApiUrl = 'http://10.0.2.2:8000/api/menu/';

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse(menuApiUrl), headers: {
        'Authorization': 'Bearer ${GetStorage().read('authToken')}',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() {
          menuItems = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> updateMenuItem(int id, Map<String, dynamic> newData) async {
    final response = await http.put(
      Uri.parse('$menuApiUrl$id/'),
      headers: {
        'Authorization': 'Bearer ${GetStorage().read('authToken')}',
        'Content-Type': 'application/json',
      },
      body: json.encode(newData),
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = menuItems.indexWhere((item) => item['id'] == id);
        menuItems[index] = json.decode(response.body);
      });
    } else {
      print('Failed to update item');
    }
  }

  Future<void> deleteMenuItem(int id) async {
    final response = await http.delete(
      Uri.parse('$menuApiUrl$id/'),
      headers: {
        'Authorization': 'Bearer ${GetStorage().read('authToken')}',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        menuItems.removeWhere((item) => item['id'] == id);
      });
    } else {
      print('Failed to delete item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Menus')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
          ? Center(child: Text('Failed to load menu items'))
          : ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: item['image_url'] != null
                ? Image.network(item['image_url']) // Display image if URL is available
                : Icon(Icons.image_not_supported),
            title: Text(item['name'] ?? 'No name'),
            subtitle: Text(item['description'] ?? 'No description'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(item['id'], item);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteMenuItem(item['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(int id, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final descriptionController = TextEditingController(text: item['description']);
    final priceController = TextEditingController(text: item['price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                };
                updateMenuItem(id, newData);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
