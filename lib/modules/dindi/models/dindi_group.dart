class DindiHalt {
  final String id;
  final String dindiId;
  final int dayNumber;
  final String haltDate;
  final String locationName;
  final double? approxLatitude;
  final double? approxLongitude;
  final String? nextDestination;
  final String? expectedArrival;
  final String? expectedDeparture;
  final String? notes;

  const DindiHalt({
    required this.id,
    required this.dindiId,
    required this.dayNumber,
    required this.haltDate,
    required this.locationName,
    this.approxLatitude,
    this.approxLongitude,
    this.nextDestination,
    this.expectedArrival,
    this.expectedDeparture,
    this.notes,
  });

  factory DindiHalt.fromJson(Map<String, dynamic> json) {
    return DindiHalt(
      id: json['id']?.toString() ?? '',
      dindiId: json['dindiId']?.toString() ?? json['dindi_id']?.toString() ?? '',
      dayNumber: json['dayNumber'] != null
          ? int.parse(json['dayNumber'].toString())
          : (json['day_number'] != null ? int.parse(json['day_number'].toString()) : 1),
      haltDate: json['haltDate']?.toString() ?? json['halt_date']?.toString() ?? '',
      locationName: json['locationName']?.toString() ?? json['location_name']?.toString() ?? '',
      approxLatitude: json['approxLatitude'] != null
          ? double.tryParse(json['approxLatitude'].toString())
          : (json['approx_latitude'] != null ? double.tryParse(json['approx_latitude'].toString()) : null),
      approxLongitude: json['approxLongitude'] != null
          ? double.tryParse(json['approxLongitude'].toString())
          : (json['approx_longitude'] != null ? double.tryParse(json['approx_longitude'].toString()) : null),
      nextDestination: json['nextDestination']?.toString() ?? json['next_destination']?.toString(),
      expectedArrival: json['expectedArrival']?.toString() ?? json['expected_arrival']?.toString(),
      expectedDeparture: json['expectedDeparture']?.toString() ?? json['expected_departure']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dindi_id': dindiId,
      'day_number': dayNumber,
      'halt_date': haltDate,
      'location_name': locationName,
      'approx_latitude': approxLatitude,
      'approx_longitude': approxLongitude,
      'next_destination': nextDestination,
      'expected_arrival': expectedArrival,
      'expected_departure': expectedDeparture,
      'notes': notes,
    };
  }
}

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
  final String documentUrl;
  final String leaderImageUrl;
  final List<DindiHalt> halts;

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
    this.documentUrl = '',
    this.leaderImageUrl = '',
    this.halts = const [],
  });

  factory DindiGroup.fromJson(Map<String, dynamic> json) {
    var rawHalts = json['halts'];
    List<DindiHalt> parsedHalts = [];
    if (rawHalts is List) {
      parsedHalts = rawHalts
          .whereType<Map<String, dynamic>>()
          .map((h) => DindiHalt.fromJson(h))
          .toList();
    }

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
      documentUrl: json['documentUrl']?.toString() ??
          json['document_url']?.toString() ??
          '',
      leaderImageUrl: json['leaderImageUrl']?.toString() ??
          json['leader_image_url']?.toString() ??
          '',
      halts: parsedHalts,
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
      'documentUrl': documentUrl,
      'document_url': documentUrl,
      'leaderImageUrl': leaderImageUrl,
      'leader_image_url': leaderImageUrl,
      'halts': halts.map((h) => h.toJson()).toList(),
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
    String? documentUrl,
    String? leaderImageUrl,
    List<DindiHalt>? halts,
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
      documentUrl: documentUrl ?? this.documentUrl,
      leaderImageUrl: leaderImageUrl ?? this.leaderImageUrl,
      halts: halts ?? this.halts,
    );
  }
}
