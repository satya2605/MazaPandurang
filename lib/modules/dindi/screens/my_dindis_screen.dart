import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/constants/app_colors.dart';
import '../models/dindi_group.dart';
import '../services/dindi_state_service.dart';
import 'create_dindi_screen.dart';
import 'dindi_dashboard_screen.dart';

/// Entry screen for Dindi Leader displaying all Dindis owned by the leader.
class MyDindisScreen extends StatefulWidget {
  const MyDindisScreen({super.key});

  @override
  State<MyDindisScreen> createState() => _MyDindisScreenState();
}

class _MyDindisScreenState extends State<MyDindisScreen> {
  final DindiStateService _service = DindiStateService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await _service.loadDindis();
    } catch (_) {
      // Error is captured in _service.errorMessage
    }
  }

  void _navigateToCreateDindi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateDindiScreen(),
      ),
    );
  }

  void _selectAndOpenDashboard(DindiGroup dindi) {
    _service.selectDindi(dindi.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DindiDashboardScreen(),
      ),
    );
  }

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

  Color _getRoadStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'clear':
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
        final dindis = _service.dindis;
        final isLoading = _service.isLoading;
        final errorMessage = _service.errorMessage;
        final leaderName = _service.identityProvider.currentLeaderName;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Dindis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Leader: $leaderName',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: AppColors.dindiAccent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Dindis',
                onPressed: _loadData,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Create Dindi',
                onPressed: _navigateToCreateDindi,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navigateToCreateDindi,
            backgroundColor: AppColors.dindiAccent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Create Dindi'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.dindiAccent,
              child: _buildBody(isLoading, errorMessage, dindis),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    bool isLoading,
    String? errorMessage,
    List<DindiGroup> dindis,
  ) {
    if (isLoading && dindis.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.dindiAccent),
            SizedBox(height: 16),
            Text(
              'Loading your Dindis...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && dindis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Dindis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dindiAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (dindis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.dindiAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups,
                  size: 64,
                  color: AppColors.dindiAccent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Dindis Registered Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Register your Dindi procession to manage Warkari members, route halts, and announcements.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToCreateDindi,
                icon: const Icon(Icons.add),
                label: const Text('Register New Dindi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dindiAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: dindis.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final dindi = dindis[index];
        final isSelected = dindi.id == _service.selectedDindiId;

        return Card(
          elevation: isSelected ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected
                  ? AppColors.dindiAccent
                  : AppColors.border.withValues(alpha: 0.7),
              width: isSelected ? 2 : 1,
            ),
          ),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectAndOpenDashboard(dindi),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Dindi Name & Number Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dindiAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'No. ${dindi.dindiNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dindiAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          dindi.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Route info
                  Row(
                    children: [
                      const Icon(
                        Icons.route,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${dindi.startPoint} ➔ ${dindi.destination}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Current Halt & Road Status
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dindi.currentHalt.isNotEmpty
                              ? dindi.currentHalt
                              : 'Not specified',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoadStatusColor(dindi.roadStatus)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dindi.roadStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getRoadStatusColor(dindi.roadStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Bottom Row: Join Code & Open Dashboard Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Join Code: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            dindi.joinCode,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: AppColors.dindiAccent,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 14),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Copy Code',
                            onPressed: () => _copyJoinCode(dindi.joinCode),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Open Dashboard',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.dindiAccent
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: isSelected
                                ? AppColors.dindiAccent
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
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
