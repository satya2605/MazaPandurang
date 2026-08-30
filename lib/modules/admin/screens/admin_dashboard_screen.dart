import 'package:flutter/material.dart';
import '../../../common/navigation/app_routes.dart';
import '../../../core/auth/auth_service.dart';
import '../../pilgrim/widgets/pilgrim_profile_modal.dart';
import '../models/admin_models.dart';
import '../repositories/admin_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AdminRepository _repository = AdminRepository();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;

  AdminDashboardStats? _stats;
  List<AdminNgo> _ngos = [];
  List<AdminService> _services = [];
  List<AdminDindi> _dindis = [];
  List<AdminDindiLeader> _dindiLeaders = [];
  List<AdminLostPerson> _lostPersons = [];
  List<AdminServiceReport> _serviceReports = [];
  List<AdminUser> _users = [];
  List<AdminAuditLog> _auditLogs = [];
  List<AdminPalkhi> _palkhis = [];

  // Filter states
  String _ngoFilter = 'ALL';
  String _serviceFilter = 'ALL';
  String _dindiLeaderFilter = 'ALL';
  String _userRoleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isAdmin() {
    final profile = _authService.currentProfile;
    // Allow if role is admin or in dev environment fallback
    if (profile == null) return true; // Allows initial dev view
    final role = profile['role']?.toString().toLowerCase();
    return role == 'admin';
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _repository.getDashboardStats().catchError((_) => const AdminDashboardStats(
              pendingNgos: 0,
              pendingServices: 0,
              pendingDindis: 0,
              pendingDindiLeaders: 0,
              pendingLostPersonReports: 0,
              openServiceReports: 0,
              activeEmergencies: 0,
              activeTrafficAlerts: 0,
              timestamp: '',
            )),
        _repository.getNgos().catchError((_) => <AdminNgo>[]),
        _repository.getServices().catchError((_) => <AdminService>[]),
        _repository.getDindis().catchError((_) => <AdminDindi>[]),
        _repository.getDindiLeaders().catchError((_) => <AdminDindiLeader>[]),
        _repository.getLostPersons().catchError((_) => <AdminLostPerson>[]),
        _repository.getServiceReports().catchError((_) => <AdminServiceReport>[]),
        _repository.getUsers().catchError((_) => <AdminUser>[]),
        _repository.getAuditLogs().catchError((_) => <AdminAuditLog>[]),
        _repository.getPalkhis().catchError((_) => <AdminPalkhi>[]),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as AdminDashboardStats;
          _ngos = results[1] as List<AdminNgo>;
          _services = results[2] as List<AdminService>;
          _dindis = results[3] as List<AdminDindi>;
          _dindiLeaders = results[4] as List<AdminDindiLeader>;
          _lostPersons = results[5] as List<AdminLostPerson>;
          _serviceReports = results[6] as List<AdminServiceReport>;
          _users = results[7] as List<AdminUser>;
          _auditLogs = results[8] as List<AdminAuditLog>;
          _palkhis = results[9] as List<AdminPalkhi>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load Admin Data: $e';
        });
      }
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.purple.shade700,
      ),
    );
  }

  Future<String?> _promptReason(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter reason or notes...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNgoApprove(String id) async {
    final success = await _repository.approveNgo(id);
    if (success) {
      _showMessage('NGO approved successfully.');
      _fetchAllData();
    } else {
      _showMessage('Failed to approve NGO.', isError: true);
    }
  }

  Future<void> _handleNgoReject(String id) async {
    final reason = await _promptReason('Reject NGO Registration');
    if (reason == null) return;
    final success = await _repository.rejectNgo(id, reason: reason);
    if (success) {
      _showMessage('NGO registration rejected.');
      _fetchAllData();
    } else {
      _showMessage('Failed to reject NGO.', isError: true);
    }
  }

  Future<void> _viewNgoDocument(String ngoId, String docId) async {
    final url = await _repository.getNgoDocumentUrl(ngoId, docId);
    if (url != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Private Document Signed URL (1-hr)'),
          content: SelectableText('Signed URL generated securely:\n\n$url'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    } else if (mounted) {
      _showMessage('Failed to generate 1-hour signed URL for private document.', isError: true);
    }
  }

  Future<void> _handleServiceApprove(String id) async {
    final success = await _repository.approveService(id);
    if (success) {
      _showMessage('Service verified (Gate 1 Passed).');
      _fetchAllData();
    } else {
      _showMessage('Failed to verify service.', isError: true);
    }
  }

  Future<void> _handleServicePublish(String id) async {
    final success = await _repository.publishService(id);
    if (success) {
      _showMessage('Service published to Pilgrims (Gate 2 Active).');
      _fetchAllData();
    } else {
      _showMessage('Failed to publish service.', isError: true);
    }
  }

  Future<void> _handleServiceUnpublish(String id) async {
    final success = await _repository.unpublishService(id);
    if (success) {
      _showMessage('Service unpublished.');
      _fetchAllData();
    } else {
      _showMessage('Failed to unpublish service.', isError: true);
    }
  }

  Future<void> _handleDindiApprove(String id) async {
    final success = await _repository.approveDindi(id);
    if (success) {
      _showMessage('Dindi approved to Active status.');
      _fetchAllData();
    } else {
      _showMessage('Failed to approve Dindi.', isError: true);
    }
  }

  Future<void> _handleDindiReject(String id) async {
    final reason = await _promptReason('Reject Dindi Registration');
    if (reason == null) return;
    final success = await _repository.rejectDindi(id, reason: reason);
    if (success) {
      _showMessage('Dindi registration rejected.');
      _fetchAllData();
    } else {
      _showMessage('Failed to reject Dindi.', isError: true);
    }
  }

  Future<void> _handleDindiLeaderApprove(String id) async {
    final success = await _repository.approveDindiLeader(id);
    if (success) {
      _showMessage('Dindi Leader approved.');
      _fetchAllData();
    } else {
      _showMessage('Failed to approve Dindi Leader.', isError: true);
    }
  }

  Future<void> _handleDindiLeaderReject(String id) async {
    final reason = await _promptReason('Reject Dindi Leader Application');
    if (reason == null) return;
    final success = await _repository.rejectDindiLeader(id, reason: reason);
    if (success) {
      _showMessage('Dindi Leader application rejected.');
      _fetchAllData();
    } else {
      _showMessage('Failed to reject Dindi Leader.', isError: true);
    }
  }

  Future<void> _handleDindiLeaderSuspend(String id) async {
    final reason = await _promptReason('Suspend Dindi Leader Account');
    if (reason == null) return;
    final success = await _repository.suspendDindiLeader(id, reason: reason);
    if (success) {
      _showMessage('Dindi Leader suspended.');
      _fetchAllData();
    } else {
      _showMessage('Failed to suspend Dindi Leader.', isError: true);
    }
  }

  Future<void> _handleLostPersonApprove(String id) async {
    final success = await _repository.approveLostPerson(id);
    if (success) {
      _showMessage('Lost person report approved for public alert broadcast.');
      _fetchAllData();
    } else {
      _showMessage('Failed to approve lost person report.', isError: true);
    }
  }

  Future<void> _handleLostPersonClose(String id) async {
    final reason = await _promptReason('Close Lost Person Case');
    if (reason == null) return;
    final success = await _repository.closeLostPerson(id, reason: reason);
    if (success) {
      _showMessage('Lost person case closed as Found.');
      _fetchAllData();
    } else {
      _showMessage('Failed to close case.', isError: true);
    }
  }

  Future<void> _handleUserStatusChange(String id, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    final success = await _repository.updateUserStatus(id, newStatus);
    if (success) {
      _showMessage('User status updated to $newStatus.');
      _fetchAllData();
    } else {
      _showMessage('Failed to update user status.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Admin Authorization Required (403 Forbidden)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your profile does not have Admin privileges.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _authService.signOut();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text('Sign Out / Login as Admin'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Admin Control Plane'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => PilgrimProfileModal.show(context),
            tooltip: 'My Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            tooltip: 'Sign Out',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Palkhi Registry'),
            Tab(icon: Icon(Icons.volunteer_activism), text: 'NGOs'),
            Tab(icon: Icon(Icons.medical_services), text: 'Services (2-Gate)'),
            Tab(icon: Icon(Icons.group), text: 'Dindi Leaders'),
            Tab(icon: Icon(Icons.person_search), text: 'Lost Persons'),
            Tab(icon: Icon(Icons.report_problem), text: 'Service Reports'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.history), text: 'Audit Logs'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchAllData, child: const Text('Retry')),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildPalkhisTab(),
                    _buildNgosTab(),
                    _buildServicesTab(),
                    _buildDindiLeadersTab(),
                    _buildLostPersonsTab(),
                    _buildServiceReportsTab(),
                    _buildUsersTab(),
                    _buildAuditTrailTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    final stats = _stats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live System Governance Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAllData),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard('Pending NGOs', '${stats?.pendingNgos ?? 0}', Colors.orange, 1, onFilter: () => setState(() => _ngoFilter = 'PENDING')),
              _buildStatCard('Pending Services', '${stats?.pendingServices ?? 0}', Colors.deepOrange, 2, onFilter: () => setState(() => _serviceFilter = 'GATE1_PENDING')),
              _buildStatCard('Pending Dindi Leaders', '${stats?.pendingDindiLeaders ?? 0}', Colors.blue, 3, onFilter: () => setState(() => _dindiLeaderFilter = 'PENDING')),
              _buildStatCard('Pending Dindis', '${stats?.pendingDindis ?? 0}', Colors.indigo, 3, onFilter: () => setState(() => _dindiLeaderFilter = 'PENDING')),
              _buildStatCard('Lost Person Cases', '${stats?.pendingLostPersonReports ?? 0}', Colors.red, 4),
              _buildStatCard('Service Reports', '${stats?.openServiceReports ?? 0}', Colors.amber, 5),
              _buildStatCard('Active Emergencies', '${stats?.activeEmergencies ?? 0}', Colors.purple, 0),
              _buildStatCard('Active Traffic Alerts', '${stats?.activeTrafficAlerts ?? 0}', Colors.teal, 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, int targetTabIndex, {VoidCallback? onFilter}) {
    return InkWell(
      onTap: () {
        if (onFilter != null) onFilter();
        _tabController.animateTo(targetTabIndex);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildNgosTab() {
    final filtered = _ngos.where((n) {
      if (_ngoFilter == 'ALL') return true;
      return n.status.toUpperCase() == _ngoFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('Filter Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _ngoFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Submissions')),
                  DropdownMenuItem(value: 'PENDING', child: Text('Pending Approval')),
                  DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                ],
                onChanged: (v) => setState(() => _ngoFilter = v!),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No NGOs found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final ngo = filtered[i];
                    final isApproved = ngo.status.toLowerCase() == 'approved';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(ngo.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Reg: ${ngo.registrationNumber} | Contact: ${ngo.contactPerson} (${ngo.phone})'),
                        trailing: Chip(
                          label: Text(ngo.status.toUpperCase()),
                          backgroundColor: isApproved ? Colors.green.shade100 : Colors.orange.shade100,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${ngo.description}'),
                                const SizedBox(height: 8),
                                Text('Email: ${ngo.email}'),
                                const SizedBox(height: 12),
                                if (ngo.documents.isNotEmpty) ...[
                                  const Text('Submitted Private Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    children: ngo.documents.map((doc) {
                                      final docId = doc['id'] ?? doc.toString();
                                      return OutlinedButton.icon(
                                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                                        label: const Text('View Signed Doc (1-hr)'),
                                        onPressed: () => _viewNgoDocument(ngo.id, docId),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (!isApproved)
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text('Approve NGO'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        onPressed: () => _handleNgoApprove(ngo.id),
                                      ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      label: const Text('Reject NGO', style: TextStyle(color: Colors.red)),
                                      onPressed: () => _handleNgoReject(ngo.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    final filtered = _services.where((s) {
      if (_serviceFilter == 'GATE1_PENDING') return !s.isVerified;
      if (_serviceFilter == 'GATE2_PENDING') return s.isVerified && !s.isActive;
      if (_serviceFilter == 'PUBLISHED') return s.isVerified && s.isActive;
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('Publication Gate Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _serviceFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Facilities')),
                  DropdownMenuItem(value: 'GATE1_PENDING', child: Text('Pending Gate 1 (Verification)')),
                  DropdownMenuItem(value: 'GATE2_PENDING', child: Text('Pending Gate 2 (Publication)')),
                  DropdownMenuItem(value: 'PUBLISHED', child: Text('Fully Published')),
                ],
                onChanged: (v) => setState(() => _serviceFilter = v!),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No Seva services found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final srv = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(srv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${srv.category} | Provider: ${srv.providerName}\nGate 1 Verified: ${srv.isVerified} | Gate 2 Active: ${srv.isActive}'),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            if (!srv.isVerified)
                              ElevatedButton(
                                onPressed: () => _handleServiceApprove(srv.id),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                child: const Text('Verify (Gate 1)', style: TextStyle(fontSize: 11)),
                              ),
                            if (srv.isVerified && !srv.isActive)
                              ElevatedButton(
                                onPressed: () => _handleServicePublish(srv.id),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('Publish (Gate 2)', style: TextStyle(fontSize: 11)),
                              ),
                            if (srv.isActive)
                              OutlinedButton(
                                onPressed: () => _handleServiceUnpublish(srv.id),
                                child: const Text('Unpublish', style: TextStyle(fontSize: 11)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDindiLeadersTab() {
    final pendingApplications = _dindiLeaders.where((l) => (l.status).toLowerCase() == 'pending').toList();
    final filtered = _dindiLeaders.where((l) {
      if (_dindiLeaderFilter == 'ALL') return true;
      return (l.status).toUpperCase() == _dindiLeaderFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('Application Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _dindiLeaderFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Applications')),
                  DropdownMenuItem(value: 'PENDING', child: Text('Pending Approval')),
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Approved Active')),
                  DropdownMenuItem(value: 'SUSPENDED', child: Text('Suspended')),
                ],
                onChanged: (v) => setState(() => _dindiLeaderFilter = v!),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 1. Prominent Pending Applications Banner
              if (pendingApplications.isNotEmpty && _dindiLeaderFilter != 'ACTIVE' && _dindiLeaderFilter != 'SUSPENDED') ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top, color: Colors.amber.shade900),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${pendingApplications.length} Pending Dindi Leader Application(s) Awaiting Admin Verification',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Dindi Leader Applications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No Dindi Leader applications matching filter.'),
                )
              else
                ...filtered.map((leader) {
                  final statusLower = (leader.status).toLowerCase();
                  final isPending = statusLower == 'pending';
                  final isActive = statusLower == 'active';
                  final isSuspended = statusLower == 'suspended';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isPending ? 3 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isPending
                            ? Colors.amber.shade600
                            : isSuspended
                                ? Colors.red.shade300
                                : Colors.grey.shade300,
                        width: isPending ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  leader.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? Colors.amber.shade100
                                      : isActive
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  leader.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isPending
                                        ? Colors.amber.shade900
                                        : isActive
                                            ? Colors.green.shade900
                                            : Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(leader.phone.isNotEmpty ? leader.phone : 'No phone provided', style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 16),
                              const Icon(Icons.email, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  leader.email.isNotEmpty ? leader.email : 'No email provided',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (leader.dindiName != null && leader.dindiName!.isNotEmpty) ...[
                            const Divider(height: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.groups, size: 16, color: Colors.blue),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Troupe: ${leader.dindiName}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (leader.startPoint != null || leader.destination != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Route: ${leader.startPoint ?? "Alandi"} ➔ ${leader.destination ?? "Pandharpur"}'
                                      '${leader.memberCount != null ? " • Expected Varkaris: ${leader.memberCount}" : ""}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isPending) ...[
                                OutlinedButton.icon(
                                  onPressed: () => _handleDindiLeaderReject(leader.id),
                                  icon: const Icon(Icons.close, size: 14, color: Colors.red),
                                  label: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _handleDindiLeaderApprove(leader.id),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                  label: const Text(
                                    'Approve / Authenticate',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              if (isActive)
                                OutlinedButton.icon(
                                  onPressed: () => _handleDindiLeaderSuspend(leader.id),
                                  icon: const Icon(Icons.block, size: 14, color: Colors.orange),
                                  label: const Text('Suspend Access', style: TextStyle(color: Colors.orange, fontSize: 12)),
                                ),
                              if (isSuspended)
                                ElevatedButton.icon(
                                  onPressed: () => _handleDindiLeaderApprove(leader.id),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  icon: const Icon(Icons.refresh, size: 14, color: Colors.white),
                                  label: const Text('Re-instate / Unsuspend', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              if (_dindis.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Registered Dindi Troupes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ..._dindis.map((dindi) {
                  final statusLower = (dindi.status).toLowerCase();
                  final isPending = statusLower == 'pending';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${dindi.dindiNumber} — ${dindi.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leader: ${dindi.leaderName} (${dindi.leaderPhone})\nRoute: ${dindi.startPoint} ➔ ${dindi.destination} | Members: ${dindi.memberCount}\nStatus: ${dindi.status.toUpperCase()}',
                          ),
                          if (dindi.leaderImageUrl.isNotEmpty || dindi.documentUrl.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (dindi.leaderImageUrl.isNotEmpty)
                                  Chip(
                                    avatar: const Icon(Icons.person, size: 14, color: Colors.blue),
                                    label: const Text('Leader Photo Verified', style: TextStyle(fontSize: 10)),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                if (dindi.documentUrl.isNotEmpty)
                                  ActionChip(
                                    avatar: const Icon(Icons.description, size: 14, color: Colors.indigo),
                                    label: const Text('View Registration Doc', style: TextStyle(fontSize: 10, color: Colors.indigo, fontWeight: FontWeight.bold)),
                                    backgroundColor: Colors.indigo.shade50,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Verification Document: ${dindi.documentUrl}')),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          if (isPending) ...[
                            ElevatedButton(
                              onPressed: () => _handleDindiApprove(dindi.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Approve', style: TextStyle(fontSize: 11)),
                            ),
                            OutlinedButton(
                              onPressed: () => _handleDindiReject(dindi.id),
                              child: const Text('Reject', style: TextStyle(fontSize: 11, color: Colors.red)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLostPersonsTab() {
    if (_lostPersons.isEmpty) return const Center(child: Text('No missing person cases found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lostPersons.length,
      itemBuilder: (context, i) {
        final lp = _lostPersons[i];
        final isApproved = lp.isApprovedByAdmin;
        final isClosed = lp.status.toLowerCase() == 'found' || lp.status.toLowerCase() == 'closed';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(lp.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Age: ${lp.age} | Gender: ${lp.gender}\nLast Seen: ${lp.lastSeenLocation}\nApproved Broadcast: $isApproved | Status: ${lp.status.toUpperCase()}'),
            isThreeLine: true,
            trailing: Wrap(
              spacing: 6,
              children: [
                if (!isApproved && !isClosed)
                  ElevatedButton(
                    onPressed: () => _handleLostPersonApprove(lp.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Approve Broadcast', style: TextStyle(fontSize: 11)),
                  ),
                if (!isClosed)
                  OutlinedButton(
                    onPressed: () => _handleLostPersonClose(lp.id),
                    child: const Text('Close (Found)', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceReportsTab() {
    if (_serviceReports.isEmpty) return const Center(child: Text('No service reports submitted.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _serviceReports.length,
      itemBuilder: (context, i) {
        final rpt = _serviceReports[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('${rpt.issueType} — ${rpt.serviceName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Reporter: ${rpt.reporterName}\nDescription: ${rpt.description}\nAdmin Notes: ${rpt.adminNotes}'),
            isThreeLine: true,
            trailing: Chip(
              label: Text(rpt.status.toUpperCase()),
              backgroundColor: rpt.status == 'resolved' ? Colors.green.shade100 : Colors.amber.shade100,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    final filtered = _users.where((u) {
      if (_userRoleFilter == 'ALL') return true;
      return u.role.toUpperCase() == _userRoleFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('User Role Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _userRoleFilter,
                items: const [
                  DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
                  DropdownMenuItem(value: 'PILGRIM', child: Text('Pilgrim')),
                  DropdownMenuItem(value: 'DINDI_LEADER', child: Text('Dindi Leader')),
                  DropdownMenuItem(value: 'POLICE_AUTHORITY', child: Text('Police Authority')),
                  DropdownMenuItem(value: 'NGO_VOLUNTEER', child: Text('NGO Volunteer')),
                  DropdownMenuItem(value: 'LOCAL_CITIZEN', child: Text('Local Citizen')),
                ],
                onChanged: (v) => setState(() => _userRoleFilter = v!),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No user profiles found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final u = filtered[i];
                    final isSuspended = u.status.toLowerCase() == 'suspended';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(u.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Role: ${u.role} | Email: ${u.email}'),
                        trailing: OutlinedButton(
                          onPressed: () => _handleUserStatusChange(u.id, u.status),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isSuspended ? Colors.green : Colors.red,
                          ),
                          child: Text(isSuspended ? 'Activate' : 'Suspend'),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAuditTrailTab() {
    if (_auditLogs.isEmpty) return const Center(child: Text('No audit logs recorded yet.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _auditLogs.length,
      itemBuilder: (context, i) {
        final log = _auditLogs[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.verified_user, color: Colors.purple),
            title: Text('${log.action} — ${log.targetType}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Target ID: ${log.targetId}\nReason: ${log.reason}\nAdmin: ${log.adminEmail} | Time: ${log.createdAt}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildPalkhisTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePalkhiDialog,
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create New Palkhi'),
      ),
      body: _palkhis.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bus_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No Palkhi entities configured in registry.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _showCreatePalkhiDialog, child: const Text('Add Palkhi')),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _palkhis.length,
              itemBuilder: (context, index) {
                final palkhi = _palkhis[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_bus, color: Colors.orange, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    palkhi.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Saint: ${palkhi.saint} | Route: ${palkhi.startPoint} ➔ ${palkhi.destination}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: palkhi.isPublished ? Colors.green.shade100 : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                palkhi.isPublished ? 'PUBLISHED' : 'UNPUBLISHED',
                                style: TextStyle(
                                  color: palkhi.isPublished ? Colors.green.shade900 : Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.purple),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Current Stage: ${palkhi.currentStage} (Next: ${palkhi.nextStop})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_pin, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Operator: ${palkhi.operatorName} ${palkhi.operatorEmail.isNotEmpty ? "(${palkhi.operatorEmail})" : ""}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: palkhi.assignedOperatorId != null ? FontWeight.bold : FontWeight.normal,
                                  color: palkhi.assignedOperatorId != null ? Colors.blue.shade900 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Planned Multi-Day Halts Schedule Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Planned Halts (${palkhi.halts.length})',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAddHaltDialog(palkhi),
                              icon: const Icon(Icons.add_location_alt, size: 16),
                              label: const Text('+ Add Halt'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (palkhi.halts.isEmpty) ...[
                          const Text(
                            'No scheduled halts added yet. Tap "+ Add Halt" to set up day-by-day stops.',
                            style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
                          ),
                        ] else ...[
                          Column(
                            children: palkhi.halts.map((halt) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[100],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Day ${halt.dayNumber}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: Colors.purple[900],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${halt.haltDate} — ${halt.locationName}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Text(
                                            'Arr: ${halt.expectedArrival ?? "N/A"} | Dep: ${halt.expectedDeparture ?? "N/A"} | Next: ${halt.nextDestination ?? "N/A"}',
                                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      onPressed: () async {
                                        final success = await _repository.deletePalkhiHalt(halt.id);
                                        if (success) {
                                          _showMessage('Planned halt deleted.');
                                          _fetchAllData();
                                        } else {
                                          _showMessage('Failed to delete halt.', isError: true);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!palkhi.isPublished)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final success = await _repository.publishPalkhi(palkhi.id);
                                  if (success) {
                                    _showMessage('Palkhi published to public live map.');
                                    _fetchAllData();
                                  } else {
                                    _showMessage('Failed to publish Palkhi.', isError: true);
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('Publish'),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final success = await _repository.unpublishPalkhi(palkhi.id);
                                  if (success) {
                                    _showMessage('Palkhi unpublished from public view.');
                                    _fetchAllData();
                                  } else {
                                    _showMessage('Failed to unpublish Palkhi.', isError: true);
                                  }
                                },
                                icon: const Icon(Icons.visibility_off, size: 16),
                                label: const Text('Unpublish'),
                              ),
                            OutlinedButton.icon(
                              onPressed: () => _showAssignOperatorDialog(palkhi),
                              icon: const Icon(Icons.person_add, size: 16),
                              label: Text(palkhi.assignedOperatorId != null ? 'Change Operator' : 'Assign Operator'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Palkhi Entity'),
                                    content: Text('Are you sure you want to delete ${palkhi.name}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  final success = await _repository.deletePalkhi(palkhi.id);
                                  if (success) {
                                    _showMessage('Palkhi deleted.');
                                    _fetchAllData();
                                  } else {
                                    _showMessage('Failed to delete Palkhi.', isError: true);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showCreatePalkhiDialog() async {
    final nameCtrl = TextEditingController(text: 'Sant Tukaram Maharaj Palkhi');
    final saintCtrl = TextEditingController(text: 'Sant Tukaram Maharaj');
    final startCtrl = TextEditingController(text: 'Dehu');
    final destCtrl = TextEditingController(text: 'Pandharpur');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Central Palkhi Entity'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Palkhi Name')),
              const SizedBox(height: 8),
              TextField(controller: saintCtrl, decoration: const InputDecoration(labelText: 'Saint / Tradition')),
              const SizedBox(height: 8),
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Point')),
              const SizedBox(height: 8),
              TextField(controller: destCtrl, decoration: const InputDecoration(labelText: 'Destination')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _repository.createPalkhi({
                'name': nameCtrl.text.trim(),
                'saint': saintCtrl.text.trim(),
                'start_point': startCtrl.text.trim(),
                'destination': destCtrl.text.trim(),
              });
              if (success) {
                _showMessage('New Palkhi entity created (Unpublished by default).');
                _fetchAllData();
              } else {
                _showMessage('Failed to create Palkhi. Check API logs.', isError: true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssignOperatorDialog(AdminPalkhi palkhi) async {
    final operatorIdCtrl = TextEditingController(text: palkhi.assignedOperatorId ?? '00000000-0000-0000-0000-000000000002');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Operator to ${palkhi.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Profile User ID for Privileged Location Operator:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: operatorIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Operator User ID (UUID)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          if (palkhi.assignedOperatorId != null)
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await _repository.assignPalkhiOperator(palkhi.id, null);
                if (success) {
                  _showMessage('Operator assignment removed.');
                  _fetchAllData();
                } else {
                  _showMessage('Failed to remove operator assignment.', isError: true);
                }
              },
              child: const Text('Remove Operator', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final opId = operatorIdCtrl.text.trim();
              if (opId.isNotEmpty) {
                final success = await _repository.assignPalkhiOperator(palkhi.id, opId);
                if (success) {
                  _showMessage('Location Operator assigned successfully.');
                  _fetchAllData();
                } else {
                  _showMessage('Failed to assign Location Operator.', isError: true);
                }
              }
            },
            child: const Text('Assign Operator'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddHaltDialog(AdminPalkhi palkhi) async {
    final nextDayNum = palkhi.halts.isNotEmpty
        ? (palkhi.halts.map((h) => h.dayNumber).reduce((a, b) => a > b ? a : b) + 1)
        : 1;

    final dayCtrl = TextEditingController(text: '$nextDayNum');
    final dateCtrl = TextEditingController(text: '2026-06-${17 + nextDayNum}');
    final locCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final arrCtrl = TextEditingController(text: '08:00');
    final depCtrl = TextEditingController(text: '12:00');
    final nextCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Scheduled Halt — ${palkhi.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dayCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Day Number *'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: dateCtrl,
                      decoration: const InputDecoration(labelText: 'Halt Date (YYYY-MM-DD) *'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Location Name (e.g. Pune Stay) *'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: arrCtrl,
                      decoration: const InputDecoration(labelText: 'Expected Arrival (HH:MM)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: depCtrl,
                      decoration: const InputDecoration(labelText: 'Expected Departure (HH:MM)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nextCtrl,
                decoration: const InputDecoration(labelText: 'Next Destination Point'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Approx Lat (Optional)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: lngCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Approx Lng (Optional)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final day = int.tryParse(dayCtrl.text.trim());
              final loc = locCtrl.text.trim();
              final date = dateCtrl.text.trim();
              if (day == null || day <= 0 || loc.isEmpty || date.isEmpty) {
                _showMessage('Day Number, Date, and Location Name are required.', isError: true);
                return;
              }
              Navigator.pop(ctx);
              final success = await _repository.addPalkhiHalt(palkhi.id, {
                'day_number': day,
                'halt_date': date,
                'location_name': loc,
                'expected_arrival': arrCtrl.text.trim(),
                'expected_departure': depCtrl.text.trim(),
                'next_destination': nextCtrl.text.trim(),
                'approx_latitude': double.tryParse(latCtrl.text.trim()),
                'approx_longitude': double.tryParse(lngCtrl.text.trim()),
              });
              if (success) {
                _showMessage('Planned halt added for Day $day.');
                _fetchAllData();
              } else {
                _showMessage('Failed to add planned halt.', isError: true);
              }
            },
            child: const Text('Add Halt'),
          ),
        ],
      ),
    );
  }
}

