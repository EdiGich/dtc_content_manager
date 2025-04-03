import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dtc_content_manager/main.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controllers/login_controller.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LoginController loginController = Get.find<LoginController>();
  String appVersion = "";
  String developerName = "Gichira Edwin M";

  @override
  void initState() {
    super.initState();
    _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'Preferences'),
            _buildSwitchTile(
              context: context,
              icon: Icons.brightness_6,
              title: 'Dark Mode',
              value: ThemeService().isDarkMode(),
              onChanged: (bool value) {
                ThemeService().switchTheme();
                setState(() {}); // Refresh UI after theme change
              },
            ),
            _buildSwitchTile(
              context: context,
              icon: Icons.notifications,
              title: 'Notifications',
              value: true, // Replace with a state or user preference
              onChanged: (bool value) {
                // Implement notification toggle functionality
              },
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Account'),
            _buildActionTile(
              context: context,
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                // Navigate to a password change page
              },
            ),
            _buildActionTile(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => _showLogoutConfirmation(context),
              titleColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.redAccent.shade100
                  : Colors.redAccent,
            ),
            const Divider(height: 32, thickness: 1),
            _buildSectionTitle(context, 'About'),
            _buildInfoTile(
              context: context,
              icon: Icons.info,
              title: 'App Version',
              subtitle: appVersion.isNotEmpty ? appVersion : "Fetching...",
            ),
            _buildInfoTile(
              context: context,
              icon: Icons.person,
              title: 'Developer',
              subtitle: developerName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(color: titleColor ?? Theme.of(context).textTheme.bodyMedium?.color),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
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