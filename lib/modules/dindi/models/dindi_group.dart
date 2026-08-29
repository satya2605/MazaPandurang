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
  });

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
    );
  }
}
