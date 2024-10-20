// ignore_for_file: use_key_in_widget_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'messages_page.dart';
import 'menu_update_page.dart';
import 'gallery_upload_page.dart';
import 'settings_page.dart';
import '../controllers/login_controller.dart';
import 'gallery_management_page.dart';

class DashboardPage extends StatelessWidget {
  final LoginController loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button for Messages Page
            ElevatedButton(
              onPressed: () => Get.to(() => MessagesPage()),
              child: Text('Messages'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            SizedBox(height: 16),

            // Button for Menu Update Page
            ElevatedButton(
              onPressed: () => Get.to(() => MenuUpdatePage()),
              child: Text('Update Menu'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            SizedBox(height: 16),

            // Button for Gallery Upload Page
            ElevatedButton(
              onPressed: () => Get.to(() => GalleryUploadPage()),
              child: Text('Upload to Gallery'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            SizedBox(height: 16),

            //Manage Gallery Items
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminGalleryManagementPage()),
                );
              },
              child: Text("Manage Gallery Items"),
            ),

            SizedBox(height: 16),
            // Button for Settings Page
            ElevatedButton(
              onPressed: () => Get.to(() => SettingsPage()),
              child: Text('Settings'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),


            SizedBox(height: 32),

            //logout button
            ElevatedButton(
              onPressed: () => loginController.logout(),
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
