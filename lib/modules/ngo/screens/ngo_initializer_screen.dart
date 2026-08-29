import 'package:flutter/material.dart';

/// Blank initializer screen for the NGO Volunteer Module owned by Shrutika.
class NgoInitializerScreen extends StatelessWidget {
  const NgoInitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Volunteer Module'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 64,
              color: Color(0xFF2E7D32),
            ),
            SizedBox(height: 16),
            Text(
              'NGO Volunteer Module',
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
