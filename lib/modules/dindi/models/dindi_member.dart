enum DindiMemberStatus {
  pending,
  approved,
  rejected,
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

  factory DindiMember.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] is Map<String, dynamic>
        ? json['profiles'] as Map<String, dynamic>
        : (json['profile'] is Map<String, dynamic>
            ? json['profile'] as Map<String, dynamic>
            : null);

    final rawStatus = (json['status']?.toString() ?? 'pending').toLowerCase();
    final DindiMemberStatus memberStatus;
    if (rawStatus == 'active' || rawStatus == 'approved') {
      memberStatus = DindiMemberStatus.approved;
    } else if (rawStatus == 'rejected') {
      memberStatus = DindiMemberStatus.rejected;
    } else {
      memberStatus = DindiMemberStatus.pending;
    }

    final rawDate = json['joined_at'] ??
        json['requested_at'] ??
        json['joinedAt'] ??
        json['created_at'];
    DateTime parsedDate;
    if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return DindiMember(
      id: json['id']?.toString() ?? '',
      dindiId: json['dindi_id']?.toString() ?? json['dindiId']?.toString() ?? '',
      name: profile?['display_name']?.toString() ??
          profile?['name']?.toString() ??
          json['name']?.toString() ??
          json['display_name']?.toString() ??
          'Warkari Pilgrim',
      phone: profile?['phone']?.toString() ??
          json['phone']?.toString() ??
          '',
      role: json['role']?.toString() ?? 'Warkari (वारकरी)',
      status: memberStatus,
      joinedAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dindi_id': dindiId,
      'name': name,
      'phone': phone,
      'role': role,
      'status': status == DindiMemberStatus.approved
          ? 'active'
          : (status == DindiMemberStatus.rejected ? 'rejected' : 'pending'),
      'joined_at': joinedAt.toIso8601String(),
    };
  }

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
