enum SightingStatus { reported, verified, dismissed }

/// A reported sighting for a lost person case.
class LostPersonSighting {
  final String id;
  final String caseId;
  final double latitude;
  final double longitude;
  final String locationDescription;
  final DateTime reportedAt;
  final String? reporterMessage;
  SightingStatus status;

  LostPersonSighting({
    required this.id,
    required this.caseId,
    required this.latitude,
    required this.longitude,
    required this.locationDescription,
    required this.reportedAt,
    this.reporterMessage,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case SightingStatus.reported:
        return 'REPORTED';
      case SightingStatus.verified:
        return 'VERIFIED';
      case SightingStatus.dismissed:
        return 'DISMISSED';
    }
  }
}
