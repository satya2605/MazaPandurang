import 'package:flutter/material.dart';

/// Citizen Alerts Screen — shows traffic + local alerts.
/// Owned by: Gauri — Local Citizen Module
///
/// Phase 4 feature — will consume approved Police/Authority API.
/// For now, shows a placeholder with sample alert cards.
class CitizenAlertsScreen extends StatelessWidget {
  const CitizenAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alerts'),
            Text(
              'सतर्कता सूचना',
              style: TextStyle(fontSize: 12, color: Color(0xFF6A1B9A)),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Phase notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: const Row(
              children: [
                Icon(Icons.construction, color: Color(0xFFE65100), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Live alerts from Police/Authority will appear here in Phase 4. Showing sample data.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sample alert cards
          const _AlertCard(
            type: AlertType.traffic,
            title: 'Road Closure — Vitthal Mandir Road',
            description:
                'Vitthal Mandir Road is closed for vehicle traffic from 6 AM to 9 PM during Wari. Use alternate routes.',
            timeAgo: '10 min ago',
            severity: AlertSeverity.high,
          ),
          const SizedBox(height: 12),
          const _AlertCard(
            type: AlertType.diversion,
            title: 'Traffic Diversion — Bhima Bridge',
            description:
                'Heavy pedestrian traffic on Bhima Bridge. Vehicles advised to use Chandrabhaga Bridge.',
            timeAgo: '25 min ago',
            severity: AlertSeverity.medium,
          ),
          const SizedBox(height: 12),
          const _AlertCard(
            type: AlertType.info,
            title: 'Parking Available — District Ground',
            description:
                'Temporary parking open at District Ground. Capacity: 500 vehicles. Free during Wari.',
            timeAgo: '1 hour ago',
            severity: AlertSeverity.low,
          ),
          const SizedBox(height: 12),
          const _AlertCard(
            type: AlertType.safety,
            title: 'Safety Notice — Crowd Alert',
            description:
                'Extreme crowd near Vitthal Mandir entrance between 5 PM – 8 PM. Plan accordingly.',
            timeAgo: '2 hours ago',
            severity: AlertSeverity.high,
          ),
        ],
      ),
    );
  }
}

enum AlertType { traffic, diversion, info, safety }

enum AlertSeverity { low, medium, high }

class _AlertCard extends StatelessWidget {
  final AlertType type;
  final String title;
  final String description;
  final String timeAgo;
  final AlertSeverity severity;

  const _AlertCard({
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon(type), color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _severityLabel(severity),
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _severityColor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.low:
        return const Color(0xFF2E7D32);
      case AlertSeverity.medium:
        return const Color(0xFFE65100);
      case AlertSeverity.high:
        return const Color(0xFFC62828);
    }
  }

  String _severityLabel(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.low:
        return 'INFO';
      case AlertSeverity.medium:
        return 'WARNING';
      case AlertSeverity.high:
        return 'URGENT';
    }
  }

  IconData _typeIcon(AlertType t) {
    switch (t) {
      case AlertType.traffic:
        return Icons.traffic;
      case AlertType.diversion:
        return Icons.alt_route;
      case AlertType.info:
        return Icons.local_parking;
      case AlertType.safety:
        return Icons.warning_amber;
    }
  }
}
