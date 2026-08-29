import 'package:flutter/foundation.dart';
import 'ngo_service.dart';

/// Independent multi-criteria filters for NGO Seva services.
@immutable
class MedicalServiceFilter {
  final String? serviceType;
  final ServiceAvailability? liveStatus;
  final bool hasAvailableBeds;
  final bool hasAvailableDoctors;
  final bool hasAvailableAmbulances;
  final bool hasAvailableFood;
  final bool hasAvailableShelter;
  final bool hasAvailableWater;
  final bool isEmergencySupport;
  final bool isOpenNow;
  final double? maxDistanceKm;

  const MedicalServiceFilter({
    this.serviceType,
    this.liveStatus,
    this.hasAvailableBeds = false,
    this.hasAvailableDoctors = false,
    this.hasAvailableAmbulances = false,
    this.hasAvailableFood = false,
    this.hasAvailableShelter = false,
    this.hasAvailableWater = false,
    this.isEmergencySupport = false,
    this.isOpenNow = false,
    this.maxDistanceKm,
  });

  bool matches(NgoService service) {
    if (serviceType != null &&
        serviceType!.isNotEmpty &&
        serviceType != 'All') {
      final query = serviceType!.toLowerCase();
      final catLabel = service.categoryLabel.toLowerCase();
      final catName = service.category.name.toLowerCase();
      if (!catLabel.contains(query) && !catName.contains(query)) {
        return false;
      }
    }

    if (liveStatus != null && service.availability != liveStatus) {
      return false;
    }

    if (hasAvailableBeds && (service.availableBedsCount ?? 0) <= 0) {
      return false;
    }

    if (hasAvailableDoctors && (service.availableDoctorsCount ?? 0) <= 0) {
      return false;
    }

    if (hasAvailableAmbulances &&
        (service.availableAmbulancesCount ?? 0) <= 0) {
      return false;
    }

    if (hasAvailableFood) {
      if (service.category != NgoServiceCategory.food) return false;
      final meals = service.details?.mealsPerDay ?? 0;
      if (service.availability == ServiceAvailability.unavailable &&
          meals <= 0) {
        return false;
      }
    }

    if (hasAvailableShelter) {
      if (service.category != NgoServiceCategory.shelter) return false;
      final spaces = service.details?.availableSpaces ?? 0;
      if (service.availability == ServiceAvailability.unavailable &&
          spaces <= 0) {
        return false;
      }
    }

    if (hasAvailableWater) {
      if (service.category != NgoServiceCategory.water) return false;
      final taps = service.details?.waterTapsCount ?? 0;
      final cap = service.details?.waterCapacityLitresPerDay ?? 0;
      if (service.availability == ServiceAvailability.unavailable &&
          taps <= 0 &&
          cap <= 0) {
        return false;
      }
    }

    if (isEmergencySupport &&
        !service.emergencySupportAvailable &&
        !service.ambulanceAvailable &&
        service.category != NgoServiceCategory.emergency) {
      return false;
    }

    if (isOpenNow && service.availability == ServiceAvailability.unavailable) {
      return false;
    }

    return true;
  }

  MedicalServiceFilter copyWith({
    String? serviceType,
    ServiceAvailability? liveStatus,
    bool? hasAvailableBeds,
    bool? hasAvailableDoctors,
    bool? hasAvailableAmbulances,
    bool? hasAvailableFood,
    bool? hasAvailableShelter,
    bool? hasAvailableWater,
    bool? isEmergencySupport,
    bool? isOpenNow,
    double? maxDistanceKm,
  }) {
    return MedicalServiceFilter(
      serviceType: serviceType ?? this.serviceType,
      liveStatus: liveStatus ?? this.liveStatus,
      hasAvailableBeds: hasAvailableBeds ?? this.hasAvailableBeds,
      hasAvailableDoctors: hasAvailableDoctors ?? this.hasAvailableDoctors,
      hasAvailableAmbulances:
          hasAvailableAmbulances ?? this.hasAvailableAmbulances,
      hasAvailableFood: hasAvailableFood ?? this.hasAvailableFood,
      hasAvailableShelter: hasAvailableShelter ?? this.hasAvailableShelter,
      hasAvailableWater: hasAvailableWater ?? this.hasAvailableWater,
      isEmergencySupport: isEmergencySupport ?? this.isEmergencySupport,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
    );
  }
}

/// Alias for universal service filtering across all NGO categories.
typedef NgoServiceFilter = MedicalServiceFilter;
