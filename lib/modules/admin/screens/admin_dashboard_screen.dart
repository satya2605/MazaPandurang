import 'package:flutter/material.dart';
import '../../../common/navigation/app_routes.dart';
import '../../../core/auth/auth_service.dart';
import '../models/admin_models.dart';
import '../repositories/admin_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
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

  // Filter states
  String _ngoFilter = 'ALL';
  String _serviceFilter = 'ALL';
  String _dindiLeaderFilter = 'ALL';
  String _userRoleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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
              _buildStatCard('Pending NGOs', '${stats?.pendingNgos ?? 0}', Colors.orange, 1),
              _buildStatCard('Pending Services', '${stats?.pendingServices ?? 0}', Colors.deepOrange, 2),
              _buildStatCard('Pending Dindi Leaders', '${stats?.pendingDindiLeaders ?? 0}', Colors.blue, 3),
              _buildStatCard('Pending Dindis', '${stats?.pendingDindis ?? 0}', Colors.indigo, 3),
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

  Widget _buildStatCard(String label, String value, Color color, int targetTabIndex) {
    return InkWell(
      onTap: () => _tabController.animateTo(targetTabIndex),
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
    final filtered = _dindiLeaders.where((l) {
      if (_dindiLeaderFilter == 'ALL') return true;
      return l.status.toUpperCase() == _dindiLeaderFilter;
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
              if (_dindis.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Registered Dindi Troupes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ..._dindis.map((dindi) {
                  final isPending = dindi.status.toLowerCase() == 'pending';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${dindi.dindiNumber} — ${dindi.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Leader: ${dindi.leaderName} (${dindi.leaderPhone})\nRoute: ${dindi.startPoint} ➔ ${dindi.destination} | Members: ${dindi.memberCount}\nStatus: ${dindi.status.toUpperCase()}'),
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
                const Divider(),
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
                  final isPending = leader.status.toLowerCase() == 'pending';
                  final isActive = leader.status.toLowerCase() == 'active';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(leader.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Email: ${leader.email} | Phone: ${leader.phone}\nStatus: ${leader.status.toUpperCase()}'),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          if (isPending) ...[
                            ElevatedButton(
                              onPressed: () => _handleDindiLeaderApprove(leader.id),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('Approve', style: TextStyle(fontSize: 11)),
                            ),
                            OutlinedButton(
                              onPressed: () => _handleDindiLeaderReject(leader.id),
                              child: const Text('Reject', style: TextStyle(fontSize: 11, color: Colors.red)),
                            ),
                          ],
                          if (isActive)
                            OutlinedButton(
                              onPressed: () => _handleDindiLeaderSuspend(leader.id),
                              child: const Text('Suspend', style: TextStyle(fontSize: 11, color: Colors.orange)),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
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
}
