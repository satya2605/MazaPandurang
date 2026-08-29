/// Emergency status state machine: NEW → ACKNOWLEDGED → ASSIGNED → IN_PROGRESS → RESOLVED
enum EmergencyStatus { newCase, acknowledged, assigned, inProgress, resolved }

enum EmergencyType { medical, stampede, fire, drowning, other }

/// An emergency incident reported during the Wari.
class EmergencyRequest {
  final String id;
  final EmergencyType type;
  final double latitude;
  final double longitude;
  final String locationDescription;
  final DateTime reportedAt;
  EmergencyStatus status;
  final String? nearestMedicalCampId;
  String? assignedUnit;
  final String description;

  EmergencyRequest({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    required this.reportedAt,
    required this.status,
    this.nearestMedicalCampId,
    this.assignedUnit,
    required this.description,
  });

  String get typeLabel {
    switch (type) {
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.stampede:
        return 'Stampede Risk';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.drowning:
        return 'Drowning';
      case EmergencyType.other:
        return 'Other Emergency';
    }
  }

  String get statusLabel {
    switch (status) {
      case EmergencyStatus.newCase:
        return 'NEW';
      case EmergencyStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case EmergencyStatus.assigned:
        return 'ASSIGNED';
      case EmergencyStatus.inProgress:
        return 'IN PROGRESS';
      case EmergencyStatus.resolved:
        return 'RESOLVED';
    }
  }
}
