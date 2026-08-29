import 'package:flutter/material.dart';
import '../models/ngo_organization.dart';
import '../models/ngo_service.dart';
import '../services/ngo_repository.dart';
import '../widgets/approval_status_banner.dart';
import '../widgets/service_card.dart';
import 'ngo_profile_screen.dart';
import 'ngo_registration_screen.dart';
import 'service_detail_screen.dart';
import 'service_form_screen.dart';

/// Main Dashboard Screen for the NGO Volunteer Module owned by Shrutika.
class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  final NgoRepository _repo = NgoRepository();
  String _selectedCategoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChange);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
    super.dispose();
  }

  void _onRepoChange() {
    if (mounted) setState(() {});
  }

  void _openRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NgoRegistrationScreen(),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NgoProfileScreen(),
      ),
    );
  }

  void _openServiceForm([NgoService? service]) {
    if (_repo.organization.approvalStatus == NgoApprovalStatus.rejected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'NGO Registration is currently rejected. Cannot modify services.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceFormScreen(serviceToEdit: service),
      ),
    );
  }

  void _openServiceDetail(NgoService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }

  List<NgoService> _getFilteredServices() {
    if (_selectedCategoryFilter == 'All') return _repo.services;
    return _repo.services.where((s) {
      if (_selectedCategoryFilter == 'Food') {
        return s.category == NgoServiceCategory.food;
      }
      if (_selectedCategoryFilter == 'Medical') {
        return s.category == NgoServiceCategory.medical;
      }
      if (_selectedCategoryFilter == 'Water') {
        return s.category == NgoServiceCategory.water;
      }
      if (_selectedCategoryFilter == 'Shelter') {
        return s.category == NgoServiceCategory.shelter;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final org = _repo.organization;
    final services = _getFilteredServices();
    final totalReports = _repo.reports.length;
    final availableCount = _repo.services
        .where((s) => s.availability == ServiceAvailability.available)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.volunteer_activism, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('NGO Seva Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'NGO Profile & Verification',
            icon: const Icon(Icons.account_balance),
            onPressed: _openProfile,
          ),
          IconButton(
            tooltip: 'Register New NGO',
            icon: const Icon(Icons.app_registration),
            onPressed: _openRegistration,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        onPressed: () => _openServiceForm(),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Seva Service'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Approval Status Banner
              ApprovalStatusBanner(status: org.approvalStatus),
              const SizedBox(height: 16),

              // NGO Info Header Card
              Card(
                color: const Color(0xFF2E7D32).withAlpha(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFF2E7D32).withAlpha(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFF2E7D32),
                        child:
                            Icon(Icons.church, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              org.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Reg: ${org.registrationNo} • ${org.primaryCategory}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Color(0xFF2E7D32)),
                        onPressed: _openProfile,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Summary Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Total Services',
                      value: '${_repo.services.length}',
                      icon: Icons.grid_view,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'Active & Available',
                      value: '$availableCount',
                      icon: Icons.check_circle,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'User Reports',
                      value: '$totalReports',
                      icon: Icons.report_problem,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Service List Header & Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seva Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openServiceForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Service'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['All', 'Food', 'Medical', 'Water', 'Shelter'].map((cat) {
                    final isSelected = _selectedCategoryFilter == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2E7D32),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryFilter = cat;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Service List
              if (services.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.design_services,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No Seva Services Found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap "Add Seva Service" to list your organization assistance location.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceCard(
                      service: service,
                      onTap: () => _openServiceDetail(service),
                      onEdit: () => _openServiceForm(service),
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
