class DindiAnnouncement {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isUrgent;

  const DindiAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isUrgent = false,
  });
}
