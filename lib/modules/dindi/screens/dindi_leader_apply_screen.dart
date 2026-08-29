import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/navigation/app_routes.dart';
import '../../../core/auth/auth_service.dart';
import 'dindi_pending_approval_screen.dart';

/// Screen allowing normal users/Varkaris to register and apply as a Dindi Leader.
class DindiLeaderApplyScreen extends StatefulWidget {
  const DindiLeaderApplyScreen({super.key});

  @override
  State<DindiLeaderApplyScreen> createState() => _DindiLeaderApplyScreenState();
}

class _DindiLeaderApplyScreenState extends State<DindiLeaderApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _leaderNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dindiNameController = TextEditingController();
  final _startPointController = TextEditingController(text: 'Alandi');
  final _destinationController = TextEditingController(text: 'Pandharpur');
  final _expectedMembersController = TextEditingController(text: '100');
  final _descriptionController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final profile = _authService.currentProfile;
    if (profile != null) {
      _leaderNameController.text = profile['display_name'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _leaderNameController.dispose();
    _phoneController.dispose();
    _dindiNameController.dispose();
    _startPointController.dispose();
    _destinationController.dispose();
    _expectedMembersController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final profile = _authService.currentProfile;
      final userId = profile?['id']?.toString() ?? '00000000-0000-0000-0000-000000000002';

      final result = await _authService.applyDindiLeader(
        userId: userId,
        dindiName: _dindiNameController.text.trim(),
        startPoint: _startPointController.text.trim(),
        destination: _destinationController.text.trim(),
        expectedMembers: int.tryParse(_expectedMembersController.text.trim()) ?? 50,
      );

      if (!mounted) return;

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DindiPendingApprovalScreen(
              dindiName: _dindiNameController.text.trim(),
              startPoint: _startPointController.text.trim(),
              destination: _destinationController.text.trim(),
              expectedMembers: _expectedMembersController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit application. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply as Dindi Leader'),
        backgroundColor: AppColors.dindiAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.dindiAccent.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dindiAccent.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.dindiAccent, size: 36),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dindi Leader Registration',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Submit your troupe details for Admin verification. Once approved, you can create and manage your Dindi.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Leader Details
                const Text(
                  'Leader Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _leaderNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Sanket Patil',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter your full name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone *',
                    hintText: '+91 98220 12345',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 24),

                // Dindi Details
                const Text(
                  'Dindi Troupe Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dindiNameController,
                  decoration: const InputDecoration(
                    labelText: 'Dindi Troupe Name *',
                    hintText: 'e.g. Shree Tukaram Maharaj Palkhi Dindi No. 12',
                    prefixIcon: Icon(Icons.groups),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter Dindi name' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startPointController,
                        decoration: const InputDecoration(
                          labelText: 'Origin *',
                          hintText: 'Dehu / Alandi',
                          prefixIcon: Icon(Icons.trip_origin),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter origin' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          labelText: 'Destination *',
                          hintText: 'Pandharpur',
                          prefixIcon: Icon(Icons.pin_drop),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter destination' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _expectedMembersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expected Varkaris (Members) *',
                    hintText: 'e.g. 150',
                    prefixIcon: Icon(Icons.people_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter expected member count' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Route Description / Tradition (Optional)',
                    hintText: 'e.g. 100-year traditional wari dindi from Dehu',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dindiAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _isSubmitting ? 'Submitting to Admin...' : 'Submit Application to Admin',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.roleSelector),
                    child: const Text('Cancel & Return to Role Selection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
