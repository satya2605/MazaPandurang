class DindiGroup {
  final String id;
  final String name;
  final String dindiNumber;
  final String leaderName;
  final String leaderPhone;
  final String startPoint;
  final String destination;
  final String currentHalt;
  final String roadStatus;
  final String joinCode;
  final String leaderUserId;
  final String status;

  const DindiGroup({
    required this.id,
    required this.name,
    required this.dindiNumber,
    required this.leaderName,
    required this.leaderPhone,
    required this.startPoint,
    required this.destination,
    required this.currentHalt,
    required this.roadStatus,
    required this.joinCode,
    this.leaderUserId = '00000000-0000-0000-0000-000000000002',
    this.status = 'Active',
  });

  factory DindiGroup.fromJson(Map<String, dynamic> json) {
    return DindiGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dindiNumber: json['dindiNumber']?.toString() ??
          json['dindi_number']?.toString() ??
          '',
      leaderName: json['leaderName']?.toString() ??
          json['leader_name']?.toString() ??
          'Dindi Leader',
      leaderPhone: json['leaderPhone']?.toString() ??
          json['leader_phone']?.toString() ??
          '',
      startPoint: json['startPoint']?.toString() ??
          json['start_point']?.toString() ??
          'Alandi',
      destination: json['destination']?.toString() ??
          json['destination']?.toString() ??
          'Pandharpur',
      currentHalt: json['currentHalt']?.toString() ??
          json['current_halt']?.toString() ??
          '',
      roadStatus: json['roadStatus']?.toString() ??
          json['road_status']?.toString() ??
          'Clear & Moving',
      joinCode:
          json['joinCode']?.toString() ?? json['join_code']?.toString() ?? '',
      leaderUserId: json['leaderUserId']?.toString() ??
          json['leader_id']?.toString() ??
          '00000000-0000-0000-0000-000000000002',
      status: json['status']?.toString() ??
          json['currentStatus']?.toString() ??
          'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dindiNumber': dindiNumber,
      'leaderName': leaderName,
      'leaderPhone': leaderPhone,
      'startPoint': startPoint,
      'destination': destination,
      'currentHalt': currentHalt,
      'roadStatus': roadStatus,
      'joinCode': joinCode,
      'status': status,
    };
  }

  DindiGroup copyWith({
    String? id,
    String? name,
    String? dindiNumber,
    String? leaderName,
    String? leaderPhone,
    String? startPoint,
    String? destination,
    String? currentHalt,
    String? roadStatus,
    String? joinCode,
    String? leaderUserId,
    String? status,
  }) {
    return DindiGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      dindiNumber: dindiNumber ?? this.dindiNumber,
      leaderName: leaderName ?? this.leaderName,
      leaderPhone: leaderPhone ?? this.leaderPhone,
      startPoint: startPoint ?? this.startPoint,
      destination: destination ?? this.destination,
      currentHalt: currentHalt ?? this.currentHalt,
      roadStatus: roadStatus ?? this.roadStatus,
      joinCode: joinCode ?? this.joinCode,
      leaderUserId: leaderUserId ?? this.leaderUserId,
      status: status ?? this.status,
    );
  }
}
