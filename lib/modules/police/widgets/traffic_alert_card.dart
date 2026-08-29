import 'package:flutter/material.dart';
import '../data/models/traffic_alert.dart';
import 'status_badge.dart';

Color _trafficTypeColor(TrafficAlertType type) {
  switch (type) {
    case TrafficAlertType.roadBlock:
      return const Color(0xFFD32F2F);
    case TrafficAlertType.diversion:
      return const Color(0xFFF57F17);
    case TrafficAlertType.slow:
      return const Color(0xFFE65100);
    case TrafficAlertType.cleared:
      return const Color(0xFF388E3C);
  }
}

class TrafficAlertCard extends StatelessWidget {
  final TrafficAlert alert;
  final VoidCallback? onTap;

  const TrafficAlertCard({super.key, required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = _trafficTypeColor(alert.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: typeColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.traffic, color: typeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      StatusBadge(label: alert.typeLabel, color: typeColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Severity: ${alert.severityLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBBBBBB),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
