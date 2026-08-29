import 'package:flutter/material.dart';

/// Geographical coordinate representation.
class WariLatLng {
  final double latitude;
  final double longitude;

  const WariLatLng(this.latitude, this.longitude);
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
  final String currentStage;
  final String nextStop;
  final WariLatLng currentPosition;
  final List<WariLatLng> routePoints;
  final DateTime lastUpdated;

  const PalkhiInfo({
    required this.palkhiId,
    required this.name,
    required this.currentStage,
    required this.nextStop,
    required this.currentPosition,
    required this.routePoints,
    required this.lastUpdated,
  });
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
  final String availabilityStatus; // e.g. "Available", "Busy", "Full"
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
  final String youtubeVideoId;
  final String category;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  const BhaktiMediaItem({
    required this.id,
    required this.youtubeVideoId,
    required this.category,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
  });

  factory BhaktiMediaItem.fromJson(Map<String, dynamic> json) {
    return BhaktiMediaItem(
      id: json['id'] ?? '',
      youtubeVideoId: json['youtubeVideoId'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      channelTitle: json['channelTitle'] ?? '',
    );
  }
}

/// Tilak AI Chat message.
class TilakChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? suggestedActionText;
  final String? targetRoute;

  const TilakChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedActionText,
    this.targetRoute,
  });
}
