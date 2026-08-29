import 'package:flutter/foundation.dart';

/// Strongly-typed model representing extended attributes stored in `public.service_details`.
@immutable
class NgoServiceDetails {
  final String? serviceId;
  final String? serviceCapacity;
  final String? operatingHours;
  final bool isOpen24Hours;
  final int? mealsPerDay;
  final int? beneficiariesPerDay;
  final int? doctorsAvailable;
  final int? bedsAvailable;
  final String? medicinesAvailable;
  final int? waterCapacityLitresPerDay;
  final int? waterTapsCount;
  final int? availableSpaces;
  final String? currentOccupancy;
  final String? alternateContactPhone;
  final bool whatsappAvailable;
  final bool wheelchairAccessible;
  final bool drinkingWater;
  final bool seatingAvailable;
  final bool accessibleToilet;
  final bool seniorCitizenFriendly;
  final String? importantInstructions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NgoServiceDetails({
    this.serviceId,
    this.serviceCapacity,
    this.operatingHours,
    this.isOpen24Hours = false,
    this.mealsPerDay,
    this.beneficiariesPerDay,
    this.doctorsAvailable,
    this.bedsAvailable,
    this.medicinesAvailable,
    this.waterCapacityLitresPerDay,
    this.waterTapsCount,
    this.availableSpaces,
    this.currentOccupancy,
    this.alternateContactPhone,
    this.whatsappAvailable = false,
    this.wheelchairAccessible = false,
    this.drinkingWater = false,
    this.seatingAvailable = false,
    this.accessibleToilet = false,
    this.seniorCitizenFriendly = false,
    this.importantInstructions,
    this.createdAt,
    this.updatedAt,
  });

  factory NgoServiceDetails.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    return NgoServiceDetails(
      serviceId:
          json['service_id']?.toString() ?? json['serviceId']?.toString(),
      serviceCapacity: json['service_capacity']?.toString() ??
          json['serviceCapacity']?.toString() ??
          json['capacity']?.toString(),
      operatingHours: json['operating_hours']?.toString() ??
          json['operatingHours']?.toString(),
      isOpen24Hours: json['is_open_24_hours'] == true ||
          json['isOpen24Hours'] == true ||
          (json['operating_hours']?.toString().toLowerCase().contains('24') ??
              false),
      mealsPerDay: parseInt(json['meals_per_day'] ?? json['mealsPerDay']),
      beneficiariesPerDay: parseInt(
          json['beneficiaries_per_day'] ?? json['beneficiariesPerDay']),
      doctorsAvailable:
          parseInt(json['doctors_available'] ?? json['doctorsAvailable']),
      bedsAvailable: parseInt(json['beds_available'] ?? json['bedsAvailable']),
      medicinesAvailable: json['medicines_available']?.toString() ??
          json['medicinesAvailable']?.toString(),
      waterCapacityLitresPerDay: parseInt(
          json['water_capacity_litres_per_day'] ??
              json['waterCapacityLitresPerDay']),
      waterTapsCount: parseInt(json['water_taps_count'] ??
          json['waterTapsCount'] ??
          json['water_taps']),
      availableSpaces: parseInt(json['available_spaces'] ??
          json['availableSpaces'] ??
          json['available_beds_spaces']),
      currentOccupancy: json['current_occupancy']?.toString() ??
          json['currentOccupancy']?.toString(),
      alternateContactPhone: json['alternate_contact_phone']?.toString() ??
          json['alternateContactPhone']?.toString(),
      whatsappAvailable: json['whatsapp_available'] == true ||
          json['whatsappAvailable'] == true,
      wheelchairAccessible: json['wheelchair_accessible'] == true ||
          json['wheelchairAccessible'] == true,
      drinkingWater: json['drinking_water'] == true ||
          json['drinkingWater'] == true ||
          json['drinking_water_available'] == true,
      seatingAvailable:
          json['seating_available'] == true || json['seatingAvailable'] == true,
      accessibleToilet:
          json['accessible_toilet'] == true || json['accessibleToilet'] == true,
      seniorCitizenFriendly: json['senior_citizen_friendly'] == true ||
          json['seniorCitizenFriendly'] == true,
      importantInstructions: json['important_instructions']?.toString() ??
          json['importantInstructions']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (serviceId != null) 'service_id': serviceId,
      if (serviceCapacity != null) 'service_capacity': serviceCapacity,
      if (operatingHours != null) 'operating_hours': operatingHours,
      'is_open_24_hours': isOpen24Hours,
      if (mealsPerDay != null) 'meals_per_day': mealsPerDay,
      if (beneficiariesPerDay != null)
        'beneficiaries_per_day': beneficiariesPerDay,
      if (doctorsAvailable != null) 'doctors_available': doctorsAvailable,
      if (bedsAvailable != null) 'beds_available': bedsAvailable,
      if (medicinesAvailable != null) 'medicines_available': medicinesAvailable,
      if (waterCapacityLitresPerDay != null)
        'water_capacity_litres_per_day': waterCapacityLitresPerDay,
      if (waterTapsCount != null) 'water_taps_count': waterTapsCount,
      if (availableSpaces != null) 'available_spaces': availableSpaces,
      if (currentOccupancy != null) 'current_occupancy': currentOccupancy,
      if (alternateContactPhone != null)
        'alternate_contact_phone': alternateContactPhone,
      'whatsapp_available': whatsappAvailable,
      'wheelchair_accessible': wheelchairAccessible,
      'drinking_water': drinkingWater,
      'seating_available': seatingAvailable,
      'accessible_toilet': accessibleToilet,
      'senior_citizen_friendly': seniorCitizenFriendly,
      if (importantInstructions != null)
        'important_instructions': importantInstructions,
    };
  }
}
