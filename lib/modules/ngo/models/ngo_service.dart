import 'package:flutter/foundation.dart';
import 'ambulance_record.dart';
import 'doctor_record.dart';
import 'ngo_service_details.dart';

/// Categories of services offered by NGOs during Wari.
enum NgoServiceCategory {
  medical,
  food,
  water,
  shelter,
  volunteer,
  lostAndFound,
  clothing,
  sanitation,
  emergency,
  other,
}

/// Dynamic availability status for a service.
enum ServiceAvailability {
  available,
  limited,
  unavailable,
}

/// Sentinel used in [NgoService.copyWith] to distinguish "not passed" from null.
const Object _sentinel = Object();

/// NGO Seva Service entity with geographical, capacity, medical emergency, and availability metadata.
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

  /// Primary image URL (Supabase Storage public URL, data-URL, or null).
  final String? imageUrl;

  /// Additional image URLs for a multi-image gallery.
  final List<String> additionalImageUrls;

  /// Contact & Accessibility Extensions
  final String? alternateContactPhone;
  final bool whatsappAvailable;
  final bool wheelchairAccessible;
  final bool drinkingWaterAvailable;
  final bool seatingAvailable;
  final bool accessibleToilet;
  final bool seniorCitizenFriendly;
  final String? importantInstructions;

  /// Medical & Emergency Support Fields
  final bool emergencySupportAvailable;
  final bool ambulanceAvailable;
  final String? emergencyContactPhone;
  final String? ambulanceContactPhone;
  final String? emergencyInstructions;
  final List<Map<String, dynamic>> emergencyContacts;

  /// Granular Ambulance Availability (Independent Tracking)
  final int? totalAmbulances;
  final int? availableAmbulances;
  final int? onTripAmbulances;
  final List<AmbulanceRecord> ambulancesList;

  /// Granular Bed Availability (Independent Tracking)
  final int? totalBeds;
  final int? availableBeds;
  final int? occupiedBeds;
  final int? generalBedsAvailable;
  final int? icuBedsAvailable;

  /// Granular Doctor Availability (Independent Tracking)
  final int? totalDoctors;
  final int? availableDoctors;
  final int? onDutyDoctors;
  final int? emergencyDoctorsCount;
  final List<DoctorRecord> doctorsList;

  /// Strongly-typed service details corresponding to `public.service_details`
  final NgoServiceDetails? details;

  /// Category-specific structured details (JSON map for flexible extensions)
  final Map<String, dynamic> categoryDetails;

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
    this.imageUrl,
    this.additionalImageUrls = const [],
    this.alternateContactPhone,
    this.whatsappAvailable = false,
    this.wheelchairAccessible = false,
    this.drinkingWaterAvailable = false,
    this.seatingAvailable = false,
    this.accessibleToilet = false,
    this.seniorCitizenFriendly = false,
    this.importantInstructions,
    this.emergencySupportAvailable = false,
    this.ambulanceAvailable = false,
    this.emergencyContactPhone,
    this.ambulanceContactPhone,
    this.emergencyInstructions,
    this.emergencyContacts = const [],
    this.totalAmbulances,
    this.availableAmbulances,
    this.onTripAmbulances,
    this.ambulancesList = const [],
    this.totalBeds,
    this.availableBeds,
    this.occupiedBeds,
    this.generalBedsAvailable,
    this.icuBedsAvailable,
    this.totalDoctors,
    this.availableDoctors,
    this.onDutyDoctors,
    this.emergencyDoctorsCount,
    this.doctorsList = const [],
    this.details,
    this.categoryDetails = const {},
  });

  /// Helper getters for availability counts
  int? get availableBedsCount =>
      availableBeds ??
      (totalBeds != null && occupiedBeds != null
          ? (totalBeds! - occupiedBeds!)
          : null) ??
      details?.bedsAvailable ??
      (categoryDetails['available_beds'] is num
          ? (categoryDetails['available_beds'] as num).toInt()
          : int.tryParse(categoryDetails['available_beds']?.toString() ?? ''));

  int? get availableDoctorsCount =>
      availableDoctors ??
      details?.doctorsAvailable ??
      (categoryDetails['available_doctors'] is num
          ? (categoryDetails['available_doctors'] as num).toInt()
          : int.tryParse(
              categoryDetails['available_doctors']?.toString() ?? ''));

  int? get availableAmbulancesCount =>
      availableAmbulances ??
      (categoryDetails['available_ambulances'] is num
          ? (categoryDetails['available_ambulances'] as num).toInt()
          : (ambulancesList.where((a) => a.isAvailable).isNotEmpty
              ? ambulancesList.where((a) => a.isAvailable).length
              : (ambulanceAvailable ? 1 : 0)));

  /// Returns all image URLs: primary first, then additional.
  List<String> get allImageUrls => [
        if (imageUrl != null) imageUrl!,
        ...additionalImageUrls,
      ];

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
    Object? imageUrl = _sentinel,
    List<String>? additionalImageUrls,
    String? alternateContactPhone,
    bool? whatsappAvailable,
    bool? wheelchairAccessible,
    bool? drinkingWaterAvailable,
    bool? seatingAvailable,
    bool? accessibleToilet,
    bool? seniorCitizenFriendly,
    String? importantInstructions,
    bool? emergencySupportAvailable,
    bool? ambulanceAvailable,
    String? emergencyContactPhone,
    String? ambulanceContactPhone,
    String? emergencyInstructions,
    List<Map<String, dynamic>>? emergencyContacts,
    int? totalAmbulances,
    int? availableAmbulances,
    int? onTripAmbulances,
    List<AmbulanceRecord>? ambulancesList,
    int? totalBeds,
    int? availableBeds,
    int? occupiedBeds,
    int? generalBedsAvailable,
    int? icuBedsAvailable,
    int? totalDoctors,
    int? availableDoctors,
    int? onDutyDoctors,
    int? emergencyDoctorsCount,
    List<DoctorRecord>? doctorsList,
    NgoServiceDetails? details,
    Map<String, dynamic>? categoryDetails,
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
      imageUrl: imageUrl == _sentinel ? this.imageUrl : imageUrl as String?,
      additionalImageUrls: additionalImageUrls ?? this.additionalImageUrls,
      alternateContactPhone:
          alternateContactPhone ?? this.alternateContactPhone,
      whatsappAvailable: whatsappAvailable ?? this.whatsappAvailable,
      wheelchairAccessible: wheelchairAccessible ?? this.wheelchairAccessible,
      drinkingWaterAvailable:
          drinkingWaterAvailable ?? this.drinkingWaterAvailable,
      seatingAvailable: seatingAvailable ?? this.seatingAvailable,
      accessibleToilet: accessibleToilet ?? this.accessibleToilet,
      seniorCitizenFriendly:
          seniorCitizenFriendly ?? this.seniorCitizenFriendly,
      importantInstructions:
          importantInstructions ?? this.importantInstructions,
      emergencySupportAvailable:
          emergencySupportAvailable ?? this.emergencySupportAvailable,
      ambulanceAvailable: ambulanceAvailable ?? this.ambulanceAvailable,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      ambulanceContactPhone:
          ambulanceContactPhone ?? this.ambulanceContactPhone,
      emergencyInstructions:
          emergencyInstructions ?? this.emergencyInstructions,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      totalAmbulances: totalAmbulances ?? this.totalAmbulances,
      availableAmbulances: availableAmbulances ?? this.availableAmbulances,
      onTripAmbulances: onTripAmbulances ?? this.onTripAmbulances,
      ambulancesList: ambulancesList ?? this.ambulancesList,
      totalBeds: totalBeds ?? this.totalBeds,
      availableBeds: availableBeds ?? this.availableBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      generalBedsAvailable: generalBedsAvailable ?? this.generalBedsAvailable,
      icuBedsAvailable: icuBedsAvailable ?? this.icuBedsAvailable,
      totalDoctors: totalDoctors ?? this.totalDoctors,
      availableDoctors: availableDoctors ?? this.availableDoctors,
      onDutyDoctors: onDutyDoctors ?? this.onDutyDoctors,
      emergencyDoctorsCount:
          emergencyDoctorsCount ?? this.emergencyDoctorsCount,
      doctorsList: doctorsList ?? this.doctorsList,
      details: details ?? this.details,
      categoryDetails: categoryDetails ?? this.categoryDetails,
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
        return 'Drinking Water & Jal Seva';
      case NgoServiceCategory.shelter:
        return 'Night Halt & Shelter';
      case NgoServiceCategory.clothing:
        return 'Clothing & Material Distribution';
      case NgoServiceCategory.sanitation:
        return 'Sanitation & Bio-Toilets';
      case NgoServiceCategory.volunteer:
        return 'Volunteer & Help Desk';
      case NgoServiceCategory.emergency:
        return 'Emergency & Rescue';
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

  factory NgoService.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] ?? 'other').toString().toLowerCase();
    NgoServiceCategory parsedCategory = NgoServiceCategory.other;
    if (catStr.contains('med')) {
      parsedCategory = NgoServiceCategory.medical;
    } else if (catStr.contains('food') || catStr.contains('anna')) {
      parsedCategory = NgoServiceCategory.food;
    } else if (catStr.contains('water') || catStr.contains('jal')) {
      parsedCategory = NgoServiceCategory.water;
    } else if (catStr.contains('shelter') || catStr.contains('niwas')) {
      parsedCategory = NgoServiceCategory.shelter;
    } else if (catStr.contains('cloth') || catStr.contains('vastra')) {
      parsedCategory = NgoServiceCategory.clothing;
    } else if (catStr.contains('sanitat') || catStr.contains('toilet')) {
      parsedCategory = NgoServiceCategory.sanitation;
    } else if (catStr.contains('volun') || catStr.contains('help')) {
      parsedCategory = NgoServiceCategory.volunteer;
    } else if (catStr.contains('emerg') || catStr.contains('rescue')) {
      parsedCategory = NgoServiceCategory.emergency;
    } else if (catStr.contains('lost')) {
      parsedCategory = NgoServiceCategory.lostAndFound;
    }

    final availStr = (json['availability_status'] ??
            json['availabilityStatus'] ??
            json['availability'] ??
            'available')
        .toString()
        .toLowerCase();
    ServiceAvailability parsedAvail = ServiceAvailability.available;
    if (availStr.contains('limit') || availStr.contains('slow')) {
      parsedAvail = ServiceAvailability.limited;
    } else if (availStr.contains('unavail') ||
        availStr.contains('close') ||
        availStr.contains('exhaust')) {
      parsedAvail = ServiceAvailability.unavailable;
    }

    final isVerified = json['is_verified'] == true ||
        json['isVerified'] == true ||
        json['isApproved'] == true;

    // Extract images list if available
    List<String> imageList = [];
    if (json['images'] is List) {
      for (final img in json['images']) {
        if (img is Map && img['storage_path'] != null) {
          final path = img['storage_path'].toString();
          if (path.startsWith('http')) {
            imageList.add(path);
          } else {
            imageList.add(
                'https://fjnhsaxuwyairfgrciyf.supabase.co/storage/v1/object/public/$path');
          }
        } else if (img is String) {
          imageList.add(img);
        }
      }
    } else if (json['service_images'] is List) {
      for (final img in json['service_images']) {
        if (img is Map && img['storage_path'] != null) {
          final path = img['storage_path'].toString();
          if (path.startsWith('http')) {
            imageList.add(path);
          } else {
            imageList.add(
                'https://fjnhsaxuwyairfgrciyf.supabase.co/storage/v1/object/public/$path');
          }
        }
      }
    }

    String? primaryImage = json['imageUrl']?.toString() ??
        json['image_url']?.toString() ??
        (imageList.isNotEmpty ? imageList.first : null);

    List<String> additionalImages = [];
    if (json['additionalImageUrls'] is List) {
      additionalImages = (json['additionalImageUrls'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (imageList.length > 1) {
      additionalImages = imageList.sublist(1);
    }

    // Category details parsing
    Map<String, dynamic> parsedCategoryDetails = {};
    if (json['category_details'] is Map<String, dynamic>) {
      parsedCategoryDetails =
          Map<String, dynamic>.from(json['category_details']);
    } else if (json['categoryDetails'] is Map<String, dynamic>) {
      parsedCategoryDetails =
          Map<String, dynamic>.from(json['categoryDetails']);
    }

    // Parse service_details if returned by join or nested object
    NgoServiceDetails? parsedDetails;
    if (json['service_details'] is Map<String, dynamic>) {
      parsedDetails = NgoServiceDetails.fromJson(
          Map<String, dynamic>.from(json['service_details']));
    } else if (json['service_details'] is List &&
        (json['service_details'] as List).isNotEmpty &&
        (json['service_details'] as List).first is Map) {
      parsedDetails = NgoServiceDetails.fromJson(
          Map<String, dynamic>.from((json['service_details'] as List).first));
    } else if (json['serviceDetails'] is Map<String, dynamic>) {
      parsedDetails = NgoServiceDetails.fromJson(
          Map<String, dynamic>.from(json['serviceDetails']));
    } else {
      parsedDetails = NgoServiceDetails.fromJson(json);
    }

    // Emergency contacts parsing
    List<Map<String, dynamic>> parsedEmergencyContacts = [];
    if (parsedCategoryDetails['emergency_contacts'] is List) {
      parsedEmergencyContacts =
          (parsedCategoryDetails['emergency_contacts'] as List)
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
    } else if (json['emergency_contacts'] is List) {
      parsedEmergencyContacts = (json['emergency_contacts'] as List)
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }

    // Ambulances list parsing
    List<AmbulanceRecord> parsedAmbulances = [];
    if (json['ambulances'] is List) {
      parsedAmbulances = (json['ambulances'] as List)
          .whereType<Map>()
          .map((m) => AmbulanceRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } else if (parsedCategoryDetails['ambulances'] is List) {
      parsedAmbulances = (parsedCategoryDetails['ambulances'] as List)
          .whereType<Map>()
          .map((m) => AmbulanceRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    // Doctors list parsing
    List<DoctorRecord> parsedDoctors = [];
    if (json['doctors'] is List) {
      parsedDoctors = (json['doctors'] as List)
          .whereType<Map>()
          .map((m) => DoctorRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } else if (parsedCategoryDetails['doctors'] is List) {
      parsedDoctors = (parsedCategoryDetails['doctors'] as List)
          .whereType<Map>()
          .map((m) => DoctorRecord.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return NgoService(
      id: json['id']?.toString() ??
          json['serviceCode']?.toString() ??
          json['service_id']?.toString() ??
          '',
      ngoId: json['provider_id']?.toString() ??
          json['providerId']?.toString() ??
          json['ngoId']?.toString() ??
          'ngo-001',
      name: json['name']?.toString() ?? 'Wari Seva Service',
      category: parsedCategory,
      description: json['description']?.toString() ?? '',
      latitude: (json['latitude'] is num)
          ? (json['latitude'] as num).toDouble()
          : (double.tryParse(json['latitude']?.toString() ?? '') ?? 17.6775),
      longitude: (json['longitude'] is num)
          ? (json['longitude'] as num).toDouble()
          : (double.tryParse(json['longitude']?.toString() ?? '') ?? 75.3260),
      locationName: json['address']?.toString() ??
          json['locationName']?.toString() ??
          'Pandharpur Wari Route',
      capacity: parsedDetails.serviceCapacity ??
          json['capacity']?.toString() ??
          'Open Capacity',
      operatingHours: parsedDetails.operatingHours ??
          json['operating_hours']?.toString() ??
          json['operatingHours']?.toString() ??
          '24 Hours Open',
      contactPhone: json['contact_phone']?.toString() ??
          json['contactPhone']?.toString() ??
          '',
      availability: parsedAvail,
      lastUpdatedAt: DateTime.tryParse(json['updated_at']?.toString() ??
              json['lastUpdatedAt']?.toString() ??
              '') ??
          DateTime.now(),
      isApproved: isVerified,
      imageUrl: primaryImage,
      additionalImageUrls: additionalImages,
      alternateContactPhone: parsedDetails.alternateContactPhone ??
          json['alternate_contact_phone']?.toString() ??
          json['alternateContactPhone']?.toString(),
      whatsappAvailable: parsedDetails.whatsappAvailable ||
          json['whatsapp_available'] == true ||
          json['whatsappAvailable'] == true,
      wheelchairAccessible: parsedDetails.wheelchairAccessible ||
          json['wheelchair_accessible'] == true ||
          json['wheelchairAccessible'] == true,
      drinkingWaterAvailable: parsedDetails.drinkingWater ||
          json['drinking_water_available'] == true ||
          json['drinkingWaterAvailable'] == true ||
          json['drinking_water'] == true,
      seatingAvailable: parsedDetails.seatingAvailable ||
          json['seating_available'] == true ||
          json['seatingAvailable'] == true,
      accessibleToilet: parsedDetails.accessibleToilet ||
          json['accessible_toilet'] == true ||
          json['accessibleToilet'] == true,
      seniorCitizenFriendly: parsedDetails.seniorCitizenFriendly ||
          json['senior_citizen_friendly'] == true ||
          json['seniorCitizenFriendly'] == true,
      importantInstructions: parsedDetails.importantInstructions ??
          json['important_instructions']?.toString() ??
          json['importantInstructions']?.toString(),
      emergencySupportAvailable: json['emergency_support_available'] == true ||
          parsedCategoryDetails['emergency_support_available'] == true,
      ambulanceAvailable: json['ambulance_available'] == true ||
          parsedCategoryDetails['ambulance_available'] == true,
      emergencyContactPhone: json['emergency_contact_phone']?.toString() ??
          parsedCategoryDetails['emergency_contact_phone']?.toString(),
      ambulanceContactPhone: json['ambulance_contact_phone']?.toString() ??
          parsedCategoryDetails['ambulance_contact_phone']?.toString(),
      emergencyInstructions: json['emergency_instructions']?.toString() ??
          parsedCategoryDetails['emergency_instructions']?.toString(),
      emergencyContacts: parsedEmergencyContacts,
      totalAmbulances: parseInt(json['total_ambulances'] ??
          parsedCategoryDetails['total_ambulances']),
      availableAmbulances: parseInt(json['available_ambulances'] ??
          parsedCategoryDetails['available_ambulances']),
      onTripAmbulances: parseInt(json['on_trip_ambulances'] ??
          parsedCategoryDetails['on_trip_ambulances']),
      ambulancesList: parsedAmbulances,
      totalBeds:
          parseInt(json['total_beds'] ?? parsedCategoryDetails['total_beds']),
      availableBeds: parseInt(json['available_beds'] ??
          parsedCategoryDetails['available_beds'] ??
          parsedDetails.bedsAvailable),
      occupiedBeds: parseInt(
          json['occupied_beds'] ?? parsedCategoryDetails['occupied_beds']),
      generalBedsAvailable: parseInt(json['general_beds_available'] ??
          parsedCategoryDetails['general_beds_available']),
      icuBedsAvailable: parseInt(json['icu_beds_available'] ??
          parsedCategoryDetails['icu_beds_available']),
      totalDoctors: parseInt(
          json['total_doctors'] ?? parsedCategoryDetails['total_doctors']),
      availableDoctors: parseInt(json['available_doctors'] ??
          parsedCategoryDetails['available_doctors'] ??
          parsedDetails.doctorsAvailable),
      onDutyDoctors: parseInt(
          json['on_duty_doctors'] ?? parsedCategoryDetails['on_duty_doctors']),
      emergencyDoctorsCount: parseInt(json['emergency_doctors_count'] ??
          parsedCategoryDetails['emergency_doctors_count']),
      doctorsList: parsedDoctors,
      details: parsedDetails,
      categoryDetails: parsedCategoryDetails,
    );
  }

  Map<String, dynamic> toJson() {
    final mergedCategoryDetails = Map<String, dynamic>.from(categoryDetails);
    if (emergencyContacts.isNotEmpty) {
      mergedCategoryDetails['emergency_contacts'] = emergencyContacts;
    }
    if (emergencySupportAvailable) {
      mergedCategoryDetails['emergency_support_available'] = true;
    }
    if (ambulanceAvailable) {
      mergedCategoryDetails['ambulance_available'] = true;
    }
    if (emergencyContactPhone != null) {
      mergedCategoryDetails['emergency_contact_phone'] = emergencyContactPhone;
    }
    if (ambulanceContactPhone != null) {
      mergedCategoryDetails['ambulance_contact_phone'] = ambulanceContactPhone;
    }
    if (emergencyInstructions != null) {
      mergedCategoryDetails['emergency_instructions'] = emergencyInstructions;
    }
    if (totalAmbulances != null) {
      mergedCategoryDetails['total_ambulances'] = totalAmbulances;
    }
    if (availableAmbulances != null) {
      mergedCategoryDetails['available_ambulances'] = availableAmbulances;
    }
    if (onTripAmbulances != null) {
      mergedCategoryDetails['on_trip_ambulances'] = onTripAmbulances;
    }
    if (ambulancesList.isNotEmpty) {
      mergedCategoryDetails['ambulances'] =
          ambulancesList.map((a) => a.toJson()).toList();
    }
    if (totalBeds != null) mergedCategoryDetails['total_beds'] = totalBeds;
    if (availableBeds != null) {
      mergedCategoryDetails['available_beds'] = availableBeds;
    }
    if (occupiedBeds != null) {
      mergedCategoryDetails['occupied_beds'] = occupiedBeds;
    }
    if (generalBedsAvailable != null) {
      mergedCategoryDetails['general_beds_available'] = generalBedsAvailable;
    }
    if (icuBedsAvailable != null) {
      mergedCategoryDetails['icu_beds_available'] = icuBedsAvailable;
    }
    if (totalDoctors != null) {
      mergedCategoryDetails['total_doctors'] = totalDoctors;
    }
    if (availableDoctors != null) {
      mergedCategoryDetails['available_doctors'] = availableDoctors;
    }
    if (onDutyDoctors != null) {
      mergedCategoryDetails['on_duty_doctors'] = onDutyDoctors;
    }
    if (emergencyDoctorsCount != null) {
      mergedCategoryDetails['emergency_doctors_count'] = emergencyDoctorsCount;
    }
    if (doctorsList.isNotEmpty) {
      mergedCategoryDetails['doctors'] =
          doctorsList.map((d) => d.toJson()).toList();
    }

    final effectiveDetails = details ??
        NgoServiceDetails(
          serviceId: id,
          serviceCapacity: capacity,
          operatingHours: operatingHours,
          isOpen24Hours: operatingHours.toLowerCase().contains('24'),
          bedsAvailable: availableBeds,
          doctorsAvailable: availableDoctors,
          alternateContactPhone: alternateContactPhone,
          whatsappAvailable: whatsappAvailable,
          wheelchairAccessible: wheelchairAccessible,
          drinkingWater: drinkingWaterAvailable,
          seatingAvailable: seatingAvailable,
          accessibleToilet: accessibleToilet,
          seniorCitizenFriendly: seniorCitizenFriendly,
          importantInstructions: importantInstructions,
        );

    return {
      'service_id': id,
      'category': category.name,
      'name': name,
      'description': description,
      'address': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'contact_phone': contactPhone,
      'availability_status': availabilityLabel,
      'is_verified': isApproved,
      'provider_id': ngoId,
      'provider_type': 'NGO',
      'capacity': capacity,
      'operating_hours': operatingHours,
      if (alternateContactPhone != null)
        'alternate_contact_phone': alternateContactPhone,
      'whatsapp_available': whatsappAvailable,
      'wheelchair_accessible': wheelchairAccessible,
      'drinking_water_available': drinkingWaterAvailable,
      'seating_available': seatingAvailable,
      'accessible_toilet': accessibleToilet,
      'senior_citizen_friendly': seniorCitizenFriendly,
      if (importantInstructions != null)
        'important_instructions': importantInstructions,
      'emergency_support_available': emergencySupportAvailable,
      'ambulance_available': ambulanceAvailable,
      if (emergencyContactPhone != null)
        'emergency_contact_phone': emergencyContactPhone,
      if (ambulanceContactPhone != null)
        'ambulance_contact_phone': ambulanceContactPhone,
      if (emergencyInstructions != null)
        'emergency_instructions': emergencyInstructions,
      'service_details': effectiveDetails.toJson(),
      if (mergedCategoryDetails.isNotEmpty)
        'category_details': mergedCategoryDetails,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (additionalImageUrls.isNotEmpty)
        'additionalImageUrls': additionalImageUrls,
    };
  }
}
