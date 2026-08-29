import 'package:flutter/foundation.dart';

/// Categories of services offered by NGOs during Wari.
enum NgoServiceCategory {
  medical,
  food,
  water,
  shelter,
  volunteer,
  lostAndFound,
  other,
}

/// Dynamic availability status for a service.
enum ServiceAvailability {
  available,
  limited,
  unavailable,
}

/// NGO Seva Service entity with geographical and availability metadata.
@immutable
class NgoService {
  final String id;
  final String ngoId;
  final String name;
  final NgoServiceCategory category;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final String capacity;
  final String operatingHours;
  final String contactPhone;
  final ServiceAvailability availability;
  final DateTime lastUpdatedAt;
  final bool isApproved;

  const NgoService({
    required this.id,
    required this.ngoId,
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.capacity,
    required this.operatingHours,
    required this.contactPhone,
    required this.availability,
    required this.lastUpdatedAt,
    this.isApproved = true,
  });

  NgoService copyWith({
    String? id,
    String? ngoId,
    String? name,
    NgoServiceCategory? category,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    String? capacity,
    String? operatingHours,
    String? contactPhone,
    ServiceAvailability? availability,
    DateTime? lastUpdatedAt,
    bool? isApproved,
  }) {
    return NgoService(
      id: id ?? this.id,
      ngoId: ngoId ?? this.ngoId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      capacity: capacity ?? this.capacity,
      operatingHours: operatingHours ?? this.operatingHours,
      contactPhone: contactPhone ?? this.contactPhone,
      availability: availability ?? this.availability,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  /// Helper to convert category to human readable display string.
  String get categoryLabel {
    switch (category) {
      case NgoServiceCategory.medical:
        return 'Medical Assistance';
      case NgoServiceCategory.food:
        return 'Food & Annachhatra';
      case NgoServiceCategory.water:
        return 'Drinking Water & Sanitation';
      case NgoServiceCategory.shelter:
        return 'Night Halt & Shelter';
      case NgoServiceCategory.volunteer:
        return 'Volunteer Assistance';
      case NgoServiceCategory.lostAndFound:
        return 'Lost & Found Support';
      case NgoServiceCategory.other:
        return 'Other Seva Service';
    }
  }

  /// Helper to convert availability to human readable display string.
  String get availabilityLabel {
    switch (availability) {
      case ServiceAvailability.available:
        return 'AVAILABLE';
      case ServiceAvailability.limited:
        return 'LIMITED';
      case ServiceAvailability.unavailable:
        return 'UNAVAILABLE';
    }
  }
}
