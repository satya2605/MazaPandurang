import 'package:flutter/foundation.dart';

/// Reasons for reporting incorrect service information.
enum ReportReason {
  incorrectLocation,
  serviceClosed,
  wrongAvailability,
  wrongContact,
  duplicate,
  other,
}

/// User report data structure submitted when service details are inaccurate.
@immutable
class ServiceReport {
  final String id;
  final String serviceId;
  final String serviceName;
  final String reporterName;
  final ReportReason reason;
  final String comments;
  final DateTime timestamp;

  const ServiceReport({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.reporterName,
    required this.reason,
    required this.comments,
    required this.timestamp,
  });

  String get reasonLabel {
    switch (reason) {
      case ReportReason.incorrectLocation:
        return 'Incorrect Location on Map';
      case ReportReason.serviceClosed:
        return 'Service Currently Closed / Shut';
      case ReportReason.wrongAvailability:
        return 'Inaccurate Availability Status';
      case ReportReason.wrongContact:
        return 'Wrong Contact Number';
      case ReportReason.duplicate:
        return 'Duplicate Service Listing';
      case ReportReason.other:
        return 'Other Information Issue';
    }
  }
}
