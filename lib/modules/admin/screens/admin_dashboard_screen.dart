import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _baseUrl = 'http://localhost:3000/api/admin';
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'x-admin-id': '00000000-0000-0000-0000-000000000000',
    'x-admin-role': 'admin',
  };

  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _ngos = [];
  List<dynamic> _services = [];
  List<dynamic> _lostPersons = [];
  List<dynamic> _auditLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_baseUrl/dashboard'), headers: _headers),
        http.get(Uri.parse('$_baseUrl/ngos'), headers: _headers),
        http.get(Uri.parse('$_baseUrl/services'), headers: _headers),
        http.get(Uri.parse('$_baseUrl/lost-persons'), headers: _headers),
        http.get(Uri.parse('$_baseUrl/audit-logs'), headers: _headers),
      ]);

      if (mounted) {
        setState(() {
          _dashboardData = results[0].statusCode == 200
              ? jsonDecode(results[0].body)
              : {};
          _ngos = results[1].statusCode == 200
              ? jsonDecode(results[1].body)
              : [];
          _services = results[2].statusCode == 200
              ? jsonDecode(results[2].body)
              : [];
          _lostPersons = results[3].statusCode == 200
              ? jsonDecode(results[3].body)
              : [];
          _auditLogs = results[4].statusCode == 200
              ? jsonDecode(results[4].body)
              : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load Admin Data: $e')),
        );
      }
    }
  }

  Future<void> _approveNgo(String id) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/ngos/$id/approve'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      _showMessage('NGO approved successfully');
      _fetchAllData();
    }
  }

  Future<void> _rejectNgo(String id) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/ngos/$id/reject'),
      headers: _headers,
      body: jsonEncode({'reason': 'Unverified documents'}),
    );
    if (res.statusCode == 200) {
      _showMessage('NGO rejected');
      _fetchAllData();
    }
  }

  Future<void> _approveService(String id) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/services/$id/approve'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      _showMessage('Service verified (Gate 1)');
      _fetchAllData();
    }
  }

  Future<void> _publishService(String id) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/services/$id/publish'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      _showMessage('Service published to Pilgrims (Gate 2)');
      _fetchAllData();
    }
  }

  Future<void> _approveLostPerson(String id) async {
    final res = await http.patch(
      Uri.parse('$_baseUrl/lost-persons/$id/approve'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      _showMessage('Lost person case approved for public alert');
      _fetchAllData();
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.purple.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Control Plane'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAllData,
            tooltip: 'Refresh Data',
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
            Tab(icon: Icon(Icons.person_search), text: 'Lost Persons'),
            Tab(icon: Icon(Icons.history), text: 'Audit Trail'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildNgosTab(),
                _buildServicesTab(),
                _buildLostPersonsTab(),
                _buildAuditTrailTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Governance Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard('Pending NGOs', '${_dashboardData['pending_ngos'] ?? 0}', Colors.orange),
              _buildStatCard('Pending Services', '${_dashboardData['pending_services'] ?? 0}', Colors.deepOrange),
              _buildStatCard('Pending Dindis', '${_dashboardData['pending_dindis'] ?? 0}', Colors.blue),
              _buildStatCard('Lost Person Cases', '${_dashboardData['pending_lost_person_reports'] ?? 0}', Colors.red),
              _buildStatCard('Service Reports', '${_dashboardData['open_service_reports'] ?? 0}', Colors.amber),
              _buildStatCard('Active Emergencies', '${_dashboardData['active_emergencies'] ?? 0}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildNgosTab() {
    if (_ngos.isEmpty) return const Center(child: Text('No NGO submissions found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ngos.length,
      itemBuilder: (context, i) {
        final ngo = _ngos[i];
        final isApproved = ngo['status'] == 'approved';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(ngo['name'] ?? 'NGO', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Reg: ${ngo['registration_number']} | Contact: ${ngo['contact_person'] ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(ngo['status']?.toUpperCase() ?? 'PENDING'),
                  backgroundColor: isApproved ? Colors.green.shade100 : Colors.orange.shade100,
                ),
                if (!isApproved) ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _approveNgo(ngo['id']),
                    tooltip: 'Approve NGO',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _rejectNgo(ngo['id']),
                    tooltip: 'Reject NGO',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab() {
    if (_services.isEmpty) return const Center(child: Text('No Seva facilities found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, i) {
        final srv = _services[i];
        final isVerified = srv['is_verified'] == true;
        final isActive = srv['is_active'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(srv['name'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${srv['category']} | ${srv['address']}\nGate 1 (Verified): $isVerified | Gate 2 (Active): $isActive'),
            isThreeLine: true,
            trailing: Wrap(
              spacing: 6,
              children: [
                if (!isVerified)
                  ElevatedButton(
                    onPressed: () => _approveService(srv['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Verify (Gate 1)', style: TextStyle(fontSize: 11)),
                  ),
                if (isVerified && !isActive)
                  ElevatedButton(
                    onPressed: () => _publishService(srv['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Publish (Gate 2)', style: TextStyle(fontSize: 11)),
                  ),
                if (isVerified && isActive)
                  const Chip(
                    label: Text('PUBLIC'),
                    backgroundColor: Colors.greenAccent,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLostPersonsTab() {
    if (_lostPersons.isEmpty) return const Center(child: Text('No missing person cases found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lostPersons.length,
      itemBuilder: (context, i) {
        final lp = _lostPersons[i];
        final isApproved = lp['is_approved_by_admin'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(lp['person_name'] ?? 'Lost Person', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Age: ${lp['age'] ?? 'N/A'} | Last Seen: ${lp['last_seen_location']}\nApproved Broadcast: $isApproved'),
            isThreeLine: true,
            trailing: isApproved
                ? const Chip(label: Text('BROADCAST ACTIVE'), backgroundColor: Colors.redAccent)
                : ElevatedButton(
                    onPressed: () => _approveLostPerson(lp['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Approve Broadcast'),
                  ),
          ),
        );
      },
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
            title: Text('${log['action']} — ${log['target_type']}'),
            subtitle: Text('Target ID: ${log['target_id']}\nTime: ${log['created_at']}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
