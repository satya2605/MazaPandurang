/// Admin Dashboard System Metrics Stats Model.
class AdminDashboardStats {
  final int pendingNgos;
  final int pendingServices;
  final int pendingDindis;
  final int pendingDindiLeaders;
  final int pendingLostPersonReports;
  final int openServiceReports;
  final int activeEmergencies;
  final int activeTrafficAlerts;
  final String timestamp;

  const AdminDashboardStats({
    required this.pendingNgos,
    required this.pendingServices,
    required this.pendingDindis,
    required this.pendingDindiLeaders,
    required this.pendingLostPersonReports,
    required this.openServiceReports,
    required this.activeEmergencies,
    required this.activeTrafficAlerts,
    required this.timestamp,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      pendingNgos: (json['pending_ngos'] as num?)?.toInt() ?? 0,
      pendingServices: (json['pending_services'] as num?)?.toInt() ?? 0,
      pendingDindis: (json['pending_dindis'] as num?)?.toInt() ?? 0,
      pendingDindiLeaders: (json['pending_dindi_leaders'] as num?)?.toInt() ?? 0,
      pendingLostPersonReports: (json['pending_lost_person_reports'] as num?)?.toInt() ?? (json['pending_lost_persons'] as num?)?.toInt() ?? 0,
      openServiceReports: (json['open_service_reports'] as num?)?.toInt() ?? 0,
      activeEmergencies: (json['active_emergencies'] as num?)?.toInt() ?? 0,
      activeTrafficAlerts: (json['active_traffic_alerts'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}

/// Admin NGO Model.
class AdminNgo {
  final String id;
  final String name;
  final String registrationNumber;
  final String contactPerson;
  final String phone;
  final String email;
  final String status;
  final String description;
  final List<dynamic> documents;
  final List<dynamic> gallery;
  final List<dynamic> services;
  final String createdAt;

  const AdminNgo({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.status,
    required this.description,
    required this.documents,
    required this.gallery,
    required this.services,
    required this.createdAt,
  });

  factory AdminNgo.fromJson(Map<String, dynamic> json) {
    return AdminNgo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'NGO',
      registrationNumber: json['registration_number']?.toString() ?? json['registrationNumber']?.toString() ?? 'N/A',
      contactPerson: json['contact_person']?.toString() ?? json['contactPerson']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      description: json['description']?.toString() ?? '',
      documents: json['documents'] as List<dynamic>? ?? [],
      gallery: json['gallery_urls'] as List<dynamic>? ?? json['gallery'] as List<dynamic>? ?? [],
      services: json['services'] as List<dynamic>? ?? [],
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

/// Admin Service Model (2-Gate Publication).
class AdminService {
  final String id;
  final String name;
  final String category;
  final String address;
  final String providerName;
  final bool isVerified; // Gate 1
  final bool isActive;   // Gate 2
  final String availabilityStatus;
  final String contactPhone;

  const AdminService({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.providerName,
    required this.isVerified,
    required this.isActive,
    required this.availabilityStatus,
    required this.contactPhone,
  });

  factory AdminService.fromJson(Map<String, dynamic> json) {
    return AdminService(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Service',
      category: json['category']?.toString() ?? 'Other',
      address: json['address']?.toString() ?? '',
      providerName: json['provider_name']?.toString() ?? json['ngos']?['name']?.toString() ?? 'Provider',
      isVerified: json['is_verified'] == true,
      isActive: json['is_active'] == true,
      availabilityStatus: json['availability_status']?.toString() ?? json['availabilityStatus']?.toString() ?? 'Open 24/7',
      contactPhone: json['contact_phone']?.toString() ?? json['contactPhone']?.toString() ?? '',
    );
  }
}

/// Admin Dindi Model.
class AdminDindi {
  final String id;
  final String dindiNumber;
  final String name;
  final String leaderName;
  final String leaderPhone;
  final int memberCount;
  final String status;
  final String startPoint;
  final String destination;

  const AdminDindi({
    required this.id,
    required this.dindiNumber,
    required this.name,
    required this.leaderName,
    required this.leaderPhone,
    required this.memberCount,
    required this.status,
    required this.startPoint,
    required this.destination,
  });

  factory AdminDindi.fromJson(Map<String, dynamic> json) {
    return AdminDindi(
      id: json['id']?.toString() ?? '',
      dindiNumber: json['dindi_number']?.toString() ?? json['dindiNumber']?.toString() ?? 'DND-000',
      name: json['name']?.toString() ?? 'Dindi',
      leaderName: json['profiles']?['display_name']?.toString() ?? json['leader_name']?.toString() ?? 'Leader',
      leaderPhone: json['profiles']?['phone']?.toString() ?? json['leader_phone']?.toString() ?? '',
      memberCount: (json['member_count'] as num?)?.toInt() ?? (json['memberCount'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString() ?? 'Pending',
      startPoint: json['start_point']?.toString() ?? json['startPoint']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
    );
  }
}

/// Admin Dindi Leader Application Model.
class AdminDindiLeader {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String status;
  final List<dynamic> dindis;
  final String? dindiName;
  final String? startPoint;
  final String? destination;
  final int? memberCount;
  final String? dindiNumber;
  final String? createdAt;

  const AdminDindiLeader({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.status,
    required this.dindis,
    this.dindiName,
    this.startPoint,
    this.destination,
    this.memberCount,
    this.dindiNumber,
    this.createdAt,
  });

  factory AdminDindiLeader.fromJson(Map<String, dynamic> json) {
    final dindisList = json['dindis'] as List<dynamic>? ?? [];
    Map<String, dynamic>? firstDindi;
    if (dindisList.isNotEmpty && dindisList.first is Map<String, dynamic>) {
      firstDindi = dindisList.first as Map<String, dynamic>;
    } else if (dindisList.isNotEmpty && dindisList.first is Map) {
      firstDindi = Map<String, dynamic>.from(dindisList.first as Map);
    }

    return AdminDindiLeader(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['name']?.toString() ?? 'Applicant',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      dindis: dindisList,
      dindiName: firstDindi?['name']?.toString(),
      startPoint: firstDindi?['start_point']?.toString() ?? firstDindi?['startPoint']?.toString(),
      destination: firstDindi?['destination']?.toString(),
      memberCount: (firstDindi?['member_count'] as num?)?.toInt() ?? (firstDindi?['memberCount'] as num?)?.toInt(),
      dindiNumber: firstDindi?['dindi_number']?.toString() ?? firstDindi?['dindiNumber']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['updated_at']?.toString(),
    );
  }
}

/// Admin Lost Person Case Model.
class AdminLostPerson {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String lastSeenLocation;
  final bool isApprovedByAdmin;
  final String status;
  final String contactPhone;

  const AdminLostPerson({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.lastSeenLocation,
    required this.isApprovedByAdmin,
    required this.status,
    required this.contactPhone,
  });

  factory AdminLostPerson.fromJson(Map<String, dynamic> json) {
    return AdminLostPerson(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['person_name']?.toString() ?? json['fullName']?.toString() ?? 'Lost Person',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender']?.toString() ?? '',
      lastSeenLocation: json['last_seen_location']?.toString() ?? json['lastSeenLocation']?.toString() ?? '',
      isApprovedByAdmin: json['is_approved_by_admin'] == true,
      status: json['status']?.toString() ?? 'missing',
      contactPhone: json['contact_phone']?.toString() ?? json['contactPhone']?.toString() ?? '',
    );
  }
}

/// Admin Service Report Model.
class AdminServiceReport {
  final String id;
  final String serviceName;
  final String reporterName;
  final String issueType;
  final String description;
  final String status;
  final String adminNotes;

  const AdminServiceReport({
    required this.id,
    required this.serviceName,
    required this.reporterName,
    required this.issueType,
    required this.description,
    required this.status,
    required this.adminNotes,
  });

  factory AdminServiceReport.fromJson(Map<String, dynamic> json) {
    return AdminServiceReport(
      id: json['id']?.toString() ?? '',
      serviceName: json['services']?['name']?.toString() ?? json['service_name']?.toString() ?? 'Service',
      reporterName: json['profiles']?['display_name']?.toString() ?? json['reporter_name']?.toString() ?? 'Reporter',
      issueType: json['issue_type']?.toString() ?? json['issue']?.toString() ?? 'Issue',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      adminNotes: json['admin_notes']?.toString() ?? '',
    );
  }
}

/// Admin User Profile Governance Model.
class AdminUser {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String status;

  const AdminUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.status,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'local_citizen',
      status: json['status']?.toString() ?? 'active',
    );
  }
}

/// Admin Audit Log Model.
class AdminAuditLog {
  final String id;
  final String action;
  final String targetType;
  final String targetId;
  final String reason;
  final String createdAt;
  final String adminEmail;

  const AdminAuditLog({
    required this.id,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.createdAt,
    required this.adminEmail,
  });

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) {
    return AdminAuditLog(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      targetType: json['target_type']?.toString() ?? json['targetType']?.toString() ?? '',
      targetId: json['target_id']?.toString() ?? json['targetId']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      adminEmail: json['profiles']?['email']?.toString() ?? 'admin@mazapandurang.local',
    );
  }
}
