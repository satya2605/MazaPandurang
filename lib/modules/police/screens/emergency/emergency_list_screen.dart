import 'package:flutter/material.dart';
import '../../data/models/emergency_request.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../../widgets/emergency_card.dart';
import 'emergency_detail_screen.dart';

/// List of all emergency incidents — the Alerts tab.
class EmergencyListScreen extends StatefulWidget {
  const EmergencyListScreen({super.key});

  @override
  State<EmergencyListScreen> createState() => _EmergencyListScreenState();
}

class _EmergencyListScreenState extends State<EmergencyListScreen> {
  final _repo = PoliceDemoRepository.instance;
  static const _policeNavy = Color(0xFF1565C0);
  EmergencyStatus? _filter;

  List<EmergencyRequest> get _filtered {
    if (_filter == null) return _repo.emergencies;
    return _repo.emergencies.where((e) => e.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: _policeNavy,
        title: const Text(
          'Emergency Incidents',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<EmergencyStatus?>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(
                value: EmergencyStatus.newCase,
                child: Text('NEW'),
              ),
              const PopupMenuItem(
                value: EmergencyStatus.acknowledged,
                child: Text('ACKNOWLEDGED'),
              ),
              const PopupMenuItem(
                value: EmergencyStatus.assigned,
                child: Text('ASSIGNED'),
              ),
              const PopupMenuItem(
                value: EmergencyStatus.inProgress,
                child: Text('IN PROGRESS'),
              ),
              const PopupMenuItem(
                value: EmergencyStatus.resolved,
                child: Text('RESOLVED'),
              ),
            ],
          ),
        ],
      ),
      body: _filtered.isEmpty
          ? const Center(child: Text('No emergencies match filter.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final e = _filtered[i];
                return EmergencyCard(
                  emergency: e,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmergencyDetailScreen(emergency: e),
                      ),
                    );
                    setState(() {}); // refresh after status change
                  },
                );
              },
            ),
    );
  }
}
