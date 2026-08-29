import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../../../core/auth/auth_service.dart';

/// Profile bottom sheet modal supporting Guest mode and Authenticated user profile details.
class PilgrimProfileModal extends StatefulWidget {
  const PilgrimProfileModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const PilgrimProfileModal(),
    );
  }

  @override
  State<PilgrimProfileModal> createState() => _PilgrimProfileModalState();
}

class _PilgrimProfileModalState extends State<PilgrimProfileModal> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  static String _formatRoleName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin (प्रशासक)';
      case 'dindi_leader':
        return 'Dindi Leader (दिंडी प्रमुख)';
      case 'police_authority':
      case 'police':
        return 'Police Authority (पोलीस)';
      case 'ngo_volunteer':
      case 'ngo':
        return 'NGO Volunteer (सेवाभावी)';
      case 'local_citizen':
      case 'citizen':
        return 'Local Citizen (स्थानिक)';
      case 'palkhi_operator':
        return 'Palkhi Operator';
      case 'pilgrim':
      default:
        return 'Pilgrim (वारकरी)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final profile = _authService.currentProfile;
    final bool isAuthenticated = user != null || profile != null;

    final String displayName = profile?['display_name'] ??
        profile?['full_name'] ??
        user?.userMetadata?['full_name'] ??
        (user?.email != null && user!.email!.isNotEmpty
            ? user.email!.split('@')[0]
            : 'Warkari Pilgrim');

    final String email = profile?['email'] ?? user?.email ?? 'No email associated';
    final String role = (profile?['role'] ?? user?.userMetadata?['role'] ?? 'pilgrim').toString();
    final String status = (profile?['status'] ?? 'active').toString();
    final String userId = user?.id ?? profile?['id'] ?? 'Guest';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isAuthenticated ? AppColors.primary : AppColors.primaryLight,
                child: Icon(
                  isAuthenticated ? Icons.person : Icons.person_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAuthenticated
                          ? email
                          : 'Guest User Mode (सार्वजनिक वारी प्रवेश)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isAuthenticated) ...[
            // Authenticated Role & Status Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Assigned Role / भूमिका',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Text(
                          _formatRoleName(role),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Status / स्थिती',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'suspended'
                              ? Colors.red[50]
                              : status == 'pending'
                                  ? Colors.orange[50]
                                  : Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: status == 'suspended'
                                ? Colors.red
                                : status == 'pending'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: status == 'suspended'
                                ? Colors.red
                                : status == 'pending'
                                    ? Colors.orange[800]
                                    : Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'User Identifier (ID)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          userId.length > 16 ? '${userId.substring(0, 16)}...' : userId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Account Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Log out of your current Supabase session'),
              onTap: () async {
                Navigator.pop(context);
                await _authService.signOut();
              },
            ),
          ] else ...[
            // Guest Mode Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No login required to view map, Palkhi route, services, and Bhakti music.',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Account Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.login, color: AppColors.primary),
              title: const Text('Sign In or Register'),
              subtitle: const Text('Sign in with Email/Password or Google to unlock full role access'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language),
            title: const Text('Language / भाषा'),
            subtitle: const Text('Marathi / English'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
