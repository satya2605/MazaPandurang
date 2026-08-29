enum ServiceReportStatus { open, inReview, verified, updated }
enum ServiceReportReason {
  incorrectLocation,
  wrongAvailability,
  closedService,
  incorrectInfo,
}

/// A user-submitted report about incorrect or unavailable service information.
class ServiceReport {
  final String id;
  final String serviceId;
  final String serviceName;
  final String reportedBy;
  final ServiceReportReason reason;
  final String? notes;
  final double latitude;
  final double longitude;
  ServiceReportStatus status;
  final DateTime createdAt;

  ServiceReport({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.reportedBy,
    required this.reason,
    this.notes,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
  });

  String get reasonLabel {
    switch (reason) {
      case ServiceReportReason.incorrectLocation:
        return 'Incorrect Location';
      case ServiceReportReason.wrongAvailability:
        return 'Wrong Availability';
      case ServiceReportReason.closedService:
        return 'Service Closed';
      case ServiceReportReason.incorrectInfo:
        return 'Incorrect Information';
    }
  }

  String get statusLabel {
    switch (status) {
      case ServiceReportStatus.open:
        return 'OPEN';
      case ServiceReportStatus.inReview:
        return 'IN REVIEW';
      case ServiceReportStatus.verified:
        return 'VERIFIED';
      case ServiceReportStatus.updated:
        return 'UPDATED';
    }
  }
}
