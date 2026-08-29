import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/constants/app_colors.dart';
import '../services/dindi_state_service.dart';
import 'dindi_announcements_screen.dart';
import 'dindi_members_screen.dart';
import 'dindi_profile_screen.dart';

class DindiDashboardScreen extends StatefulWidget {
  const DindiDashboardScreen({super.key});

  @override
  State<DindiDashboardScreen> createState() => _DindiDashboardScreenState();
}

class _DindiDashboardScreenState extends State<DindiDashboardScreen> {
  final DindiStateService _service = DindiStateService();

  void _copyJoinCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join Code "$code" copied to clipboard!'),
        backgroundColor: AppColors.dindiAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToMembers({int initialTab = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DindiMembersScreen(initialTabIndex: initialTab),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DindiProfileScreen(),
      ),
    );
  }

  void _navigateToAnnouncements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DindiAnnouncementsScreen(),
      ),
    );
  }

  Color _getRoadStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'clear & moving':
        return Colors.green.shade700;
      case 'slow':
      case 'crowded':
      case 'slow moving / crowded':
        return Colors.orange.shade800;
      case 'temporarily blocked':
      case 'blocked':
        return Colors.red.shade700;
      default:
        return AppColors.dindiAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final dindi = _service.dindiGroup;
        final totalMembers = _service.totalMemberCount;
        final pendingRequests = _service.pendingRequestCount;
        final latestAnnouncement = _service.announcements.isNotEmpty
            ? _service.announcements.first
            : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dindi Leader Dashboard'),
            backgroundColor: AppColors.dindiAccent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.campaign),
                tooltip: 'Announcements',
                onPressed: _navigateToAnnouncements,
              ),
              IconButton(
                icon: const Icon(Icons.edit_note),
                tooltip: 'Edit Dindi Info',
                onPressed: _navigateToProfile,
              ),
              IconButton(
                icon: const Icon(Icons.people),
                tooltip: 'Member Management',
                onPressed: () => _navigateToMembers(
                  initialTab: pendingRequests > 0 ? 0 : 1,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dindi Header Card with Edit Action
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppColors.dindiAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.dindiAccent
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.groups,
                                  color: AppColors.dindiAccent,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dindi.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Dindi No. ${dindi.dindiNumber} • Leader: ${dindi.leaderName}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppColors.dindiAccent,
                                ),
                                tooltip: 'Edit Dindi Details',
                                onPressed: _navigateToProfile,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.route,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Route: ${dindi.startPoint} ➔ ${dindi.destination}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Join Code Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: const Color(0xFFFFF3E0), // Soft warm amber container
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DINDI JOIN CODE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.dindiAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dindi.joinCode,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Share this code with Warkaris to join',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _copyJoinCode(dindi.joinCode),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dindiAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Operational Status Badges (Current Halt & Road Status)
                  Row(
                    children: [
                      // Current Halt Card
                      Expanded(
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _navigateToProfile,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Current Halt',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.edit,
                                        size: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dindi.currentHalt,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Road Status Card
                      Expanded(
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _navigateToProfile,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.traffic,
                                        size: 18,
                                        color: _getRoadStatusColor(
                                            dindi.roadStatus),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Road Status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.edit,
                                        size: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dindi.roadStatus,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _getRoadStatusColor(dindi.roadStatus),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Announcements Card Preview
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: latestAnnouncement?.isUrgent ?? false
                            ? Colors.red.shade300
                            : AppColors.border,
                      ),
                    ),
                    color: latestAnnouncement?.isUrgent ?? false
                        ? const Color(0xFFFFF8F8)
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.campaign,
                                    size: 20,
                                    color: latestAnnouncement?.isUrgent ?? false
                                        ? Colors.red.shade700
                                        : AppColors.dindiAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Dindi Announcements',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: _navigateToAnnouncements,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: AppColors.dindiAccent,
                                ),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (latestAnnouncement != null) ...[
                            Row(
                              children: [
                                if (latestAnnouncement.isUrgent)
                                  Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'URGENT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    latestAnnouncement.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestAnnouncement.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else
                            const Text(
                              'No recent announcements.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Member Metrics Grid (Total Members & Pending Requests)
                  Row(
                    children: [
                      // Total Members
                      Expanded(
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _navigateToMembers(initialTab: 1),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 18,
                                        color: AppColors.dindiAccent,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Total Members',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$totalMembers',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Row(
                                    children: [
                                      Text(
                                        'Active in Dindi',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Pending Requests
                      Expanded(
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: pendingRequests > 0
                                  ? Colors.orange.shade300
                                  : AppColors.border,
                            ),
                          ),
                          color: pendingRequests > 0
                              ? const Color(0xFFFFFDE7) // Soft yellow tint
                              : Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _navigateToMembers(initialTab: 0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.pending_actions,
                                        size: 18,
                                        color: pendingRequests > 0
                                            ? Colors.orange.shade800
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Pending Requests',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$pendingRequests',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: pendingRequests > 0
                                          ? Colors.orange.shade900
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        pendingRequests > 0
                                            ? 'Requires action'
                                            : 'All reviewed',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: pendingRequests > 0
                                              ? Colors.orange.shade800
                                              : AppColors.textMuted,
                                          fontWeight: pendingRequests > 0
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dedicated Manage Members Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.dindiAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.manage_accounts,
                          color: AppColors.dindiAccent,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Manage Member Roster',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '$totalMembers active warkaris • $pendingRequests pending join requests',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () => _navigateToMembers(
                        initialTab: pendingRequests > 0 ? 0 : 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
