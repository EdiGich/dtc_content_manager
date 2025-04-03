// ignore_for_file: use_key_in_widget_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'messages_page.dart';
import 'menu_update_page.dart';
import 'gallery_upload_page.dart';
import 'settings_page.dart';
import '../controllers/login_controller.dart';
import 'gallery_management_page.dart';
import 'news_page.dart';
import 'events_page.dart';
import 'notifications_page.dart';

class DashboardPage extends StatelessWidget {
  final LoginController loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Messages and Notifications in GridView
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildDashboardButton(
                      context: context,
                      title: 'Messages',
                      icon: Icons.message,
                      onPressed: () => Get.to(() => MessagesPage(), transition: Transition.cupertino),
                    ),
                    _buildDashboardButton(
                      context: context,
                      title: 'View Notifications',
                      icon: Icons.notifications,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Gallery-related buttons in a faint box
                _buildGroupedSection(
                  context: context,
                  label: 'Gallery Management',
                  children: [
                    _buildDashboardButton(
                      context: context,
                      title: 'Upload to Gallery',
                      icon: Icons.photo,
                      onPressed: () => Get.to(() => GalleryUploadPage(), transition: Transition.cupertino),
                    ),
                    _buildDashboardButton(
                      context: context,
                      title: 'Manage Gallery Items',
                      icon: Icons.image,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminGalleryManagementPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content-related buttons in a faint box
                _buildGroupedSection(
                  context: context,
                  label: 'Content Management',
                  children: [
                    _buildDashboardButton(
                      context: context,
                      title: 'Update Menu',
                      icon: Icons.menu_book,
                      onPressed: () => Get.to(() => MenuUpdatePage(), transition: Transition.cupertino),
                    ),
                    _buildDashboardButton(
                      context: context,
                      title: 'Listed Events',
                      icon: Icons.event,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventsPage()),
                      ),
                    ),
                    _buildDashboardButton(
                      context: context,
                      title: 'News',
                      icon: Icons.article,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewsPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Settings button at the bottom
                _buildDashboardButton(
                  context: context,
                  title: 'Settings',
                  icon: Icons.settings,
                  onPressed: () => Get.to(() => SettingsPage(), transition: Transition.cupertino),
                ),
                const SizedBox(height: 32),

                // Logout button
                _buildLogoutButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        title,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(0, 50)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10)),
      ),
    );
  }

  Widget _buildGroupedSection({
    required BuildContext context,
    required String label,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          ...children.map((child) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: child,
          )),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showLogoutConfirmation(context),
      child: Text(
        'Logout',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.redAccent.shade100
              : Colors.redAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Logout',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            TextButton(
              onPressed: () {
                loginController.logout();
                Navigator.of(context).pop();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}