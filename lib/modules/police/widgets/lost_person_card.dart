import 'package:flutter/material.dart';
import '../data/models/lost_person_case.dart';
import 'status_badge.dart';

Color _lostPersonStatusColor(LostPersonStatus status) {
  switch (status) {
    case LostPersonStatus.pendingApproval:
      return const Color(0xFF7B1FA2);
    case LostPersonStatus.approved:
      return const Color(0xFF1565C0);
    case LostPersonStatus.resolved:
      return const Color(0xFF388E3C);
  }
}

class LostPersonCard extends StatelessWidget {
  final LostPersonCase person;
  final VoidCallback? onTap;

  const LostPersonCard({super.key, required this.person, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _lostPersonStatusColor(person.status);
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
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person_search, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        person.id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const Spacer(),
                      StatusBadge(
                        label: person.statusLabel,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Color(0xFF999999),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'Last seen: ${person.lastSeenDescription}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (person.sightingCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${person.sightingCount} sightings',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ],
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
