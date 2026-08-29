import 'package:flutter/material.dart';
import '../emergency/emergency_list_screen.dart';
import '../map/police_map_screen.dart';
import 'police_dashboard_screen.dart';
import 'police_more_screen.dart';

/// IndexedStack-based shell providing the 4-tab bottom navigation
/// for the entire Police module after login.
class PoliceShellScreen extends StatefulWidget {
  const PoliceShellScreen({super.key});

  @override
  State<PoliceShellScreen> createState() => _PoliceShellScreenState();
}

class _PoliceShellScreenState extends State<PoliceShellScreen> {
  int _currentIndex = 0;

  static const _policeNavy = Color(0xFF1565C0);

  final List<Widget> _pages = const [
    PoliceDashboardScreen(),
    PoliceMapScreen(),
    EmergencyListScreen(),
    PoliceMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: _policeNavy.withAlpha(30),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: _policeNavy),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: _policeNavy),
            label: 'Live Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.emergency_outlined),
            selectedIcon: Icon(Icons.emergency, color: _policeNavy),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz, color: _policeNavy),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
