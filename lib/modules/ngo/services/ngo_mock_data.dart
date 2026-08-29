import '../models/ngo_organization.dart';
import '../models/ngo_service.dart';
import '../models/service_report.dart';

/// Pre-seeded mock data for demonstration during hackathon presentation.
abstract class NgoMockData {
  static final NgoOrganization defaultOrganization = NgoOrganization(
    id: 'ngo-001',
    name: 'Shree Sant Tukaram Seva Trust',
    registrationNo: 'NGO/PUNE/2021/8849',
    contactPerson: 'Shrutika Volunteer Lead',
    phone: '+91 98230 11223',
    email: 'contact@tukaramsevatrust.org',
    primaryCategory: 'Food & Medical Seva',
    approvalStatus: NgoApprovalStatus.approved,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  static final List<NgoService> initialServices = [
    NgoService(
      id: 'srv-101',
      ngoId: 'ngo-001',
      name: 'Vitthal Seva Annachhatra (Free Meals)',
      category: NgoServiceCategory.food,
      description:
          'Serving hot Maharashtrian meals (Pithla Bhakri, Khichdi, Sabudana) 24/7 to all Warkaris.',
      latitude: 17.6775,
      longitude: 75.3260,
      locationName: 'Pandharpur Bypass Road, Near Solapur Naka',
      capacity: '500 meals/hr',
      operatingHours: '24 Hours Open',
      contactPhone: '+91 98230 11223',
      availability: ServiceAvailability.available,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NgoService(
      id: 'srv-102',
      ngoId: 'ngo-001',
      name: 'Mauli Medical & First Aid Camp',
      category: NgoServiceCategory.medical,
      description:
          'Free foot massage, blister treatment, BP checkup, hydration salts & general medicine.',
      latitude: 17.6820,
      longitude: 75.3180,
      locationName: 'Wakhari Ringan Ground, Palkhi Halt #3',
      capacity: '50 beds & 4 Doctors',
      operatingHours: '06:00 AM - 11:00 PM',
      contactPhone: '+91 98230 44556',
      availability: ServiceAvailability.limited,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    NgoService(
      id: 'srv-103',
      ngoId: 'ngo-001',
      name: 'Nirmal Wari Drinking Water & Bio-Toilets',
      category: NgoServiceCategory.water,
      description:
          'Clean drinking water tanker station with 20 mobile bio-toilets for pilgrims.',
      latitude: 17.6740,
      longitude: 75.3310,
      locationName: 'Near ISKCON Temple Chowk, Pandharpur',
      capacity: '10,000 Litres Water',
      operatingHours: '24 Hours Open',
      contactPhone: '+91 98230 77889',
      availability: ServiceAvailability.available,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    NgoService(
      id: 'srv-104',
      ngoId: 'ngo-001',
      name: 'Pandharpur Night Shelter & Rain Shed',
      category: NgoServiceCategory.shelter,
      description:
          'Covered temporary waterproof shelter with clean blankets and sleeping mats for elderly Warkaris.',
      latitude: 17.6710,
      longitude: 75.3220,
      locationName: 'Bhakta Niwas Annexe Ground',
      capacity: '200 Pilgrims',
      operatingHours: '07:00 PM - 07:00 AM',
      contactPhone: '+91 98230 99000',
      availability: ServiceAvailability.unavailable,
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  static final List<ServiceReport> initialReports = [
    ServiceReport(
      id: 'rep-001',
      serviceId: 'srv-102',
      serviceName: 'Mauli Medical & First Aid Camp',
      reporterName: 'Warkari Pilgrim',
      reason: ReportReason.wrongAvailability,
      comments:
          'Long queue at doctor desk, medicine stock running low for hydration salts.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
  ];
}
