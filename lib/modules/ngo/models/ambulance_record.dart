import 'package:flutter/foundation.dart';

/// Database-ready model for individual ambulance units.
@immutable
class AmbulanceRecord {
  final String id;
  final String vehicleNumber;
  final String ambulanceType; // 'BLS', 'ALS', 'Patient Transport'
  final String contactNumber;
  final String status; // 'Available', 'On Trip', 'Maintenance'
  final String? driverName;
  final String? currentLocation;
  final DateTime? lastUpdated;

  const AmbulanceRecord({
    required this.id,
    required this.vehicleNumber,
    required this.ambulanceType,
    required this.contactNumber,
    this.status = 'Available',
    this.driverName,
    this.currentLocation,
    this.lastUpdated,
  });

  bool get isAvailable => status.toLowerCase() == 'available';

  factory AmbulanceRecord.fromJson(Map<String, dynamic> json) {
    return AmbulanceRecord(
      id: json['ambulance_id']?.toString() ??
          json['id']?.toString() ??
          'amb-${DateTime.now().millisecondsSinceEpoch}',
      vehicleNumber: json['vehicle_number']?.toString() ??
          json['vehicleNumber']?.toString() ??
          'MH-12-AMB-01',
      ambulanceType: json['ambulance_type']?.toString() ??
          json['ambulanceType']?.toString() ??
          'BLS (Basic Life Support)',
      contactNumber: json['contact_number']?.toString() ??
          json['contactNumber']?.toString() ??
          json['phone']?.toString() ??
          '',
      status: json['status']?.toString() ?? 'Available',
      driverName:
          json['driver_name']?.toString() ?? json['driverName']?.toString(),
      currentLocation: json['current_location']?.toString() ??
          json['currentLocation']?.toString(),
      lastUpdated: DateTime.tryParse(json['last_updated']?.toString() ??
          json['lastUpdated']?.toString() ??
          ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ambulance_id': id,
      'vehicle_number': vehicleNumber,
      'ambulance_type': ambulanceType,
      'contact_number': contactNumber,
      'status': status,
      if (driverName != null) 'driver_name': driverName,
      if (currentLocation != null) 'current_location': currentLocation,
      'last_updated': (lastUpdated ?? DateTime.now()).toIso8601String(),
    };
  }

  AmbulanceRecord copyWith({
    String? id,
    String? vehicleNumber,
    String? ambulanceType,
    String? contactNumber,
    String? status,
    String? driverName,
    String? currentLocation,
    DateTime? lastUpdated,
  }) {
    return AmbulanceRecord(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      ambulanceType: ambulanceType ?? this.ambulanceType,
      contactNumber: contactNumber ?? this.contactNumber,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      currentLocation: currentLocation ?? this.currentLocation,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
