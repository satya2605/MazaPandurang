import 'package:flutter/material.dart';
import '../../data/models/traffic_alert.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../../widgets/traffic_alert_card.dart';
import 'add_diversion_screen.dart';

/// Traffic alert management list with + Add Diversion FAB.
class TrafficListScreen extends StatefulWidget {
  const TrafficListScreen({super.key});

  @override
  State<TrafficListScreen> createState() => _TrafficListScreenState();
}

class _TrafficListScreenState extends State<TrafficListScreen> {
  final _repo = PoliceDemoRepository.instance;
  static const _amber = Color(0xFFF57F17);

  List<TrafficAlert> get _active =>
      _repo.trafficAlerts
          .where((t) => t.status == TrafficAlertStatus.active)
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: _amber,
        title: const Text(
          'Traffic & Diversions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading:
            Navigator.of(context).canPop(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDiversionScreen()),
          );
          setState(() {});
        },
        backgroundColor: _amber,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Diversion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _active.isEmpty
          ? const Center(child: Text('No active traffic alerts.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _active.length,
              itemBuilder: (_, i) => TrafficAlertCard(
                alert: _active[i],
                onTap: () {
                  // Future: open detail/edit screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_active[i].title} — ${_active[i].typeLabel}',
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
