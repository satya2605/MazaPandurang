import 'package:flutter/material.dart';
import '../models/citizen_service.dart';

/// Reusable card widget showing one service entry.
/// Owned by: Gauri — Local Citizen Module
///
/// Shows: name, category, status badge, distance, last updated.
/// Actions: View Details button.
class CitizenServiceCard extends StatelessWidget {
  final CitizenService service;
  final VoidCallback onTap;

  const CitizenServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Top row: icon + name + status badge --
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _categoryColor(service.category).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon(service.category),
                      color: _categoryColor(service.category),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + category label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${service.category.label} • ${service.category.marathiLabel}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  _StatusBadge(status: service.status),
                ],
              ),

              const SizedBox(height: 12),

              // -- Address row --
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // -- Distance + last updated row --
              Row(
                children: [
                  Icon(Icons.straighten, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    service.distanceLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service.lastUpdatedLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // -- Action buttons --
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        foregroundColor: const Color(0xFF6A1B9A),
                        side: const BorderSide(color: Color(0xFF6A1B9A)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the right icon for each service category.
  IconData _categoryIcon(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.medical:
        return Icons.medical_services_outlined;
      case ServiceCategory.food:
        return Icons.restaurant_outlined;
      case ServiceCategory.water:
        return Icons.water_drop_outlined;
      case ServiceCategory.toilet:
        return Icons.wc_outlined;
      case ServiceCategory.nightHalt:
        return Icons.hotel_outlined;
      case ServiceCategory.parking:
        return Icons.local_parking_outlined;
      case ServiceCategory.police:
        return Icons.local_police_outlined;
      case ServiceCategory.hospital:
        return Icons.local_hospital_outlined;
      case ServiceCategory.pharmacy:
        return Icons.medication_outlined;
      case ServiceCategory.helpCentre:
        return Icons.support_agent_outlined;
      case ServiceCategory.other:
        return Icons.place_outlined;
    }
  }

  /// Returns a colour for each category icon.
  Color _categoryColor(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.medical:
        return const Color(0xFFC62828);
      case ServiceCategory.food:
        return const Color(0xFFE65100);
      case ServiceCategory.water:
        return const Color(0xFF0277BD);
      case ServiceCategory.toilet:
        return const Color(0xFF558B2F);
      case ServiceCategory.nightHalt:
        return const Color(0xFF4527A0);
      case ServiceCategory.parking:
        return const Color(0xFF37474F);
      case ServiceCategory.police:
        return const Color(0xFF1565C0);
      case ServiceCategory.hospital:
        return const Color(0xFFAD1457);
      case ServiceCategory.pharmacy:
        return const Color(0xFF00695C);
      case ServiceCategory.helpCentre:
        return const Color(0xFF6A1B9A);
      case ServiceCategory.other:
        return const Color(0xFF546E7A);
    }
  }
}

/// The coloured status badge shown on each service card.
class _StatusBadge extends StatelessWidget {
  final ServiceStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor(status).withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _badgeColor(status).withAlpha(80)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _badgeColor(status),
        ),
      ),
    );
  }

  Color _badgeColor(ServiceStatus s) {
    switch (s) {
      case ServiceStatus.open:
      case ServiceStatus.available:
        return const Color(0xFF2E7D32); // green
      case ServiceStatus.limited:
        return const Color(0xFFE65100); // orange
      case ServiceStatus.full:
      case ServiceStatus.finished:
      case ServiceStatus.closed:
        return const Color(0xFFC62828); // red
      case ServiceStatus.unknown:
        return const Color(0xFF546E7A); // grey
    }
  }
}
