enum DindiMemberStatus {
  pending,
  approved,
}

class DindiMember {
  final String id;
  final String dindiId;
  final String name;
  final String phone;
  final String role;
  final DindiMemberStatus status;
  final DateTime joinedAt;

  const DindiMember({
    required this.id,
    required this.dindiId,
    required this.name,
    required this.phone,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  DindiMember copyWith({
    String? id,
    String? dindiId,
    String? name,
    String? phone,
    String? role,
    DindiMemberStatus? status,
    DateTime? joinedAt,
  }) {
    return DindiMember(
      id: id ?? this.id,
      dindiId: dindiId ?? this.dindiId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
