import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../admin/models/admin_models.dart' show PalkhiHalt;

/// Geographical coordinate representation.
class WariLatLng {
  final double latitude;
  final double longitude;

  const WariLatLng(this.latitude, this.longitude);

  /// Haversine distance calculation in kilometers.
  double distanceToInKm(WariLatLng other) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(other.latitude - latitude);
    final dLon = _degreesToRadians(other.longitude - longitude);

    final lat1Rad = _degreesToRadians(latitude);
    final lat2Rad = _degreesToRadians(other.latitude);

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1Rad) * math.cos(lat2Rad));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) => degrees * (3.1415926535897932 / 180.0);
}

/// User/Pilgrim location data.
class PilgrimLocation {
  final String pilgrimId;
  final String name;
  final WariLatLng position;
  final DateTime lastUpdated;

  const PilgrimLocation({
    required this.pilgrimId,
    required this.name,
    required this.position,
    required this.lastUpdated,
  });
}

/// Palkhi tracking information.
class PalkhiInfo {
  final String palkhiId;
  final String name;
  final String saint;
  final String startPoint;
  final String destination;
  final String currentStage;
  final String nextStop;
  final WariLatLng currentPosition;
  final List<WariLatLng> routePoints;
  final DateTime lastUpdated;
  final List<PalkhiHalt> halts;

  const PalkhiInfo({
    required this.palkhiId,
    required this.name,
    this.saint = 'Sant Dnyaneshwar Maharaj',
    this.startPoint = 'Alandi',
    this.destination = 'Pandharpur',
    required this.currentStage,
    required this.nextStop,
    required this.currentPosition,
    required this.routePoints,
    required this.lastUpdated,
    this.halts = const [],
  });

  factory PalkhiInfo.fromJson(Map<String, dynamic> json) {
    double lat = 18.6772;
    double lng = 73.8967;
    if (json['latitude'] != null) lat = (json['latitude'] as num).toDouble();
    if (json['longitude'] != null) lng = (json['longitude'] as num).toDouble();
    if (json['current_location'] != null && json['current_location'] is Map) {
      final loc = json['current_location'] as Map;
      if (loc['latitude'] != null) lat = (loc['latitude'] as num).toDouble();
      if (loc['longitude'] != null) lng = (loc['longitude'] as num).toDouble();
    }

    var rawHalts = json['halts'];
    List<PalkhiHalt> parsedHalts = [];
    if (rawHalts is List) {
      parsedHalts = rawHalts
          .whereType<Map<String, dynamic>>()
          .map((h) => PalkhiHalt.fromJson(h))
          .toList();
      parsedHalts.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    }

    return PalkhiInfo(
      palkhiId: json['id']?.toString() ?? json['palkhiId']?.toString() ?? 'PALKHI-001',
      name: json['name']?.toString() ?? 'Sant Dnyaneshwar Maharaj Palkhi',
      saint: json['saint']?.toString() ?? 'Sant Dnyaneshwar Maharaj',
      startPoint: json['start_point']?.toString() ?? json['startPoint']?.toString() ?? 'Alandi',
      destination: json['destination']?.toString() ?? json['destination']?.toString() ?? 'Pandharpur',
      currentStage: json['currentStage']?.toString() ?? json['current_stage']?.toString() ?? json['current_location']?['current_stage']?.toString() ?? 'Alandi',
      nextStop: json['nextStop']?.toString() ?? json['next_stop']?.toString() ?? json['current_location']?['next_stop']?.toString() ?? 'Pune Stay',
      currentPosition: WariLatLng(lat, lng),
      routePoints: const [],
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? json['last_updated']?.toString() ?? '') ?? DateTime.now(),
      halts: parsedHalts,
    );
  }
}

/// Dindi marker representation for Pilgrim map display.
class DindiMarkerInfo {
  final String dindiId;
  final String name;
  final String leaderName;
  final int memberCount;
  final WariLatLng position;
  final String currentStatus;

  const DindiMarkerInfo({
    required this.dindiId,
    required this.name,
    required this.leaderName,
    required this.memberCount,
    required this.position,
    required this.currentStatus,
  });
}

