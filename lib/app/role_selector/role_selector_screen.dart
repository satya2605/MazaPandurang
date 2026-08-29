import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../../common/navigation/app_routes.dart';

class RoleOption {
  final String id;
  final String englishTitle;
  final String marathiTitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String route;

  const RoleOption({
    required this.id,
    required this.englishTitle,
    required this.marathiTitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.route,
  });
}

class RoleSelectorScreen extends StatefulWidget {
  const RoleSelectorScreen({super.key});

  @override
  State<RoleSelectorScreen> createState() => _RoleSelectorScreenState();
}

class _RoleSelectorScreenState extends State<RoleSelectorScreen> {
  int _selectedIndex = 0;

  static const List<RoleOption> _roles = [
    RoleOption(
      id: 'pilgrim',
      englishTitle: 'Pilgrim',
      marathiTitle: 'वारकरी',
      description: 'Find services, routes & assistance',
      icon: Icons.directions_walk,
      accentColor: AppColors.pilgrimAccent,
      route: AppRoutes.pilgrim,
    ),
    RoleOption(
      id: 'dindi',
      englishTitle: 'Dindi Leader',
      marathiTitle: 'दिंडी प्रमुख',
      description: 'Manage your group & stay connected',
      icon: Icons.groups,
      accentColor: AppColors.dindiAccent,
      route: AppRoutes.dindi,
    ),
    RoleOption(
      id: 'ngo',
      englishTitle: 'NGO Volunteer',
      marathiTitle: 'सेवाभावी',
      description: 'Offer and manage Seva services',
      icon: Icons.volunteer_activism,
      accentColor: AppColors.ngoAccent,
      route: AppRoutes.ngo,
    ),
    RoleOption(
      id: 'police',
      englishTitle: 'Police / Authority',
      marathiTitle: 'पोलीस',
      description: 'Monitor routes, alerts & public safety',
      icon: Icons.local_police,
      accentColor: AppColors.policeAccent,
      route: AppRoutes.police,
    ),
    RoleOption(
      id: 'citizen',
      englishTitle: 'Local Citizen',
      marathiTitle: 'स्थानिक नागरिक',
      description: 'Traffic, parking & city updates',
      icon: Icons.location_city,
      accentColor: AppColors.citizenAccent,
      route: AppRoutes.citizen,
    ),
  ];

  void _onContinue() {
    final selectedRole = _roles[_selectedIndex];
    Navigator.pushNamed(context, selectedRole.route);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = _roles[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maza Pandurang'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Your Role',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Personalise your Wari experience',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _roles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final role = _roles[index];
                        final isSelected = index == _selectedIndex;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? role.accentColor.withAlpha(20)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? role.accentColor
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: role.accentColor.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    role.icon,
                                    color: role.accentColor,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            role.englishTitle,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: role.accentColor
                                                  .withAlpha(25),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              role.marathiTitle,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: role.accentColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        role.description,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? role.accentColor
                                      : AppColors.textMuted,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedRole.accentColor,
                ),
                child: Text('Continue as ${selectedRole.englishTitle}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
