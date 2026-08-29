import 'package:flutter/material.dart';

/// Blank initializer screen for the Local Citizen Module owned by Gauri.
class CitizenInitializerScreen extends StatelessWidget {
  const CitizenInitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Citizen Module'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: 64,
              color: Color(0xFF6A1B9A),
            ),
            SizedBox(height: 16),
            Text(
              'Local Citizen Module',
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
