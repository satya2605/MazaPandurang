import 'package:flutter/material.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../traffic/traffic_list_screen.dart';
import '../lost_person/lost_person_list_screen.dart';
import '../reports/service_report_list_screen.dart';

/// "More" tab screen — secondary navigation to Traffic, Lost Person, Reports, and Profile.
class PoliceMoreScreen extends StatelessWidget {
  const PoliceMoreScreen({super.key});

  static const _policeNavy = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final user = PoliceDemoRepository.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: _policeNavy,
        title: const Text(
          'More',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Officer profile card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _policeNavy.withAlpha(30),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_police,
                    color: _policeNavy,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${user.policeId} · ${user.station}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF388E3C).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF388E3C),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Operations',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          _menuItem(
            context,
            icon: Icons.traffic,
            label: 'Traffic & Diversions',
            subtitle: 'Manage road alerts and diversions',
            color: const Color(0xFFF57F17),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrafficListScreen()),
                ),
          ),
          _menuItem(
            context,
            icon: Icons.person_search,
            label: 'Lost Persons',
            subtitle: 'Review cases and sightings',
            color: _policeNavy,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LostPersonListScreen(),
                  ),
                ),
          ),
          _menuItem(
            context,
            icon: Icons.report_outlined,
            label: 'Service Reports',
            subtitle: 'Verify reported service issues',
            color: const Color(0xFF388E3C),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ServiceReportListScreen(),
                  ),
                ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          _menuItem(
            context,
            icon: Icons.logout,
            label: 'Logout',
            subtitle: 'Return to role selector',
            color: const Color(0xFFD32F2F),
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withAlpha(120),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
