import '../models/ambulance_record.dart';
import '../models/doctor_record.dart';
import '../models/ngo_organization.dart';
import '../models/ngo_service.dart';
import '../models/ngo_service_details.dart';
import '../models/service_report.dart';

// ── Dummy images using picsum.photos (stable, free, no auth needed) ──────────
// Each seed produces a consistent deterministic image.
// Format: https://picsum.photos/seed/<seed>/800/450

/// Builds a picsum image URL for demo purposes.
String _demo(String seed) => 'https://picsum.photos/seed/$seed/800/450';

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

  static final List<ServiceReport> initialReports = [
    ServiceReport(
      id: 'rep-001',
      serviceId: 'srv-101',
      serviceName: 'Vitthal Seva Annachhatra (Free Meals)',
      reporterName: 'Tukaram Maharaj Dindi Volunteer',
      reason: ReportReason.wrongAvailability,
      comments: 'Evening rush increased, need extra khichdi batch.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  static final List<NgoService> initialServices = [
    // ── Service 1: Food / Annachhatra ────────────────────────────────────────
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
      imageUrl: _demo('food-distribution-wari'),
      additionalImageUrls: [
        _demo('community-kitchen'),
        _demo('warm-meal-seva'),
      ],
      details: const NgoServiceDetails(
        serviceCapacity: '500 meals/hr',
        operatingHours: '24 Hours Open',
        isOpen24Hours: true,
        mealsPerDay: 5000,
        beneficiariesPerDay: 3500,
        drinkingWater: true,
        seatingAvailable: true,
      ),
    ),

    // ── Service 2: Medical Camp (Mauli Medical & First Aid Camp) ─────────────
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
      capacity: '50 Beds Capacity',
      operatingHours: '06:00 AM - 11:00 PM',
      contactPhone: '+91 98230 44556',
      availability: ServiceAvailability.limited,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      imageUrl: _demo('medical-camp-outdoor'),
      additionalImageUrls: [
        _demo('first-aid-tent'),
        _demo('medicine-pharmacy'),
      ],
      emergencySupportAvailable: true,
      ambulanceAvailable: true,
      emergencyContactPhone: '+91 98230 11223',
      ambulanceContactPhone: '+91 98230 99999',
      emergencyInstructions:
          'Triage and critical resuscitation bay located at Sector 2 North Gate.',
      totalBeds: 50,
      availableBeds: 12,
      occupiedBeds: 38,
      generalBedsAvailable: 10,
      icuBedsAvailable: 2,
      totalDoctors: 4,
      availableDoctors: 2,
      onDutyDoctors: 2,
      emergencyDoctorsCount: 1,
      doctorsList: const [
        DoctorRecord(
          id: 'doc-1',
          name: 'Dr. Rajesh Kulkarni',
          specialization: 'MBBS, Emergency Medicine',
          status: 'Available Now',
          contactNumber: '+91 98230 44556',
          isEmergencyDoctor: true,
        ),
        DoctorRecord(
          id: 'doc-2',
          name: 'Dr. Sneha Joshi',
          specialization: 'MD, General Physician',
          status: 'Available Now',
          contactNumber: '+91 98230 44557',
        ),
        DoctorRecord(
          id: 'doc-3',
          name: 'Dr. Amit Deshmukh',
          specialization: 'Ortho & Trauma Specialist',
          status: 'On Duty',
          contactNumber: '+91 98230 44558',
        ),
        DoctorRecord(
          id: 'doc-4',
          name: 'Dr. Priya Patil',
          specialization: 'Pediatric & Family Medicine',
          status: 'On Duty',
          contactNumber: '+91 98230 44559',
        ),
      ],
      totalAmbulances: 3,
      availableAmbulances: 1,
      onTripAmbulances: 2,
      ambulancesList: const [
        AmbulanceRecord(
          id: 'amb-101',
          vehicleNumber: 'MH-12-AB-1234',
          ambulanceType: 'BLS (Basic Life Support)',
          contactNumber: '+91 98230 99999',
          status: 'Available',
          driverName: 'Ramesh Shinde',
          currentLocation: 'Camp Standby Gate 1',
        ),
        AmbulanceRecord(
          id: 'amb-102',
          vehicleNumber: 'MH-12-CD-5678',
          ambulanceType: 'ALS (Advanced Cardiac Care)',
          contactNumber: '+91 98230 56789',
          status: 'On Trip',
          driverName: 'Santosh Pawar',
          currentLocation: 'En Route to Civil Hospital',
        ),
        AmbulanceRecord(
          id: 'amb-103',
          vehicleNumber: 'MH-12-EF-9012',
          ambulanceType: 'BLS (Patient Transport)',
          contactNumber: '+91 98230 90123',
          status: 'On Trip',
          driverName: 'Vijay Jadhav',
          currentLocation: 'Palkhi Route KM 14',
        ),
      ],
      wheelchairAccessible: true,
      drinkingWaterAvailable: true,
      seatingAvailable: true,
      accessibleToilet: true,
      seniorCitizenFriendly: true,
      importantInstructions:
          'Priority tokens issued for senior citizen pilgrims and emergency foot blister dressings.',
      details: const NgoServiceDetails(
        serviceCapacity: '50 Beds Capacity',
        operatingHours: '06:00 AM - 11:00 PM',
        isOpen24Hours: false,
        doctorsAvailable: 2,
        bedsAvailable: 12,
        medicinesAvailable: 'ORS, Paracetamol, Pain Relief Sprays, Bandages',
        wheelchairAccessible: true,
        drinkingWater: true,
        seatingAvailable: true,
        accessibleToilet: true,
        seniorCitizenFriendly: true,
        importantInstructions:
            'Priority tokens issued for senior citizen pilgrims and emergency foot blister dressings.',
      ),
    ),

    // ── Service 3: Water Hub ──────────────────────────────────────────────────
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
      imageUrl: _demo('water-tanker-station'),
      additionalImageUrls: [
        _demo('clean-water-point'),
        _demo('hygiene-station'),
      ],
      details: const NgoServiceDetails(
        serviceCapacity: '10,000 Litres Water',
        operatingHours: '24 Hours Open',
        isOpen24Hours: true,
        waterCapacityLitresPerDay: 10000,
        waterTapsCount: 20,
        drinkingWater: true,
      ),
    ),

    // ── Service 4: Shelter ────────────────────────────────────────────────────
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
      operatingHours: '24 Hours Open',
      contactPhone: '+91 98230 66554',
      availability: ServiceAvailability.available,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      imageUrl: _demo('pilgrim-shelter-tent'),
      additionalImageUrls: [
        _demo('sleeping-mats-hall'),
        _demo('rain-protection-shed'),
      ],
      details: const NgoServiceDetails(
        serviceCapacity: '200 Pilgrims',
        operatingHours: '24 Hours Open',
        isOpen24Hours: true,
        availableSpaces: 200,
        currentOccupancy: '40 / 200',
        wheelchairAccessible: true,
        seatingAvailable: true,
      ),
    ),

    // ── Service 5: Clothing & Material Distribution ───────────────────────────
    NgoService(
      id: 'srv-105',
      ngoId: 'ngo-001',
      name: 'Warkari Vastra & Paduka Seva Kendra',
      category: NgoServiceCategory.clothing,
      description:
          'Free distribution of fresh dhotis, cotton kurtas, soft walking chappals, raincoats & warm shawls.',
      latitude: 17.6790,
      longitude: 75.3280,
      locationName: 'Bada Gopal Mandir Marg, Sector 4',
      capacity: '1,500 Sets/Day',
      operatingHours: '07:00 AM - 09:00 PM',
      contactPhone: '+91 98230 88112',
      availability: ServiceAvailability.available,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      imageUrl: _demo('clothing-distribution'),
      additionalImageUrls: [
        _demo('dhotis-stock'),
        _demo('raincoats-parcels'),
      ],
      categoryDetails: const {
        'items_in_stock': 500,
        'distribution_items': [
          'Dhoti & Kurta Sets',
          'Soft Walking Chappals',
          'Waterproof Raincoats',
          'Warm Fleece Blankets'
        ],
        'distribution_status': 'Active Counter Open',
        'distribution_timings': '07:00 AM - 09:00 PM',
      },
      details: const NgoServiceDetails(
        serviceCapacity: '1,500 Sets/Day',
        operatingHours: '07:00 AM - 09:00 PM',
        isOpen24Hours: false,
        beneficiariesPerDay: 1200,
        seniorCitizenFriendly: true,
        importantInstructions:
            'Priority tokens for senior citizens and barefoot Warkaris.',
      ),
    ),

    // ── Service 6: Sanitation & Bio-Toilets ───────────────────────────────────
    NgoService(
      id: 'srv-106',
      ngoId: 'ngo-001',
      name: 'Swachh Wari Bio-Toilet & Bathing Complex',
      category: NgoServiceCategory.sanitation,
      description:
          '24/7 clean mobile bio-toilets, separate ladies changing tents, hot water bathing points & soap dispensers.',
      latitude: 17.6730,
      longitude: 75.3190,
      locationName: 'Chandrabhaga Riverfront Ghat #2',
      capacity: '30 Bio-Toilets',
      operatingHours: '24 Hours Open',
      contactPhone: '+91 98230 77441',
      availability: ServiceAvailability.available,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
      imageUrl: _demo('sanitation-bio-toilets'),
      additionalImageUrls: [
        _demo('handwash-station'),
        _demo('clean-water-taps'),
      ],
      categoryDetails: const {
        'total_toilets': 30,
        'available_toilets': 26,
        'male_toilets': 12,
        'female_toilets': 14,
        'accessible_toilets': 4,
        'water_supply_status': 'Continuous Flow Active',
        'cleaning_interval': 'Cleaned every 30 minutes',
      },
      accessibleToilet: true,
      wheelchairAccessible: true,
      drinkingWaterAvailable: true,
      details: const NgoServiceDetails(
        serviceCapacity: '30 Bio-Toilets',
        operatingHours: '24 Hours Open',
        isOpen24Hours: true,
        accessibleToilet: true,
        wheelchairAccessible: true,
        drinkingWater: true,
      ),
    ),

    // ── Service 7: Volunteer & Help Desk ──────────────────────────────────────
    NgoService(
      id: 'srv-107',
      ngoId: 'ngo-001',
      name: 'Wari Mitra Volunteer & Lost-Person Desk',
      category: NgoServiceCategory.volunteer,
      description:
          'Central on-ground volunteer desk assisting elderly pilgrims, lost persons announcements, route guidance & emergency escort.',
      latitude: 17.6760,
      longitude: 75.3245,
      locationName: 'Central ST Stand Chowk, Pandharpur',
      capacity: '25 Active Volunteers',
      operatingHours: '24 Hours Open',
      contactPhone: '+91 98230 33445',
      availability: ServiceAvailability.available,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 4)),
      imageUrl: _demo('volunteer-help-desk'),
      additionalImageUrls: [
        _demo('lost-person-announcement'),
        _demo('route-map-guidance'),
      ],
      categoryDetails: const {
        'volunteers_on_duty': 12,
        'total_volunteers': 25,
        'languages_supported': [
          'Marathi',
          'Hindi',
          'Kannada',
          'Telugu',
          'English'
        ],
        'services_offered': [
          'Lost Person PA Announcements',
          'Senior Citizen Route Escort',
          'Wheelchair Transport',
          'Dindi Halt Guidance'
        ],
        'help_desk_status': '24x7 Help Desk Active',
      },
      wheelchairAccessible: true,
      seniorCitizenFriendly: true,
      details: const NgoServiceDetails(
        serviceCapacity: '25 Active Volunteers',
        operatingHours: '24 Hours Open',
        isOpen24Hours: true,
        wheelchairAccessible: true,
        seniorCitizenFriendly: true,
        importantInstructions:
            'PA loudspeaker announcements made every 15 minutes for separated family members.',
      ),
    ),

    // ── Service 8: Emergency & Rescue Standby ──────────────────────────────────
    NgoService(
      id: 'srv-108',
      ngoId: 'ngo-001',
      name: 'Pandharpur Disaster & Crowd Rescue Unit',
      category: NgoServiceCategory.emergency,
      description:
          'Rapid response crowd control, river rescue boats on Chandrabhaga ghats, and high-speed emergency evacuation units.',
      latitude: 17.6705,
      longitude: 75.3210,
      locationName: 'Chandrabhaga Mahaghat Emergency Post',
      capacity: '4 Quick Response Units',
      operatingHours: '24 Hours Open',
      contactPhone: '+91 98230 91199',
      availability: ServiceAvailability.available,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      imageUrl: _demo('emergency-rescue-boat'),
      additionalImageUrls: [
        _demo('rapid-response-team'),
        _demo('life-saving-gear'),
      ],
      emergencySupportAvailable: true,
      ambulanceAvailable: true,
      emergencyContactPhone: '+91 98230 91199',
      ambulanceContactPhone: '+91 98230 99999',
      emergencyInstructions:
          'Direct river rescue and trauma bay connection to Pandharpur Sub-District Hospital.',
      totalAmbulances: 2,
      availableAmbulances: 2,
      onTripAmbulances: 0,
      ambulancesList: const [
        AmbulanceRecord(
          id: 'amb-201',
          vehicleNumber: 'MH-12-RR-0001',
          ambulanceType: 'ALS (Mobile ICU & Oxygen)',
          contactNumber: '+91 98230 91199',
          status: 'Available',
          driverName: 'Kailash Waghmare',
          currentLocation: 'Mahaghat Triage Point',
        ),
      ],
      categoryDetails: const {
        'rescue_teams_count': 2,
        'rescue_boats_count': 4,
        'rescue_equipment': [
          'Inflatable River Boats',
          'High-Power Searchlights',
          'Stretcher Drones',
          'Oxygen Resuscitation Units'
        ],
        'readiness_status': 'Code Green • High Readiness Standby',
      },
      details: const NgoServiceDetails(
        serviceCapacity: '4 Quick Response Units',
        operatingHours: '24 Hours Open',
        isOpen24Hours: true,
      ),
    ),
  ];
}
