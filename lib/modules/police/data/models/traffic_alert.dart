enum TrafficAlertType { roadBlock, diversion, slow, cleared }
enum TrafficSeverity { low, medium, high, critical }
enum TrafficAlertStatus { active, resolved }

/// A police-managed traffic alert or road diversion.
class TrafficAlert {
  final String id;
  String title;
  String description;
  TrafficAlertType type;
  final double latitude;
  final double longitude;
  TrafficSeverity severity;
  TrafficAlertStatus status;
  final String createdBy;
  final DateTime createdAt;

  TrafficAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.status,
    required this.createdBy,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case TrafficAlertType.roadBlock:
        return 'BLOCKED';
      case TrafficAlertType.diversion:
        return 'DIVERSION';
      case TrafficAlertType.slow:
        return 'SLOW';
      case TrafficAlertType.cleared:
        return 'CLEAR';
    }
  }

  String get severityLabel {
    switch (severity) {
      case TrafficSeverity.low:
        return 'Low';
      case TrafficSeverity.medium:
        return 'Medium';
      case TrafficSeverity.high:
        return 'High';
      case TrafficSeverity.critical:
        return 'Critical';
    }
  }
}
