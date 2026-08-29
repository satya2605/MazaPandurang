import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';

/// Modal Bottom Sheet helper displaying interactive marker cards.
class MapMarkerCard {
  static void showPalkhiCard({
    required BuildContext context,
    required PalkhiInfo palkhi,
    required VoidCallback onTrackSelected,
    required VoidCallback onAskTilakSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    palkhi.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Chip(
                  label: Text('LIVE'),
                  backgroundColor: Colors.orangeAccent,
                  labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('🚩 Current Stage: ${palkhi.currentStage}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('🔜 Next Stop: ${palkhi.nextStop}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('🕒 Last Updated: ${palkhi.lastUpdated.toString().substring(11, 16)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onTrackSelected();
                    },
                    icon: const Icon(Icons.my_location, size: 18),
                    label: const Text('Track Palkhi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onAskTilakSelected();
                    },
                    icon: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                    label: const Text('Ask Tilak'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showServiceCard({
    required BuildContext context,
    required WariService service,
    double? distanceKm,
    required VoidCallback onViewDetails,
    required VoidCallback onGetDirections,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(service.category.icon, color: service.category.color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      Text(service.category.label, style: TextStyle(color: service.category.color, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (distanceKm != null)
                  Chip(
                    avatar: const Icon(Icons.directions_walk, size: 14),
                    label: Text('${distanceKm.toStringAsFixed(1)} km'),
                    backgroundColor: Colors.blue.shade50,
                  ),
              ],
            ),
            const Divider(height: 20),
            Text('📍 ${service.address}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('📞 ${service.contactPhone.isNotEmpty ? service.contactPhone : "Open 24/7 Helpline"}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Row(
              children: [
                Chip(
                  label: Text(service.availabilityStatus),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const SizedBox(width: 8),
                if (service.isVerified)
                  const Chip(
                    label: Text('VERIFIED SEVA'),
                    backgroundColor: Colors.blueAccent,
                    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onViewDetails();
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onGetDirections();
                    },
                    icon: const Icon(Icons.directions, color: AppColors.primary, size: 18),
                    label: const Text('Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showTrafficCard({
    required BuildContext context,
    required TrafficAlert alert,
    required VoidCallback onAskTilakSelected,
  }) {
    final isHigh = alert.severity == 'HIGH';
    final isMed = alert.severity == 'MEDIUM';
    final severityColor = isHigh ? Colors.red : (isMed ? Colors.amber.shade900 : Colors.blue);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: severityColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(alert.severity),
                  backgroundColor: severityColor.withAlpha(40),
                  labelStyle: TextStyle(color: severityColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(alert.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('Type: ${alert.type} | Status: ${alert.status}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: severityColor),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onAskTilakSelected();
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Ask Tilak About Traffic'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showDindiCard({
    required BuildContext context,
    required DindiMarkerInfo dindi,
    required VoidCallback onJoinSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dindi.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      Text('Leader: ${dindi.leaderName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${dindi.memberCount} Members'),
                  backgroundColor: Colors.purple.shade50,
                ),
              ],
            ),
            const Divider(height: 20),
            Text('Status: ${dindi.currentStatus}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      Navigator.pop(ctx);
                      onJoinSelected();
                    },
                    icon: const Icon(Icons.group_add, size: 18),
                    label: const Text('Join Dindi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
