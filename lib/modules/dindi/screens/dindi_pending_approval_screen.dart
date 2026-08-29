import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/navigation/app_routes.dart';
import '../../../core/auth/auth_service.dart';
import 'my_dindis_screen.dart';

/// Screen displayed when a Dindi Leader application is awaiting Admin approval.
class DindiPendingApprovalScreen extends StatefulWidget {
  final String? dindiName;
  final String? startPoint;
  final String? destination;
  final String? expectedMembers;

  const DindiPendingApprovalScreen({
    super.key,
    this.dindiName,
    this.startPoint,
    this.destination,
    this.expectedMembers,
  });

  @override
  State<DindiPendingApprovalScreen> createState() => _DindiPendingApprovalScreenState();
}

class _DindiPendingApprovalScreenState extends State<DindiPendingApprovalScreen> {
  final AuthService _authService = AuthService();
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    try {
      final profile = _authService.currentProfile;
      final userId = profile?['id']?.toString() ?? '00000000-0000-0000-0000-000000000002';
      final updated = await _authService.fetchProfileById(userId);

      if (!mounted) return;

      if (updated != null && updated['status'] == 'active') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Congratulations! Your Dindi Leader application has been approved!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyDindisScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your application is still under Admin review. Please check back shortly.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status check failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Status'),
        backgroundColor: AppColors.dindiAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Pending Status Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.shade600, width: 2),
                ),
                child: Icon(
                  Icons.hourglass_top_outlined,
                  size: 48,
                  color: Colors.amber.shade800,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Awaiting Admin Approval',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              const Text(
                'Your Dindi Leader registration has been submitted to administration. Management privileges will be activated once verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Submitted Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Application Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.amber.shade800),
                              const SizedBox(width: 6),
                              Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.groups_outlined,
                      'Dindi Name',
                      widget.dindiName ?? 'Shree Tukaram Maharaj Dindi',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.alt_route_outlined,
                      'Route',
                      '${widget.startPoint ?? "Alandi"} → ${widget.destination ?? "Pandharpur"}',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.people_alt_outlined,
                      'Expected Varkaris',
                      widget.expectedMembers ?? '100+',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      Icons.lock_clock_outlined,
                      'Dindi Controls',
                      'Locked until verification',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dindiAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isChecking ? 'Checking Approval...' : 'Check Approval Status',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
                  },
                  icon: const Icon(Icons.directions_walk),
                  label: const Text('Continue as Pilgrim'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.dindiAccent),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
