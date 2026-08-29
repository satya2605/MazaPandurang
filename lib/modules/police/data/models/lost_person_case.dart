enum LostPersonStatus { pendingApproval, approved, resolved }

/// A missing/lost person case during the Wari.
class LostPersonCase {
  final String id;
  final String name;
  final String description;
  final String? photoPath;
  final double lastSeenLatitude;
  final double lastSeenLongitude;
  final String lastSeenDescription;
  final double broadcastRadiusKm;
  LostPersonStatus status;
  final bool adminApproval;
  final DateTime createdAt;
  int sightingCount;

  LostPersonCase({
    required this.id,
    required this.name,
    required this.description,
    this.photoPath,
    required this.lastSeenLatitude,
    required this.lastSeenLongitude,
    required this.lastSeenDescription,
    required this.broadcastRadiusKm,
    required this.status,
    required this.adminApproval,
    required this.createdAt,
    this.sightingCount = 0,
  });

  String get statusLabel {
    switch (status) {
      case LostPersonStatus.pendingApproval:
        return 'PENDING ADMIN APPROVAL';
      case LostPersonStatus.approved:
        return 'APPROVED';
      case LostPersonStatus.resolved:
        return 'RESOLVED';
    }
  }
}
