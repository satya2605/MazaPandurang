import 'package:flutter/foundation.dart';
import '../models/ngo_organization.dart';
import '../models/ngo_service.dart';
import '../models/service_report.dart';
import 'ngo_mock_data.dart';

/// Centralized state manager for the NGO Module.
class NgoRepository extends ChangeNotifier {
  static final NgoRepository _instance = NgoRepository._internal();
  factory NgoRepository() => _instance;

  NgoRepository._internal() {
    _organization = NgoMockData.defaultOrganization;
    _services = List.from(NgoMockData.initialServices);
    _reports = List.from(NgoMockData.initialReports);
  }

  /// Reset state to default initial mock data for unit tests
  void resetForTesting() {
    _organization = NgoMockData.defaultOrganization;
    _services = List.from(NgoMockData.initialServices);
    _reports = List.from(NgoMockData.initialReports);
    notifyListeners();
  }

  late NgoOrganization _organization;
  late List<NgoService> _services;
  late List<ServiceReport> _reports;

  NgoOrganization get organization => _organization;
  List<NgoService> get services => List.unmodifiable(_services);
  List<ServiceReport> get reports => List.unmodifiable(_reports);

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

  /// Register or update NGO organization profile
  void registerOrganization({
    required String name,
    required String registrationNo,
    required String contactPerson,
    required String phone,
    required String email,
    required String primaryCategory,
  }) {
    _organization = NgoOrganization(
      id: 'ngo-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      registrationNo: registrationNo,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      primaryCategory: primaryCategory,
      approvalStatus: NgoApprovalStatus.pending,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  /// Update availability status of a service in real-time
  void updateServiceAvailability(
      String serviceId, ServiceAvailability newAvailability) {
    final index = _services.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      _services[index] = _services[index].copyWith(
        availability: newAvailability,
        lastUpdatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Add a new Seva Service
  void addService(NgoService service) {
    _services.add(service);
    notifyListeners();
  }

  /// Update existing Seva Service
  void updateService(NgoService updatedService) {
    final index = _services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      _services[index] = updatedService.copyWith(
        lastUpdatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Delete a Seva Service
  void deleteService(String serviceId) {
    _services.removeWhere((s) => s.id == serviceId);
    notifyListeners();
  }

  /// Submit an incorrect information report for a service
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
