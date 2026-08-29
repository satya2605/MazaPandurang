import 'package:flutter/material.dart';

/// Blank initializer screen for the Dindi Leader Module owned by Sanket.
class DindiInitializerScreen extends StatelessWidget {
  const DindiInitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dindi Leader Module'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 64,
              color: Color(0xFFD84315),
            ),
            SizedBox(height: 16),
            Text(
              'Dindi Leader Module',
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