/// Detailed Dindi Information.
class DindiDetail {
  final String id;
  final String dindiNumber;
  final String name;
  final String leaderId;
  final String leaderName;
  final String leaderPhone;
  final int memberCount;
  final String currentLocationName;
  final WariLatLng position;
  final String status;
  final String startPoint;
  final String destination;
  final String currentHalt;
  final String roadStatus;
  final String joinCode;

  const DindiDetail({
    required this.id,
    required this.dindiNumber,
    required this.name,
    required this.leaderId,
    required this.leaderName,
    required this.leaderPhone,
    required this.memberCount,
    required this.currentLocationName,
    required this.position,
    required this.status,
    required this.startPoint,
    required this.destination,
    required this.currentHalt,
    required this.roadStatus,
    required this.joinCode,
  });
}

/// Category of Wari public services.
enum ServiceCategory {
  medical,
  water,
  food,
  toilet,
  shelter,
  police,
  ngo,
}

extension ServiceCategoryExtension on ServiceCategory {
  String get label {
    switch (this) {
      case ServiceCategory.medical:
        return 'Medical Camp';
      case ServiceCategory.water:
        return 'Drinking Water';
      case ServiceCategory.food:
        return 'Annachhatra / Food';
      case ServiceCategory.toilet:
        return 'Sanitation / Toilet';
      case ServiceCategory.shelter:
        return 'Rest / Shelter';
      case ServiceCategory.police:
        return 'Police Booth';
      case ServiceCategory.ngo:
        return 'NGO Seva';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceCategory.medical:
        return Icons.medical_services;
      case ServiceCategory.water:
        return Icons.water_drop;
      case ServiceCategory.food:
        return Icons.restaurant;
      case ServiceCategory.toilet:
        return Icons.wc;
      case ServiceCategory.shelter:
        return Icons.night_shelter;
      case ServiceCategory.police:
        return Icons.local_police;
      case ServiceCategory.ngo:
        return Icons.volunteer_activism;
    }
  }

  Color get color {
    switch (this) {
      case ServiceCategory.medical:
        return const Color(0xFFD32F2F);
      case ServiceCategory.water:
        return const Color(0xFF0288D1);
      case ServiceCategory.food:
        return const Color(0xFFED6C02);
      case ServiceCategory.toilet:
        return const Color(0xFF7B1FA2);
      case ServiceCategory.shelter:
        return const Color(0xFF388E3C);
      case ServiceCategory.police:
        return const Color(0xFF1976D2);
      case ServiceCategory.ngo:
        return const Color(0xFFE65100);
    }
  }
}

/// Service marker and facility information.
class WariService {
  final String serviceId;
  final String name;
  final ServiceCategory category;
  final WariLatLng position;
  final String address;
  final String availabilityStatus;
  final String description;
  final String contactPhone;
  final bool isVerified;

  const WariService({
    required this.serviceId,
    required this.name,
    required this.category,
    required this.position,
    required this.address,
    required this.availabilityStatus,
    required this.description,
    required this.contactPhone,
    this.isVerified = true,
  });
}

/// Bhakti devotional media item metadata.
class BhaktiMediaItem {
  final String id;
  final String title;
  final String marathiTitle;
  final String artist;
  final String category;
  final String duration;
  final String thumbnailUrl;
  final String streamUrl;

  const BhaktiMediaItem({
    required this.id,
    required this.title,
    required this.marathiTitle,
    required this.artist,
    required this.category,
    required this.duration,
    required this.thumbnailUrl,
    required this.streamUrl,
  });
}

/// Structured Action returned by Tilak AI.
class TilakAction {
  final String type;
  final String? id;
  final String label;
  final String? targetRoute;
  final double? latitude;
  final double? longitude;
  final String? title;

  const TilakAction({
    required this.type,
    this.id,
    required this.label,
    this.targetRoute,
    this.latitude,
    this.longitude,
    this.title,
  });

  factory TilakAction.fromJson(Map<String, dynamic> json) {
    return TilakAction(
      type: json['type']?.toString() ?? 'action',
      id: json['id']?.toString(),
      label: json['label']?.toString() ?? json['action_label']?.toString() ?? 'View Details',
      targetRoute: json['targetRoute']?.toString() ?? json['target_route']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      title: json['title']?.toString(),
    );
  }
}

