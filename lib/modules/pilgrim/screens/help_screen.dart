import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  void _triggerEmergency(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text('$type Alert'),
          ],
        ),
        content: Text(
          'Nearest available $type team will be alerted with your location. (Phase 2 backend workflow)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade700,
                  content: Text(
                    'Emergency request sent! Dispatching nearest $type unit.',
                  ),
                ),
              );
            },
            child: const Text('Confirm Alert'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency & Help (मदत व आपत्कालीन)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick SOS Card
            Card(
              color: Colors.red.shade700,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(Icons.emergency, color: Colors.white, size: 44),
                    const SizedBox(height: 10),
                    const Text(
                      'Emergency Medical Assistance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'वैद्यकीय मदत व ॲम्ब्युलन्स सेवा',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade700,
                      ),
                      onPressed: () =>
                          _triggerEmergency(context, 'Medical Emergency'),
                      icon: const Icon(Icons.call),
                      label: const Text('REQUEST EMERGENCY MEDICAL HELP'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Assistance Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Police Helpline
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.policeAccent,
                  child: Icon(Icons.local_police, color: Colors.white),
                ),
                title: const Text('Police Helpline (पोलीस नियंत्रण)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    const Text('Direct helpline 112 & local police booth'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _triggerEmergency(context, 'Police'),
              ),
            ),
            const SizedBox(height: 8),

            // Missing Person Report
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person_search, color: Colors.white),
                ),
                title: const Text('Report Missing Person (हरवलेली व्यक्ती)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    const Text('Admin-approved area notification broadcast'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Missing person reporting form opens in Phase 2.'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Lost & Found
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.find_in_page, color: Colors.white),
                ),
                title: const Text('Lost & Found Items (सापडलेली वस्तू)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    const Text('Report or find lost belongings along route'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
