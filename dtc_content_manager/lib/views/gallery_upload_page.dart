// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'gallery_management_page.dart';

class GalleryUploadPage extends StatefulWidget {
  @override
  _GalleryUploadPageState createState() => _GalleryUploadPageState();
}

class _GalleryUploadPageState extends State<GalleryUploadPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  final String uploadUrl = 'https://delicioustumainicaterers.pythonanywhere.com/api/galleryitem/upload/';
  final storage = GetStorage();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null || _titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields and pick an image.');
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

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    request.headers['Authorization'] = 'Bearer $authToken';

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Image uploaded successfully');
        setState(() {
          _titleController.clear();
          _descriptionController.clear();
          _image = null;
        });
      } else {
        Get.snackbar('Error', 'Failed to upload image');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Gallery Item'),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _image == null
                          ? const Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pick Image'),
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
                onPressed: _uploadImage,
                child: const Text('Upload'),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminGalleryManagementPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Manage Gallery Items'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}