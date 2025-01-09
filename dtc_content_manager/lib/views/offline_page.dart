import 'package:flutter/material.dart';

class OfflinePage extends StatelessWidget {
  final VoidCallback retryCallback;

  const OfflinePage({Key? key, required this.retryCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('No Internet Connection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'No internet connection detected.\nPlease check your connection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: retryCallback,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
