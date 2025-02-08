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

  // backend URL
  // final String uploadUrl = 'http://10.0.2.2:8000/api/galleryitem/upload/';
  final String uploadUrl = 'http://codenaican.pythonanywhere.com/api/galleryitem/upload/';

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
    if (_image == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields and pick an image.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Retrieve the token from storage
    String? authToken = storage.read('authToken'); // Correctly read the token

    if (authToken == null) {
      Get.snackbar('Error', 'Authentication token not found. Iko wapi funguo?.');
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;

    // adding the image to the request
    var pic = await http.MultipartFile.fromPath('image', _image!.path);
    request.files.add(pic);

    //adding the authorization header to the request
    request.headers['Authorization'] = 'Bearer $authToken';

    try {
      var response = await request.send();

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Image uploaded successfully');
        // Clear the fields on successful upload
        _titleController.clear();
        _descriptionController.clear();
        _image = null;
      } else {
        Get.snackbar('Error', 'Failed to upload image');
      }
      }catch(e){
      Get.snackbar('Error','An error occurred: $e');
    } finally {
      setState(() {
        _isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Gallery Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!, height: 150, width: 150),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadImage,
                    child: Text('Upload'),
                  ),

            SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminGalleryManagementPage()),
                );
              },
              child: Text("Manage Gallery Items"),
            )
          ],

        ),
      ),
    );
  }
}
