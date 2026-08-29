import 'package:flutter/material.dart';
import '../models/ngo_service.dart';
import '../services/ngo_repository.dart';

/// Reusable card displaying NGO Seva service with quick availability toggle.
class ServiceCard extends StatelessWidget {
  final NgoService service;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    required this.onEdit,
  });

  IconData _getCategoryIcon(NgoServiceCategory category) {
    switch (category) {
      case NgoServiceCategory.medical:
        return Icons.medical_services;
      case NgoServiceCategory.food:
        return Icons.restaurant;
      case NgoServiceCategory.water:
        return Icons.water_drop;
      case NgoServiceCategory.shelter:
        return Icons.night_shelter;
      case NgoServiceCategory.volunteer:
        return Icons.people;
      case NgoServiceCategory.lostAndFound:
        return Icons.find_in_page;
      case NgoServiceCategory.other:
        return Icons.volunteer_activism;
    }
  }

  Color _getAvailabilityColor(ServiceAvailability availability) {
    switch (availability) {
      case ServiceAvailability.available:
        return const Color(0xFF2E7D32);
      case ServiceAvailability.limited:
        return const Color(0xFFE65100);
      case ServiceAvailability.unavailable:
        return const Color(0xFFC62828);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final availColor = _getAvailabilityColor(service.availability);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: availColor.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF2E7D32).withAlpha(20),
                    child: Icon(
                      _getCategoryIcon(service.category),
                      color: const Color(0xFF2E7D32),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service.categoryLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<ServiceAvailability>(
                    tooltip: 'Change Availability',
                    itemBuilder: (context) =>
                        ServiceAvailability.values.map((avail) {
                      return PopupMenuItem(
                        value: avail,
                        child: Text(avail.name.toUpperCase()),
                      );
                    }).toList(),
                    onSelected: (newAvail) {
                      NgoRepository()
                          .updateServiceAvailability(service.id, newAvail);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Updated availability for ${service.name} to ${newAvail.name.toUpperCase()}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: availColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: availColor, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: availColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service.availabilityLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: availColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: availColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      service.locationName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF424242),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    service.operatingHours,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const Spacer(),
                  const Icon(Icons.groups_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    service.capacity,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Updated ${_formatTimeAgo(service.lastUpdatedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          foregroundColor: const Color(0xFF2E7D32),
                        ),
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 14),
                        label:
                            const Text('Edit', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          minimumSize: const Size(90, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 14),
                        label:
                            const Text('View', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
