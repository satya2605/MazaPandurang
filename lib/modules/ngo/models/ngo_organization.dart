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
    );
  }
}
