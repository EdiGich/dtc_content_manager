// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Text('Settings will be displayed here'),
      ),
    );
  }
}
