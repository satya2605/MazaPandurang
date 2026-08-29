import 'package:flutter/foundation.dart';

/// Approval status for NGO organizations and services.
enum NgoApprovalStatus {
  pending,
  approved,
  rejected,
}

/// NGO Organization entity representing a registered service provider.
@immutable
class NgoOrganization {
  final String id;
  final String name;
  final String registrationNo;
  final String contactPerson;
  final String phone;
  final String email;
  final String primaryCategory;
  final NgoApprovalStatus approvalStatus;
  final DateTime createdAt;
  final String? userId;

  const NgoOrganization({
    required this.id,
    required this.name,
    required this.registrationNo,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.primaryCategory,
    required this.approvalStatus,
    required this.createdAt,
    this.userId,
  });

  NgoOrganization copyWith({
    String? id,
    String? name,
    String? registrationNo,
    String? contactPerson,
    String? phone,
    String? email,
    String? primaryCategory,
    NgoApprovalStatus? approvalStatus,
    DateTime? createdAt,
    String? userId,
  }) {
    return NgoOrganization(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNo: registrationNo ?? this.registrationNo,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  factory NgoOrganization.fromJson(Map<String, dynamic> json) {
    NgoApprovalStatus parseStatus(String? statusStr) {
      final s = statusStr?.toLowerCase();
      if (s == 'approved') return NgoApprovalStatus.approved;
      if (s == 'rejected') return NgoApprovalStatus.rejected;
      return NgoApprovalStatus.pending;
    }

    return NgoOrganization(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      registrationNo: json['registration_number']?.toString() ??
          json['registrationNo']?.toString() ??
          '',
      contactPerson: json['contact_person']?.toString() ??
          json['contactPerson']?.toString() ??
          '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      primaryCategory: json['primary_category']?.toString() ??
          json['primaryCategory']?.toString() ??
          'Medical & Food Seva',
      approvalStatus: parseStatus(json['status']?.toString()),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'registration_number': registrationNo,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'primary_category': primaryCategory,
      'status': approvalStatus.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
