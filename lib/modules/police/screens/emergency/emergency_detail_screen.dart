import 'package:flutter/material.dart';
import '../../data/models/emergency_request.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../../widgets/status_badge.dart';

Color _statusColor(EmergencyStatus s) {
  switch (s) {
    case EmergencyStatus.newCase:
      return const Color(0xFFD32F2F);
    case EmergencyStatus.acknowledged:
      return const Color(0xFFE65100);
    case EmergencyStatus.assigned:
      return const Color(0xFF1565C0);
    case EmergencyStatus.inProgress:
      return const Color(0xFF00695C);
    case EmergencyStatus.resolved:
      return const Color(0xFF388E3C);
  }
}

/// Full emergency detail with state machine action buttons and nearest medical camp.
class EmergencyDetailScreen extends StatefulWidget {
  final EmergencyRequest emergency;
  const EmergencyDetailScreen({super.key, required this.emergency});

  @override
  State<EmergencyDetailScreen> createState() => _EmergencyDetailScreenState();
}

class _EmergencyDetailScreenState extends State<EmergencyDetailScreen> {
  final _repo = PoliceDemoRepository.instance;

  EmergencyRequest get _e => widget.emergency;

  void _advance() {
    setState(() {
      switch (_e.status) {
        case EmergencyStatus.newCase:
          _e.status = EmergencyStatus.acknowledged;
          break;
        case EmergencyStatus.acknowledged:
          _e.status = EmergencyStatus.assigned;
          _e.assignedUnit = 'Police Unit P-04';
          break;
        case EmergencyStatus.assigned:
          _e.status = EmergencyStatus.inProgress;
          break;
        case EmergencyStatus.inProgress:
          _e.status = EmergencyStatus.resolved;
          break;
        case EmergencyStatus.resolved:
          break;
      }
    });
  }

  String _nextActionLabel() {
    switch (_e.status) {
      case EmergencyStatus.newCase:
        return 'Acknowledge';
      case EmergencyStatus.acknowledged:
        return 'Assign Response Unit';
      case EmergencyStatus.assigned:
        return 'Mark In Progress';
      case EmergencyStatus.inProgress:
        return 'Mark Resolved';
      case EmergencyStatus.resolved:
        return 'Resolved';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_e.status);
    final camp = _repo.findNearestMedicalCamp(_e.latitude, _e.longitude);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          _e.id,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withAlpha(30), statusColor.withAlpha(10)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withAlpha(80)),
            ),
            child: Row(
              children: [
                Icon(Icons.emergency, color: statusColor, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _e.typeLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusBadge(
                        label: _e.statusLabel,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _infoCard('Incident Details', [
            _row('Location', _e.locationDescription),
            _row(
              'Reported',
              '${_e.reportedAt.hour}:${_e.reportedAt.minute.toString().padLeft(2, '0')} today',
            ),
            _row('Description', _e.description),
            if (_e.assignedUnit != null)
              _row('Assigned Unit', _e.assignedUnit!),
          ]),
          const SizedBox(height: 14),

          // Nearest medical camp
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD32F2F).withAlpha(60),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Color(0xFFD32F2F),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nearest Medical Camp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        camp.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${camp.distanceKm} km away',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action button
          if (_e.status != EmergencyStatus.resolved)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _advance,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  _nextActionLabel(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF388E3C)),
                  SizedBox(width: 8),
                  Text(
                    'Emergency Resolved',
                    style: TextStyle(
                      color: Color(0xFF388E3C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
            ),
          ),
        ],
      ),
    );
  }
}
