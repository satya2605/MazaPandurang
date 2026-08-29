import 'package:flutter/material.dart';
import '../models/citizen_service.dart';

/// Service Details Screen — shows full info for one service.
/// Owned by: Gauri — Local Citizen Module
///
/// Shows:
/// - Service name, category, status
/// - Full address
/// - Phone number (tappable to note)
/// - Description
/// - Last updated time
/// - "Report Incorrect Information" button (Phase 3)
/// - "Open in Google Maps" button
class CitizenServiceDetailsScreen extends StatelessWidget {
  final CitizenService service;

  const CitizenServiceDetailsScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(service.status);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // -- Top banner with gradient and service icon --
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _categoryColor(service.category),
                      _categoryColor(service.category).withAlpha(180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          _categoryIcon(service.category),
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${service.category.label} • ${service.category.marathiLabel}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // -- Scrollable content --
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Name + Status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: statusColor.withAlpha(80)),
                      ),
                      child: Text(
                        service.status.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Info tiles
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: service.address,
                ),
                const SizedBox(height: 14),

                _InfoTile(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: service.distanceLabel,
                  valueColor: const Color(0xFF6A1B9A),
                ),
                const SizedBox(height: 14),

                if (service.phone != null) ...[
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: service.phone!,
                    valueColor: const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 14),
                ],

                if (service.description != null) ...[
                  _InfoTile(
                    icon: Icons.info_outline,
                    label: 'About',
                    value: service.description!,
                  ),
                  const SizedBox(height: 14),
                ],

                _InfoTile(
                  icon: Icons.access_time,
                  label: 'Last Updated',
                  value: service.lastUpdatedLabel,
                  valueColor: Colors.grey[600],
                ),

                const SizedBox(height: 28),

                // -- Action buttons --
                ElevatedButton.icon(
                  onPressed: () => _openInGoogleMaps(context, service),
                  icon: const Icon(Icons.directions),
                  label: const Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () => _reportIncorrectInfo(context),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Report Incorrect Information'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE65100),
                    side: const BorderSide(color: Color(0xFFE65100)),
                  ),
                ),

                const SizedBox(height: 28),

                // Data notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Service availability is updated by NGO volunteers and police. Data may be up to 30 minutes old.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens Google Maps with the service location.
  void _openInGoogleMaps(BuildContext context, CitizenService s) {
    // In Phase 6 we will use url_launcher to open Google Maps.
    // For now, show a message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Would open Google Maps for: ${s.name}\n'
          'Lat: ${s.latitude}, Lng: ${s.longitude}',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows a dialog to report incorrect service information.
  /// Full implementation is Phase 3.
  void _reportIncorrectInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Incorrect Information'),
        content: const Text(
          'This feature will let you flag incorrect service details for admin review.\n\n'
          'Coming in the next phase!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ServiceStatus s) {
    switch (s) {
      case ServiceStatus.open:
      case ServiceStatus.available:
        return const Color(0xFF2E7D32);
      case ServiceStatus.limited:
        return const Color(0xFFE65100);
      case ServiceStatus.full:
      case ServiceStatus.finished:
      case ServiceStatus.closed:
        return const Color(0xFFC62828);
      case ServiceStatus.unknown:
        return const Color(0xFF546E7A);
    }
  }

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

  IconData _categoryIcon(ServiceCategory cat) {
    switch (cat) {
      case ServiceCategory.medical:
        return Icons.medical_services;
      case ServiceCategory.food:
        return Icons.restaurant;
      case ServiceCategory.water:
        return Icons.water_drop;
      case ServiceCategory.toilet:
        return Icons.wc;
      case ServiceCategory.nightHalt:
        return Icons.hotel;
      case ServiceCategory.parking:
        return Icons.local_parking;
      case ServiceCategory.police:
        return Icons.local_police;
      case ServiceCategory.hospital:
        return Icons.local_hospital;
      case ServiceCategory.pharmacy:
        return Icons.medication;
      case ServiceCategory.helpCentre:
        return Icons.support_agent;
      case ServiceCategory.other:
        return Icons.place;
    }
  }
}

// ---------------------------------------------------------------------------
// Reusable info tile (label + value with icon)
// ---------------------------------------------------------------------------
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6A1B9A)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor ?? const Color(0xFF212121),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
