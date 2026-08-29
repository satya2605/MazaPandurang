import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';

/// Side navigation drawer for Pilgrim module secondary features.
class PilgrimDrawer extends StatelessWidget {
  final VoidCallback onProfileTap;

  const PilgrimDrawer({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 24,
                        child: Icon(
                          Icons.directions_walk,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maza Pandurang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'माझा पांडुरंग वारी सेवा',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: AppColors.primary),
                    title: const Text('My Profile (प्रोफाइल)'),
                    onTap: () {
                      Navigator.pop(context);
                      onProfileTap();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.map_outlined),
                    title: const Text('Wari Route & Map (वारी मार्ग)'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: const Text('Palkhi Schedule (पालखी सोहळा)'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: const Text('Dindi Directory (दिंडी माहिती)'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.music_note_outlined),
                    title: const Text('Bhakti Streaming (भक्ती संगीत)'),
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.volunteer_activism_outlined,
                        color: AppColors.ngoAccent),
                    title: const Text('Support Maza Pandurang (दान / मदत)'),
                    subtitle: const Text('Voluntary contribution to app seva'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Support & Donation portal will open in Phase 2.',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Map & App Settings'),
                    subtitle: const Text('MapLibre + MapTiler / Google Maps'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About & Help FAQ'),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Maza Pandurang v1.0.0 (Hackathon MVP)',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
