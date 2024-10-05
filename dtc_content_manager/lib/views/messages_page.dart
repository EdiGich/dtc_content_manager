// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: Center(
        child: Text('Messages will be displayed here'),
      ),
    );
  }
}
