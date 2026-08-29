import 'package:flutter/material.dart';

/// Blank initializer screen for the Police / Authority Module owned by Yogeshwari.
class PoliceInitializerScreen extends StatelessWidget {
  const PoliceInitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police / Authority Module'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_police,
              size: 64,
              color: Color(0xFF1565C0),
            ),
            SizedBox(height: 16),
            Text(
              'Police / Authority Module',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Module initialized successfully.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
