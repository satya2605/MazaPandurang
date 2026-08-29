import 'package:flutter/material.dart';
import '../data/models/emergency_request.dart';
import 'status_badge.dart';

Color _emergencyStatusColor(EmergencyStatus status) {
  switch (status) {
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

class EmergencyCard extends StatelessWidget {
  final EmergencyRequest emergency;
  final VoidCallback? onTap;

  const EmergencyCard({super.key, required this.emergency, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _emergencyStatusColor(emergency.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                emergency.status == EmergencyStatus.newCase
                    ? const Color(0xFFD32F2F).withAlpha(80)
                    : const Color(0xFFE0E0E0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
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
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.emergency, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        emergency.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const Spacer(),
                      StatusBadge(
                        label: emergency.statusLabel,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emergency.typeLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emergency.locationDescription,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
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
