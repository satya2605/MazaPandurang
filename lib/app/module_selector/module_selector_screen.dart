import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../../common/navigation/app_routes.dart';

class ModuleCardData {
  final String title;
  final String description;
  final String owner;
  final String route;
  final Color color;
  final IconData icon;

  const ModuleCardData({
    required this.title,
    required this.description,
    required this.owner,
    required this.route,
    required this.color,
    required this.icon,
  });
}

/// Development-only Module Selector screen for developer team navigation.
class ModuleSelectorScreen extends StatelessWidget {
  const ModuleSelectorScreen({super.key});

  static const List<ModuleCardData> _modules = [
    ModuleCardData(
      title: 'Pilgrim',
      description: 'Service discovery, map routes, city guide & Bhakti songs',
      owner: 'Satyajit',
      route: AppRoutes.pilgrim,
      color: AppColors.pilgrimAccent,
      icon: Icons.directions_walk,
    ),
    ModuleCardData(
      title: 'Dindi Leader',
      description: 'Group management, live location & member announcements',
      owner: 'Sanket',
      route: AppRoutes.dindi,
      color: AppColors.dindiAccent,
      icon: Icons.groups,
    ),
    ModuleCardData(
      title: 'Police / Authority',
      description: 'Route monitoring, traffic alerts & emergency coordination',
      owner: 'Yogeshwari',
      route: AppRoutes.police,
      color: AppColors.policeAccent,
      icon: Icons.local_police,
    ),
    ModuleCardData(
      title: 'NGO Volunteer',
      description: 'Seva service registration, location & volunteer management',
      owner: 'Shrutika',
      route: AppRoutes.ngo,
      color: AppColors.ngoAccent,
      icon: Icons.volunteer_activism,
    ),
    ModuleCardData(
      title: 'Local Citizen',
      description: 'Traffic updates, parking guidance & local city alerts',
      owner: 'Gauri',
      route: AppRoutes.citizen,
      color: AppColors.citizenAccent,
      icon: Icons.location_city,
    ),
    ModuleCardData(
      title: 'Admin Control Plane',
      description: 'NGO & service verification, moderation & system governance',
      owner: 'Lead Architect',
      route: AppRoutes.admin,
      color: Colors.purple,
      icon: Icons.admin_panel_settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maza Pandurang Modules'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _modules.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _modules[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: item.color.withAlpha(30),
                        child: Icon(item.icon, color: item.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Owner: ${item.owner}',
                              style: TextStyle(
                                fontSize: 13,
                                color: item.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(140, 40),
                        foregroundColor: item.color,
                        side: BorderSide(color: item.color),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, item.route);
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Open Module'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
