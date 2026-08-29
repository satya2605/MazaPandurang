import 'package:flutter/material.dart';

/// Blank initializer screen for the Pilgrim Module owned by Satyajit.
class PilgrimInitializerScreen extends StatelessWidget {
  const PilgrimInitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilgrim Module'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_walk,
              size: 64,
              color: Color(0xFFE65100),
            ),
            SizedBox(height: 16),
            Text(
              'Pilgrim Module',
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
