// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
// Removed unused import: 'package:dtc_content_manager/models/menu_item_model.dart'

class AddMenuItemPage extends StatefulWidget {
  final Function refreshMenuItems;

  const AddMenuItemPage({required this.refreshMenuItems});

  @override
  _AddMenuItemPageState createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  final String menuApiUrl = 'https://delicioustumainicaterers.pythonanywhere.com/api/menu/';
  final storage = GetStorage();
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String _description = '';
  double _price = 0.0;
  XFile? _pickedFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedFile = pickedFile;
    });
  }

  Future<void> _submitMenuItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validation copied from GalleryUploadPage
      if (_pickedFile == null) {
        Get.snackbar('Error', 'Please pick an image.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      String? authToken = storage.read('authToken');
      if (authToken == null) {
        Get.snackbar('Error', 'Authentication token not found.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse(menuApiUrl));
      request.headers['Authorization'] = 'Bearer $authToken';

      // Add fields
      request.fields['name'] = _name;
      request.fields['description'] = _description;
      request.fields['price'] = _price.toString();

      // Add image
      if (_pickedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _pickedFile!.path));
      }

      try {
        var response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 201) {
          Get.snackbar('Success', 'Menu item uploaded successfully');
          widget.refreshMenuItems();
          setState(() {
            _name = '';
            _description = '';
            _price = 0.0;
            _pickedFile = null;
          });
          Navigator.pop(context);
        } else {
          print('Failed to create menu item: ${response.statusCode} - $responseBody');
          Get.snackbar('Error', 'Failed to upload menu item: $responseBody');
        }
      } catch (e) {
        print('Error creating menu item: $e');
        Get.snackbar('Error', 'An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Menu Item'),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price (Ksh)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixText: 'Ksh ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Price is required';
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                  onSaved: (value) => _price = double.parse(value!),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _pickedFile != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_pickedFile!.path),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Text(
                          'No image selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Select Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                )
                    : ElevatedButton(
                  onPressed: _submitMenuItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}