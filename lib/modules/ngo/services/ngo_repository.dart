import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:maza_pandurang/core/api/api_client.dart';
import 'package:maza_pandurang/core/auth/auth_service.dart';

import '../models/ngo_organization.dart';
import '../models/ngo_service.dart';
import '../models/ngo_service_details.dart';
import '../models/service_report.dart';
import 'ngo_mock_data.dart';

/// Central state repository for the NGO module.
/// Communicates with shared REST API endpoints via [ApiClient] while maintaining
/// synchronous in-memory state for instant UI responsiveness and offline fallback.
class NgoRepository extends ChangeNotifier {
  // Singleton pattern
  static final NgoRepository _instance = NgoRepository._internal();
  factory NgoRepository() => _instance;

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  NgoRepository._internal() {
    _services = List.from(NgoMockData.initialServices);
    _organization = NgoMockData.defaultOrganization;
    _reports = List.from(NgoMockData.initialReports);
  }

  NgoOrganization _organization = NgoMockData.defaultOrganization;
  List<NgoService> _services = [];
  List<ServiceReport> _reports = [];

  bool _isLoading = false;
  String? _errorMessage;

  @visibleForTesting
  void resetForTesting() {
    _services = List.from(NgoMockData.initialServices);
    _organization = NgoMockData.defaultOrganization;
    _reports = List.from(NgoMockData.initialReports);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Getters
  NgoOrganization get organization => _organization;
  List<NgoService> get services => List.unmodifiable(_services);
  List<ServiceReport> get reports => List.unmodifiable(_reports);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalServicesCount => _services.length;
  int get activeServicesCount => _services
      .where((s) => s.availability == ServiceAvailability.available)
      .length;
  int get limitedServicesCount => _services
      .where((s) => s.availability == ServiceAvailability.limited)
      .length;
  int get reportedIssuesCount => _reports.length;

  // ───────────────────────────────────────────────────────────────────────────
  // NGO Profile API Operations
  // ───────────────────────────────────────────────────────────────────────────

  /// Fetch NGO Profile from backend `GET /api/ngos` or `GET /api/ngos/:id`
  Future<void> fetchNgoProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userProfile = _authService.currentProfile;
      final userId = userProfile?['id']?.toString() ??
          '00000000-0000-0000-0000-000000000004';

      // Query all NGOs (or pending/approved)
      final res = await _apiClient
          .get('/ngos?status=all')
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        // Find NGO associated with current user
        final userNgo = list.firstWhere(
          (item) => item['user_id']?.toString() == userId,
          orElse: () => null,
        );

        if (userNgo != null) {
          _organization =
              NgoOrganization.fromJson(userNgo as Map<String, dynamic>);
          _errorMessage = null;
        } else if (list.isNotEmpty && userId == '00000000-0000-0000-0000-000000000004') {
          _organization =
              NgoOrganization.fromJson(list.first as Map<String, dynamic>);
          _errorMessage = null;
        } else if (userProfile != null) {
          final regNo = 'NGO-MH-${userId.substring(0, userId.length > 8 ? 8 : userId.length).toUpperCase()}';
          _organization = NgoOrganization(
            id: 'ngo-pending-$userId',
            userId: userId,
            name: '${userProfile['display_name'] ?? 'Seva'} Seva Mandal',
            registrationNo: regNo,
            contactPerson: userProfile['display_name'] ?? 'NGO Volunteer',
            phone: userProfile['phone'] ?? '',
            email: userProfile['email'] ?? '',
            primaryCategory: 'Food & Medical Seva',
            approvalStatus: (userProfile['status']?.toString().toLowerCase() == 'active')
                ? NgoApprovalStatus.approved
                : NgoApprovalStatus.pending,
            createdAt: DateTime.now(),
          );
          _errorMessage = null;
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        _errorMessage = 'Unauthorized. Please sign in as an NGO volunteer.';
      } else {
        _errorMessage = 'Failed to load NGO profile (${res.statusCode})';
      }
    } catch (e) {
      debugPrint('[NgoRepository] fetchNgoProfile fallback: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register or submit a new NGO application via `POST /api/ngos`.
  /// The backend creates the NGO in `pending` status for admin moderation.
  Future<bool> registerOrganization({
    required String name,
    required String registrationNo,
    required String contactPerson,
    required String phone,
    required String email,
    required String primaryCategory,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final userId = _authService.currentProfile?['id']?.toString() ??
        '00000000-0000-0000-0000-000000000004';

    final payload = {
      'user_id': userId,
      'name': name,
      'registration_number': registrationNo,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'primary_category': primaryCategory,
      'status': 'pending',
    };

    // Update local state immediately to pending
    _organization = NgoOrganization(
      id: 'ngo-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      name: name,
      registrationNo: registrationNo,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      primaryCategory: primaryCategory,
      approvalStatus: NgoApprovalStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      final res = await _apiClient
          .post('/ngos', body: payload)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _organization = NgoOrganization.fromJson(data as Map<String, dynamic>);
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        _errorMessage = 'Unauthorized to register NGO.';
      } else {
        _errorMessage = 'Registration submission error (${res.statusCode})';
      }
    } catch (e) {
      debugPrint('[NgoRepository] registerOrganization fallback: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return true; // Local state updated regardless
  }

  /// Update NGO Organization profile via `PATCH /api/ngos/:id`
  Future<bool> updateOrganizationProfile({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? primaryCategory,
  }) async {
    _organization = _organization.copyWith(
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      primaryCategory: primaryCategory,
    );
    notifyListeners();

    try {
      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (contactPerson != null) 'contact_person': contactPerson,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (primaryCategory != null) 'primary_category': primaryCategory,
      };

      final res = await _apiClient
          .patch('/ngos/${_organization.id}', body: body)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _organization = NgoOrganization.fromJson(data as Map<String, dynamic>);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[NgoRepository] updateOrganizationProfile fallback: $e');
    }
    return false;
  }

  /// Fetch NGO gallery photos via `GET /api/ngos/:id/images`
  Future<List<Map<String, dynamic>>> fetchNgoImages() async {
    try {
      final res = await _apiClient
          .get('/ngos/${_organization.id}/images')
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[NgoRepository] fetchNgoImages fallback: $e');
    }
    return [];
  }

  /// Add an NGO gallery photo record via `POST /api/ngos/:id/images`
  Future<bool> addNgoImageRecord(String imageUrl,
      {String caption = 'NGO Gallery'}) async {
    try {
      final res =
          await _apiClient.post('/ngos/${_organization.id}/images', body: {
        'image_url': imageUrl,
        'caption': caption,
      }).timeout(const Duration(seconds: 4));
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('[NgoRepository] addNgoImageRecord error: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Service CRUD API Operations
  // ───────────────────────────────────────────────────────────────────────────

  /// Fetch services via `GET /api/services?all=true`
  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient
          .get('/services?all=true')
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        if (list.isNotEmpty) {
          _services = list
              .map((item) => NgoService.fromJson(item as Map<String, dynamic>))
              .toList();
          _errorMessage = null;
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        _errorMessage = 'Session expired. Please sign in again.';
      } else {
        _errorMessage = 'Failed to load services (${res.statusCode})';
      }
    } catch (e) {
      debugPrint('[NgoRepository] fetchServices fallback: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new service via `POST /api/services`.
  /// Note: The service is created with `is_verified: false` and must await Admin approval.
  Future<bool> addService(NgoService service) async {
    // Add locally for instant UI responsiveness
    _services.add(service);
    notifyListeners();

    try {
      final payload = {
        'service_id': service.id,
        'category': service.categoryLabel.split(' ').first,
        'name': service.name,
        'description': service.description,
        'address': service.locationName,
        'latitude': service.latitude,
        'longitude': service.longitude,
        'contact_phone': service.contactPhone,
        'availability_status': service.availabilityLabel,
        'is_verified': false, // Moderation gate: awaits Admin verification
        'provider_id': _organization.id,
        'provider_type': 'NGO',
        'provider_name': _organization.name,
        'capacity': service.capacity,
        'operating_hours': service.operatingHours,
        'alternate_contact_phone': service.alternateContactPhone,
        'whatsapp_available': service.whatsappAvailable,
        'wheelchair_accessible': service.wheelchairAccessible,
        'drinking_water_available': service.drinkingWaterAvailable,
        'seating_available': service.seatingAvailable,
        'accessible_toilet': service.accessibleToilet,
        'senior_citizen_friendly': service.seniorCitizenFriendly,
        'important_instructions': service.importantInstructions,
        'emergency_support_available': service.emergencySupportAvailable,
        'ambulance_available': service.ambulanceAvailable,
        'emergency_contact_phone': service.emergencyContactPhone,
        'ambulance_contact_phone': service.ambulanceContactPhone,
        'emergency_instructions': service.emergencyInstructions,
        'service_details': (service.details ??
                NgoServiceDetails(
                  serviceCapacity: service.capacity,
                  operatingHours: service.operatingHours,
                  isOpen24Hours:
                      service.operatingHours.toLowerCase().contains('24'),
                  alternateContactPhone: service.alternateContactPhone,
                  whatsappAvailable: service.whatsappAvailable,
                  wheelchairAccessible: service.wheelchairAccessible,
                  drinkingWater: service.drinkingWaterAvailable,
                  seatingAvailable: service.seatingAvailable,
                  accessibleToilet: service.accessibleToilet,
                  seniorCitizenFriendly: service.seniorCitizenFriendly,
                  importantInstructions: service.importantInstructions,
                ))
            .toJson(),
        'category_details':
            service.toJson()['category_details'] ?? service.categoryDetails,
      };

      final res = await _apiClient
          .post('/services', body: payload)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final created = NgoService.fromJson(data as Map<String, dynamic>);
        final idx = _services.indexWhere((s) => s.id == service.id);
        if (idx != -1) {
          _services[idx] = created.copyWith(
            imageUrl: service.imageUrl,
            additionalImageUrls: service.additionalImageUrls,
          );
          notifyListeners();
        }

        // Persist images to service_images table using created service UUID
        final createdId = data['id']?.toString() ?? created.id;
        for (final imgUrl in service.allImageUrls) {
          _syncServiceImageRecord(createdId, imgUrl);
        }

        return true;
      }
    } catch (e) {
      debugPrint('[NgoRepository] addService fallback: $e');
    }
    return true;
  }

  /// Update existing service details via `PATCH /api/services/:id`
  Future<bool> updateService(NgoService updatedService) async {
    final index = _services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      _services[index] = updatedService.copyWith(
        lastUpdatedAt: DateTime.now(),
      );
      notifyListeners();
    }

    try {
      final payload = {
        'name': updatedService.name,
        'description': updatedService.description,
        'address': updatedService.locationName,
        'latitude': updatedService.latitude,
        'longitude': updatedService.longitude,
        'contact_phone': updatedService.contactPhone,
        'availability_status': updatedService.availabilityLabel,
        'capacity': updatedService.capacity,
        'operating_hours': updatedService.operatingHours,
        'alternate_contact_phone': updatedService.alternateContactPhone,
        'whatsapp_available': updatedService.whatsappAvailable,
        'wheelchair_accessible': updatedService.wheelchairAccessible,
        'drinking_water_available': updatedService.drinkingWaterAvailable,
        'seating_available': updatedService.seatingAvailable,
        'accessible_toilet': updatedService.accessibleToilet,
        'senior_citizen_friendly': updatedService.seniorCitizenFriendly,
        'important_instructions': updatedService.importantInstructions,
        'emergency_support_available': updatedService.emergencySupportAvailable,
        'ambulance_available': updatedService.ambulanceAvailable,
        'emergency_contact_phone': updatedService.emergencyContactPhone,
        'ambulance_contact_phone': updatedService.ambulanceContactPhone,
        'emergency_instructions': updatedService.emergencyInstructions,
        'service_details': (updatedService.details ??
                NgoServiceDetails(
                  serviceCapacity: updatedService.capacity,
                  operatingHours: updatedService.operatingHours,
                  isOpen24Hours: updatedService.operatingHours
                      .toLowerCase()
                      .contains('24'),
                  alternateContactPhone: updatedService.alternateContactPhone,
                  whatsappAvailable: updatedService.whatsappAvailable,
                  wheelchairAccessible: updatedService.wheelchairAccessible,
                  drinkingWater: updatedService.drinkingWaterAvailable,
                  seatingAvailable: updatedService.seatingAvailable,
                  accessibleToilet: updatedService.accessibleToilet,
                  seniorCitizenFriendly: updatedService.seniorCitizenFriendly,
                  importantInstructions: updatedService.importantInstructions,
                ))
            .toJson(),
        'category_details': updatedService.toJson()['category_details'] ??
            updatedService.categoryDetails,
      };

      final res = await _apiClient
          .patch('/services/${updatedService.id}', body: payload)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('[NgoRepository] updateService fallback: $e');
    }
    return true;
  }

  /// Update service availability in real-time via `PATCH /api/services/:id`
  Future<bool> updateServiceAvailability(
      String serviceId, ServiceAvailability newAvailability) async {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      _services[index] = _services[index].copyWith(
        availability: newAvailability,
        lastUpdatedAt: DateTime.now(),
      );
      notifyListeners();
    }

    try {
      final payload = {
        'availability_status': newAvailability.name.toUpperCase(),
      };

      final res = await _apiClient
          .patch('/services/$serviceId', body: payload)
          .timeout(const Duration(seconds: 4));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[NgoRepository] updateServiceAvailability fallback: $e');
    }
    return true;
  }

  /// Delete a service
  Future<void> deleteService(String serviceId) async {
    _services.removeWhere((s) => s.id == serviceId);
    notifyListeners();

    try {
      await _apiClient
          .delete('/services/$serviceId')
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[NgoRepository] deleteService fallback: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Service Images Operations
  // ───────────────────────────────────────────────────────────────────────────

  /// Asynchronously sync image storage path to `service_images` table
  Future<void> _syncServiceImageRecord(
      String serviceId, String imageUrl) async {
    try {
      await _apiClient.post('/services/$serviceId/images', body: {
        'storage_path': imageUrl,
      }).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[NgoRepository] _syncServiceImageRecord error: $e');
    }
  }

  /// Update the primary image URL for a service
  void updateServiceImage(String serviceId, String? imageUrl) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      _services[index] = _services[index].copyWith(imageUrl: imageUrl);
      notifyListeners();
    }
    if (imageUrl != null) {
      _syncServiceImageRecord(serviceId, imageUrl);
    }
  }

  /// Append a new image URL to the service's gallery
  void addServiceImage(String serviceId, String imageUrl) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index == -1) return;
    final svc = _services[index];
    if (svc.imageUrl == null) {
      _services[index] = svc.copyWith(imageUrl: imageUrl);
    } else {
      _services[index] = svc.copyWith(
        additionalImageUrls: [...svc.additionalImageUrls, imageUrl],
      );
    }
    notifyListeners();
    _syncServiceImageRecord(serviceId, imageUrl);
  }

  /// Remove a specific image URL from the service's gallery
  void removeServiceImage(String serviceId, String imageUrl) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index == -1) return;
    final svc = _services[index];
    if (svc.imageUrl == imageUrl) {
      final newPrimary = svc.additionalImageUrls.isNotEmpty
          ? svc.additionalImageUrls.first
          : null;
      final newAdditional = svc.additionalImageUrls.isNotEmpty
          ? svc.additionalImageUrls.sublist(1)
          : <String>[];
      _services[index] = svc.copyWith(
        imageUrl: newPrimary,
        additionalImageUrls: newAdditional,
      );
    } else {
      _services[index] = svc.copyWith(
        additionalImageUrls:
            svc.additionalImageUrls.where((u) => u != imageUrl).toList(),
      );
    }
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Demo Controls
  // ───────────────────────────────────────────────────────────────────────────

  /// Toggle approval status for hackathon live demo presentation
  void toggleDemoApprovalStatus() {
    if (_organization.approvalStatus == NgoApprovalStatus.approved) {
      _organization = _organization.copyWith(
        approvalStatus: NgoApprovalStatus.pending,
      );
    } else if (_organization.approvalStatus == NgoApprovalStatus.pending) {
      _organization = _organization.copyWith(
        approvalStatus: NgoApprovalStatus.rejected,
      );
    } else {
      _organization = _organization.copyWith(
        approvalStatus: NgoApprovalStatus.approved,
      );
    }
    notifyListeners();
  }

  /// Explicitly set approval status
  void setApprovalStatus(NgoApprovalStatus status) {
    _organization = _organization.copyWith(approvalStatus: status);
    notifyListeners();
  }

  /// In-memory report submission (kept for repository testing)
  void submitReport({
    required String serviceId,
    required String serviceName,
    required String reporterName,
    required ReportReason reason,
    required String comments,
  }) {
    final report = ServiceReport(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      serviceId: serviceId,
      serviceName: serviceName,
      reporterName: reporterName,
      reason: reason,
      comments: comments,
      timestamp: DateTime.now(),
    );
    _reports.insert(0, report);
    notifyListeners();
  }
}