/// Tilak AI Chat message.
class TilakChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;
  final List<TilakAction> actions;
  final List<String> sources;
  final String? suggestedActionText;
  final String? targetRoute;

  const TilakChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.actions = const [],
    this.sources = const [],
    this.suggestedActionText,
    this.targetRoute,
  });

  factory TilakChatMessage.fromJson(Map<String, dynamic> json) {
    final actionsList = (json['actions'] as List<dynamic>?)
            ?.map((a) => TilakAction.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    final firstAction = actionsList.isNotEmpty ? actionsList.first : null;

    final rawText = json['message']?.toString() ??
        json['reply']?.toString() ??
        json['text']?.toString();

    final parsedText = (rawText != null && rawText.trim().isNotEmpty)
        ? rawText.trim()
        : 'क्षमस्व, सध्या उत्तर मिळू शकले नाही. कृपया पुन्हा प्रयत्न करा.';

    return TilakChatMessage(
      id: json['id']?.toString() ?? 'MSG-AI-${DateTime.now().millisecondsSinceEpoch}',
      text: parsedText,
      isUser: false,
      timestamp: DateTime.now(),
      intent: json['intent']?.toString(),
      actions: actionsList,
      sources: (json['sources'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
      suggestedActionText: firstAction?.label,
      targetRoute: firstAction?.targetRoute,
    );
  }
}

/// Wari route stage information returned by GET /api/wari-route.
class WariRouteStage {
  final String id;
  final String stageName;
  final int sequenceOrder;
  final WariLatLng position;

  const WariRouteStage({
    required this.id,
    required this.stageName,
    required this.sequenceOrder,
    required this.position,
  });

  factory WariRouteStage.fromJson(Map<String, dynamic> json) {
    return WariRouteStage(
      id: json['id']?.toString() ?? '',
      stageName:
          json['stageName']?.toString() ?? json['stage_name']?.toString() ?? '',
      sequenceOrder:
          json['sequenceOrder'] as int? ?? json['sequence_order'] as int? ?? 0,
      position: WariLatLng(
        (json['latitude'] as num?)?.toDouble() ?? 18.3411,
        (json['longitude'] as num?)?.toDouble() ?? 74.0305,
      ),
    );
  }
}

/// City place information returned by GET /api/city-places.
class CityPlace {
  final String id;
  final String name;
  final String placeType;
  final WariLatLng position;
  final String description;

  const CityPlace({
    required this.id,
    required this.name,
    required this.placeType,
    required this.position,
    required this.description,
  });

  factory CityPlace.fromJson(Map<String, dynamic> json) {
    return CityPlace(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      placeType: json['place_type']?.toString() ?? json['placeType']?.toString() ?? '',
      position: WariLatLng(
        (json['latitude'] as num?)?.toDouble() ?? 18.3411,
        (json['longitude'] as num?)?.toDouble() ?? 74.0305,
      ),
      description: json['description']?.toString() ?? '',
    );
  }
}

/// City Route information returned by GET /api/routes.
class CityRoute {
  final String id;
  final String name;
  final String routeType;
  final String status;
  final String description;

  const CityRoute({
    required this.id,
    required this.name,
    required this.routeType,
    required this.status,
    required this.description,
  });

  factory CityRoute.fromJson(Map<String, dynamic> json) {
    return CityRoute(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      routeType: json['route_type']?.toString() ?? json['routeType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      description: json['description']?.toString() ?? '',
    );
  }
}

/// Donations Info returned by GET /api/donations-info.
class DonationsInfo {
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String upiId;
  final String trustName;
  final String notes;

  const DonationsInfo({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.upiId,
    required this.trustName,
    required this.notes,
  });

  factory DonationsInfo.fromJson(Map<String, dynamic> json) {
    return DonationsInfo(
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString() ?? 'State Bank of India',
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString() ?? '000000000000',
      ifscCode: json['ifsc_code']?.toString() ?? json['ifscCode']?.toString() ?? 'SBIN0001234',
      upiId: json['upi_id']?.toString() ?? json['upiId']?.toString() ?? 'wari@upi',
      trustName: json['trust_name']?.toString() ?? json['trustName']?.toString() ?? 'Shree Vitthal Rukmini Mandir Samiti',
      notes: json['notes']?.toString() ?? '',
    );
  }
}

/// Lost Person Report returned by GET /api/lost-persons.
class LostPersonReport {
  final String id;
  final String fullName;
  final int age;
  final String gender;
  final String photoUrl;
  final String lastSeenLocation;
  final WariLatLng position;
  final String contactPhone;
  final String status;

  const LostPersonReport({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.photoUrl,
    required this.lastSeenLocation,
    required this.position,
    required this.contactPhone,
    required this.status,
  });

  factory LostPersonReport.fromJson(Map<String, dynamic> json) {
    return LostPersonReport(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? json['photoUrl']?.toString() ?? '',
      lastSeenLocation: json['last_seen_location']?.toString() ?? json['lastSeenLocation']?.toString() ?? '',
      position: WariLatLng(
        (json['latitude'] as num?)?.toDouble() ?? 18.3411,
        (json['longitude'] as num?)?.toDouble() ?? 74.0305,
      ),
      contactPhone: json['contact_phone']?.toString() ?? json['contactPhone']?.toString() ?? '',
      status: json['status']?.toString() ?? 'missing',
    );
  }
}

/// Sighting of a Lost Person returned by GET /api/lost-persons/:id/sightings.
class LostPersonSighting {
  final String id;
  final String lostPersonId;
  final String locationName;
  final WariLatLng position;
  final String details;
  final DateTime createdAt;

  const LostPersonSighting({
    required this.id,
    required this.lostPersonId,
    required this.locationName,
    required this.position,
    required this.details,
    required this.createdAt,
  });

  factory LostPersonSighting.fromJson(Map<String, dynamic> json) {
    return LostPersonSighting(
      id: json['id']?.toString() ?? '',
      lostPersonId: json['lost_person_id']?.toString() ?? json['lostPersonId']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? json['locationName']?.toString() ?? '',
      position: WariLatLng(
        (json['latitude'] as num?)?.toDouble() ?? 18.3411,
        (json['longitude'] as num?)?.toDouble() ?? 74.0305,
      ),
      details: json['details']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Active Traffic Alert returned by GET /api/traffic-alerts.
class TrafficAlert {
  final String id;
  final String alertCode;
  final String title;
  final String description;
  final String type;
  final String severity; // HIGH, MEDIUM, LOW
  final String status;   // ACTIVE, RESOLVED
  final WariLatLng position;
  final String createdBy;
  final DateTime createdAt;

  const TrafficAlert({
    required this.id,
    required this.alertCode,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.status,
    required this.position,
    required this.createdBy,
    required this.createdAt,
  });

  factory TrafficAlert.fromJson(Map<String, dynamic> json) {
    return TrafficAlert(
      id: json['id']?.toString() ?? '',
      alertCode: json['alert_code']?.toString() ?? json['alertCode']?.toString() ?? 'TRF-000',
      title: json['title']?.toString() ?? 'Traffic Alert',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'SLOW_TRAFFIC',
      severity: (json['severity']?.toString() ?? 'MEDIUM').toUpperCase(),
      status: (json['status']?.toString() ?? 'ACTIVE').toUpperCase(),
      position: WariLatLng(
        (json['latitude'] as num?)?.toDouble() ?? 18.3411,
        (json['longitude'] as num?)?.toDouble() ?? 74.0305,
      ),
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Emergency Request object returned by POST/GET /api/emergencies.
class EmergencyRequest {
  final String id;
  final String requestCode;
  final String requesterId;
  final String emergencyType; // Medical, Police, Lost Person, Other
  final WariLatLng position;
  final String locationName;
  final String description;
  final String status; // pending, dispatched, resolved, cancelled
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const EmergencyRequest({
    required this.id,
    required this.requestCode,
    required this.requesterId,
    required this.emergencyType,
    required this.position,
    required this.locationName,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) {
    return EmergencyRequest(
      id: json['id']?.toString() ?? '',
      requestCode: json['request_code']?.toString() ?? json['requestCode']?.toString() ?? 'EMG-000',
      requesterId: json['requester_id']?.toString() ?? json['requesterId']?.toString() ?? '',
      emergencyType: json['emergency_type']?.toString() ?? json['emergencyType']?.toString() ?? 'Medical',
      position: WariLatLng(
        (json['latitude'] as num?)?.toDouble() ?? 18.3411,
        (json['longitude'] as num?)?.toDouble() ?? 74.0305,
      ),
      locationName: json['location_name']?.toString() ?? json['locationName']?.toString() ?? 'Wari Location',
      description: json['description']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'].toString()) : null,
    );
  }
}

/// Normalized classification of map markers.
enum MapLocationType {
  palkhiLive,
  palkhiHalt,
  dindi,
  serviceMedical,
  serviceFood,
  serviceWater,
  servicePolice,
  serviceToilet,
  serviceShelter,
  serviceOther,
  emergency,
}

extension MapLocationTypeExtension on MapLocationType {
  String get label {
    switch (this) {
      case MapLocationType.palkhiLive:
        return 'पालखी (Live)';
      case MapLocationType.palkhiHalt:
        return 'पालखी मुक्काम';
      case MapLocationType.dindi:
        return 'दिंडी';
      case MapLocationType.serviceMedical:
        return 'वैद्यकीय सेवा';
      case MapLocationType.serviceFood:
        return 'अन्नदान';
      case MapLocationType.serviceWater:
        return 'पिण्याचे पाणी';
      case MapLocationType.servicePolice:
        return 'पोलीस मदत';
      case MapLocationType.serviceToilet:
        return 'स्वच्छता गृह';
      case MapLocationType.serviceShelter:
        return 'विश्राम धाम';
      case MapLocationType.serviceOther:
        return 'इतर सेवा';
      case MapLocationType.emergency:
        return 'आणीबाणी मदत';
    }
  }

  IconData get icon {
    switch (this) {
      case MapLocationType.palkhiLive:
        return Icons.flag_rounded;
      case MapLocationType.palkhiHalt:
        return Icons.signpost_rounded;
      case MapLocationType.dindi:
        return Icons.groups_rounded;
      case MapLocationType.serviceMedical:
        return Icons.local_hospital_rounded;
      case MapLocationType.serviceFood:
        return Icons.restaurant_rounded;
      case MapLocationType.serviceWater:
        return Icons.water_drop_rounded;
      case MapLocationType.servicePolice:
        return Icons.local_police_rounded;
      case MapLocationType.serviceToilet:
        return Icons.wc_rounded;
      case MapLocationType.serviceShelter:
        return Icons.night_shelter_rounded;
      case MapLocationType.serviceOther:
        return Icons.place_rounded;
      case MapLocationType.emergency:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MapLocationType.palkhiLive:
        return const Color(0xFFE65100);
      case MapLocationType.palkhiHalt:
        return const Color(0xFFC2185B);
      case MapLocationType.dindi:
        return const Color(0xFF7B1FA2);
      case MapLocationType.serviceMedical:
        return const Color(0xFFD32F2F);
      case MapLocationType.serviceFood:
        return const Color(0xFFF57C00);
      case MapLocationType.serviceWater:
        return const Color(0xFF0288D1);
      case MapLocationType.servicePolice:
        return const Color(0xFF303F9F);
      case MapLocationType.serviceToilet:
        return const Color(0xFF00796B);
      case MapLocationType.serviceShelter:
        return const Color(0xFF5D4037);
      case MapLocationType.serviceOther:
        return const Color(0xFF455A64);
      case MapLocationType.emergency:
        return const Color(0xFFB71C1C);
    }
  }
}

/// Normalized Location Model for Map Rendering.
class MapLocationEntity {
  final String id;
  final MapLocationType type;
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;
  final String status;
  final Map<String, dynamic> metadata;

  const MapLocationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.metadata = const {},
  });

  WariLatLng get position => WariLatLng(latitude, longitude);
}
