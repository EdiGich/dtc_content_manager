import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:dtc_content_manager/models/menu_item_model.dart';

class MenuUpdatePage extends StatefulWidget {
  @override
  _MenuUpdatePageState createState() => _MenuUpdatePageState();
}

class _MenuUpdatePageState extends State<MenuUpdatePage> {
  List<MenuItem> menuItems = [];
  bool isLoading = true;
  bool hasError = false;

  // final String menuApiUrl = 'http://10.0.2.2:8000/api/menu/';
  final String menuApiUrl = 'http://codenaican.pythonanywhere.com/api/menu/';


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

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        setState(() {
          menuItems = decodedData
              .map((data) => MenuItem.fromJson(data as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      } else {
        print('Failed to fetch menu items');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }


  Future<void> updateMenuItem(MenuItem updatedItem) async {
    final response = await http.put(
      Uri.parse('$menuApiUrl${updatedItem.id}/'),
      headers: {
        'Authorization': 'Bearer ${GetStorage().read('authToken')}',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedItem.toJson()),
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = menuItems.indexWhere((item) => item.id == updatedItem.id);
        menuItems[index] = MenuItem.fromJson(json.decode(response.body));
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
        menuItems.removeWhere((item) => item.id == id);
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
            leading: item.imageUrl != null
                ? Image.network(item.imageUrl!)
                : Icon(Icons.image_not_supported),
            title: Text(item.name),
            subtitle: Text(item.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(item);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteMenuItem(item.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(MenuItem item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());

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
                final updatedItem = MenuItem(
                  id: item.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  imageUrl: item.imageUrl,
                );
                updateMenuItem(updatedItem);
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
