/// Represents a Police / Authority user account.
/// Accounts are pre-seeded by admin — no self-registration.
class PoliceUser {
  final String id;
  final String policeId;
  final String name;
  final String station;
  final String role;
  final String status;

  const PoliceUser({
    required this.id,
    required this.policeId,
    required this.name,
    required this.station,
    required this.role,
    required this.status,
  });
}
