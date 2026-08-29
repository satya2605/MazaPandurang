import 'package:flutter/foundation.dart';

/// Database-ready model for individual doctor availability.
@immutable
class DoctorRecord {
  final String id;
  final String name;
  final String specialization;
  final String status; // 'Available Now', 'On Duty', 'On Break'
  final String? contactNumber;
  final bool isEmergencyDoctor;

  const DoctorRecord({
    required this.id,
    required this.name,
    required this.specialization,
    this.status = 'Available Now',
    this.contactNumber,
    this.isEmergencyDoctor = false,
  });

  bool get isAvailable => status.toLowerCase().contains('avail');

  factory DoctorRecord.fromJson(Map<String, dynamic> json) {
    return DoctorRecord(
      id: json['doctor_id']?.toString() ??
          json['id']?.toString() ??
          'doc-${DateTime.now().millisecondsSinceEpoch}',
      name: json['name']?.toString() ?? 'Dr. Specialist',
      specialization: json['specialization']?.toString() ?? 'General Physician',
      status: json['status']?.toString() ?? 'Available Now',
      contactNumber: json['contact_number']?.toString() ??
          json['contactNumber']?.toString(),
      isEmergencyDoctor: json['is_emergency_doctor'] == true ||
          json['isEmergencyDoctor'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': id,
      'name': name,
      'specialization': specialization,
      'status': status,
      if (contactNumber != null) 'contact_number': contactNumber,
      'is_emergency_doctor': isEmergencyDoctor,
    };
  }

  DoctorRecord copyWith({
    String? id,
    String? name,
    String? specialization,
    String? status,
    String? contactNumber,
    bool? isEmergencyDoctor,
  }) {
    return DoctorRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      status: status ?? this.status,
      contactNumber: contactNumber ?? this.contactNumber,
      isEmergencyDoctor: isEmergencyDoctor ?? this.isEmergencyDoctor,
    );
  }
}
