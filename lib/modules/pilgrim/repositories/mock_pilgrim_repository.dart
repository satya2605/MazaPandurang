import '../../admin/models/admin_models.dart' show PalkhiHalt;
import '../models/pilgrim_models.dart';
import 'pilgrim_repository.dart';

/// Isolated mock implementation of [PilgrimRepository] for Phase 1.
class MockPilgrimRepository implements PilgrimRepository {
  static const WariLatLng puneLocation = WariLatLng(18.5204, 73.8567);
  static const WariLatLng saswadLocation = WariLatLng(18.3411, 74.0305);
  static const WariLatLng diveGhatLocation = WariLatLng(18.4326, 73.9536);

  static final List<WariLatLng> wariRoute = [
    const WariLatLng(18.5204, 73.8567), // Pune Alandi/Dehu
    const WariLatLng(18.4326, 73.9536), // Dive Ghat
    const WariLatLng(18.3411, 74.0305), // Saswad
    const WariLatLng(18.2755, 74.1593), // Jejuri
    const WariLatLng(18.0371, 74.1925), // Lonand
    const WariLatLng(17.9881, 74.4324), // Phaltan
    const WariLatLng(17.8341, 74.8012), // Malshiras
    const WariLatLng(17.7654, 75.0214), // Velapur
    const WariLatLng(17.6912, 75.2812), // Wakhari
    const WariLatLng(17.6775, 75.3278), // Pandharpur
  ];

  static final PalkhiInfo samplePalkhi = PalkhiInfo(
    palkhiId: 'PLK-001',
    name: 'Sant Dnyaneshwar Maharaj Palkhi',
    saint: 'Sant Dnyaneshwar Maharaj',
    startPoint: 'Alandi',
    destination: 'Pandharpur',
    currentStage: 'Saswad Stay (सासवड मुक्काम)',
    nextStop: 'Jejuri (जेजुरी)',
    currentPosition: saswadLocation,
    routePoints: wariRoute,
    lastUpdated: DateTime.now(),
    halts: const [
      PalkhiHalt(id: 'H1', palkhiId: 'PLK-001', dayNumber: 1, haltDate: '2026-06-18', locationName: 'Alandi Departure', approxLatitude: 18.6772, approxLongitude: 73.8967, nextDestination: 'Pune', expectedArrival: '06:00', expectedDeparture: '10:00'),
      PalkhiHalt(id: 'H2', palkhiId: 'PLK-001', dayNumber: 2, haltDate: '2026-06-19', locationName: 'Pune Stay', approxLatitude: 18.5204, approxLongitude: 73.8567, nextDestination: 'Saswad', expectedArrival: '16:00', expectedDeparture: '08:00'),
      PalkhiHalt(id: 'H3', palkhiId: 'PLK-001', dayNumber: 3, haltDate: '2026-06-20', locationName: 'Saswad Stay', approxLatitude: 18.3411, approxLongitude: 74.0305, nextDestination: 'Jejuri', expectedArrival: '14:00', expectedDeparture: '07:00'),
      PalkhiHalt(id: 'H4', palkhiId: 'PLK-001', dayNumber: 4, haltDate: '2026-06-21', locationName: 'Jejuri', approxLatitude: 18.2764, approxLongitude: 74.1611, nextDestination: 'Lonand', expectedArrival: '13:00', expectedDeparture: '18:00'),
      PalkhiHalt(id: 'H5', palkhiId: 'PLK-001', dayNumber: 5, haltDate: '2026-06-22', locationName: 'Pandharpur Dham', approxLatitude: 17.6777, approxLongitude: 75.3283, nextDestination: 'Pandharpur Temple', expectedArrival: '12:00', expectedDeparture: '20:00'),
    ],
  );

  static final List<PalkhiInfo> samplePalkhis = [
    samplePalkhi,
    PalkhiInfo(
      palkhiId: 'PLK-002',
      name: 'Sant Tukaram Maharaj Palkhi',
      saint: 'Sant Tukaram Maharaj',
      startPoint: 'Dehu',
      destination: 'Pandharpur',
      currentStage: 'Loni Kalbhor Stay (लोणी काळभोर मुक्काम)',
      nextStop: 'Yavat (यवत)',
      currentPosition: const WariLatLng(18.4877, 74.1192),
      routePoints: wariRoute,
      lastUpdated: DateTime.now(),
      halts: const [
        PalkhiHalt(id: 'H21', palkhiId: 'PLK-002', dayNumber: 1, haltDate: '2026-06-18', locationName: 'Dehu Departure', approxLatitude: 18.7183, approxLongitude: 73.7694, nextDestination: 'Akurdi', expectedArrival: '06:00', expectedDeparture: '11:00'),
        PalkhiHalt(id: 'H22', palkhiId: 'PLK-002', dayNumber: 2, haltDate: '2026-06-19', locationName: 'Pune Stay', approxLatitude: 18.5204, approxLongitude: 73.8567, nextDestination: 'Loni Kalbhor', expectedArrival: '15:00', expectedDeparture: '08:00'),
        PalkhiHalt(id: 'H23', palkhiId: 'PLK-002', dayNumber: 3, haltDate: '2026-06-20', locationName: 'Loni Kalbhor', approxLatitude: 18.4877, approxLongitude: 74.1192, nextDestination: 'Yavat', expectedArrival: '14:00', expectedDeparture: '07:00'),
      ],
    ),
  ];

  static final List<DindiMarkerInfo> sampleDindis = [
    const DindiMarkerInfo(
      dindiId: 'DND-001',
      name: 'Dindi No. 1 — Mauli Prasann',
      leaderName: 'Namdev Maharaj',
      memberCount: 350,
      position: WariLatLng(18.3430, 74.0290),
      currentStatus: 'Resting near Palkhi Talao',
    ),
    const DindiMarkerInfo(
      dindiId: 'DND-012',
      name: 'Dindi No. 12 — Gyanoba Tukaram',
      leaderName: 'Sopandev Varkari',
      memberCount: 220,
      position: WariLatLng(18.3490, 74.0250),
      currentStatus: 'Moving towards Saswad temple',
    ),
    const DindiMarkerInfo(
      dindiId: 'DND-024',
      name: 'Dindi No. 24 — Vitthal Rukmini Seva',
      leaderName: 'Eknath Gaikwad',
      memberCount: 180,
      position: WariLatLng(18.3370, 74.0320),
      currentStatus: 'Breakfast distribution camp',
    ),
  ];

  static final List<WariService> sampleServices = [
    const WariService(
      serviceId: 'SRV-MED-001',
      name: 'Saswad Central Medical Camp',
      category: ServiceCategory.medical,
      position: WariLatLng(18.3415, 74.0310),
      address: 'Near Saswad Bus Stand Ground',
      availabilityStatus: 'Open 24/7 (Available)',
      description:
          'First aid, emergency doctors, ambulances, and free medicines.',
      contactPhone: '+91 98765 43210',
      isVerified: true,
    ),
    const WariService(
      serviceId: 'SRV-WTR-002',
      name: 'Clean Jal Seva Tank 1',
      category: ServiceCategory.water,
      position: WariLatLng(18.3422, 74.0285),
      address: 'Dive Ghat Exit Point',
      availabilityStatus: 'Abundant Supply',
      description: 'Filtered cold drinking water and water pouch distribution.',
      contactPhone: '+91 98220 11223',
      isVerified: true,
    ),
    const WariService(
      serviceId: 'SRV-FOD-003',
      name: 'Mahaprasad Annachhatra',
      category: ServiceCategory.food,
      position: WariLatLng(18.3400, 74.0330),
      address: 'Vitthal Mandir Premises',
      availabilityStatus: 'Serving Hot Food',
      description:
          'Free nutritious Sabudana Khichdi, Poori Bhaji, and Tea for all Warkaris.',
      contactPhone: '+91 94230 55667',
      isVerified: true,
    ),
    const WariService(
      serviceId: 'SRV-TLT-004',
      name: 'Mobile Bio-Toilets Complex',
      category: ServiceCategory.toilet,
      position: WariLatLng(18.3385, 74.0270),
      address: 'Saswad Bypass Road',
      availabilityStatus: 'Clean & Functional',
      description:
          '50 separate mobile toilets for men and women with washing area.',
      contactPhone: 'N/A',
      isVerified: true,
    ),
    const WariService(
      serviceId: 'SRV-SHL-005',
      name: 'Warkari Night Shelter Mandap',
      category: ServiceCategory.shelter,
      position: WariLatLng(18.3450, 74.0340),
      address: 'Zilla Parishad School Ground',
      availabilityStatus: '80% Occupied',
      description:
          'Waterproof carpeted tents with mobile charging points and blankets.',
      contactPhone: '+91 98900 88776',
      isVerified: true,
    ),
    const WariService(
      serviceId: 'SRV-PLC-006',
      name: 'Police Assistance & Lost Person Booth',
      category: ServiceCategory.police,
      position: WariLatLng(18.3410, 74.0300),
      address: 'Chhatrapati Shivaji Chowk',
      availabilityStatus: 'Active Helpdesk',
      description:
          'Route information, lost & found announcements, and security help.',
      contactPhone: '112 / +91 02115 222100',
      isVerified: true,
    ),
    const WariService(
      serviceId: 'SRV-NGO-007',
      name: 'Foot Massage & Medical Seva Camp',
      category: ServiceCategory.ngo,
      position: WariLatLng(18.3435, 74.0325),
      address: 'Opposite Government Hospital',
      availabilityStatus: 'Volunteers Active',
      description:
          'Free herbal foot massage, pain relief sprays, and bandage distribution.',
      contactPhone: '+91 97654 32109',
      isVerified: true,
    ),
  ];

  static final List<BhaktiMediaItem> sampleBhaktiContent = [
    const BhaktiMediaItem(
      id: 'BHK-001',
      title: 'Majha Pandurang Abhang Gatha',
      marathiTitle: 'माझा पांडुरंग अभंग गाथा',
      artist: 'Pandit Bhimsen Joshi',
      category: 'Abhang',
      duration: '14:20',
      thumbnailUrl: 'https://example.com/thumb1.jpg',
      streamUrl: 'https://example.com/audio1.mp3',
    ),
    const BhaktiMediaItem(
      id: 'BHK-002',
      title: 'Alandi Te Pandharpur Wari Songs',
      marathiTitle: 'आळंदी ते पंढरपूर वारी गीते',
      artist: 'Ajit Kadkade',
      category: 'Featured',
      duration: '22:15',
      thumbnailUrl: 'https://example.com/thumb2.jpg',
      streamUrl: 'https://example.com/audio2.mp3',
    ),
    const BhaktiMediaItem(
      id: 'BHK-003',
      title: 'Dnyaneshwar Maharaj Haripath',
      marathiTitle: 'ज्ञानेश्वर महाराज हरिपाठ',
      artist: 'Prahlad Shinde',
      category: 'Kirtan',
      duration: '35:40',
      thumbnailUrl: 'https://example.com/thumb3.jpg',
      streamUrl: 'https://example.com/audio3.mp3',
    ),
    const BhaktiMediaItem(
      id: 'BHK-004',
      title: 'Gyanoba Mauli Tukaram Chants',
      marathiTitle: 'ज्ञानोबा माऊली तुकाराम नामजप',
      artist: 'Warkari Bhajan Vrinda',
      category: 'Bhajans',
      duration: '18:50',
      thumbnailUrl: 'https://example.com/thumb4.jpg',
      streamUrl: 'https://example.com/audio4.mp3',
    ),
    const BhaktiMediaItem(
      id: 'BHK-005',
      title: 'Ringan Ceremony Highlights Video',
      marathiTitle: 'रिंगण सोहळा व्हिडिओ',
      artist: 'Wari Live Broadcast',
      category: 'Videos',
      duration: '08:45',
      thumbnailUrl: 'https://example.com/thumb5.jpg',
      streamUrl: 'https://example.com/video1.mp4',
    ),
  ];

  @override
  Future<PilgrimLocation> getCurrentUserLocation() async {
    return PilgrimLocation(
      pilgrimId: 'PLG-DEMO',
      name: 'Varkari Pilgrim',
      position: diveGhatLocation,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<PalkhiInfo> getPalkhiInfo() async {
    return samplePalkhi;
  }

  @override
  Future<List<PalkhiInfo>> getPalkhiList() async {
    return samplePalkhis;
  }

  @override
  Future<List<DindiMarkerInfo>> getNearbyDindis() async {
    return sampleDindis;
  }

  @override
  Future<List<WariService>> getServices({ServiceCategory? category}) async {
    if (category == null) return sampleServices;
    return sampleServices.where((s) => s.category == category).toList();
  }

  @override
  Future<WariService?> getServiceById(String serviceId) async {
    try {
      return sampleServices.firstWhere((s) => s.serviceId == serviceId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WariRouteStage>> getWariRoute() async {
    return const [
      WariRouteStage(
          id: '1',
          stageName: 'Alandi (आळंदी)',
          sequenceOrder: 1,
          position: WariLatLng(18.6772, 73.8967)),
      WariRouteStage(
          id: '2',
          stageName: 'Pune Stay (पुणे मुक्काम)',
          sequenceOrder: 2,
          position: WariLatLng(18.5204, 73.8567)),
      WariRouteStage(
          id: '3',
          stageName: 'Dive Ghat (दिवे घाट)',
          sequenceOrder: 3,
          position: WariLatLng(18.4100, 73.9700)),
      WariRouteStage(
          id: '4',
          stageName: 'Saswad Stay (सासवड मुक्काम)',
          sequenceOrder: 4,
          position: WariLatLng(18.3411, 74.0305)),
      WariRouteStage(
          id: '5',
          stageName: 'Jejuri (जेजुरी)',
          sequenceOrder: 5,
          position: WariLatLng(18.2764, 74.1611)),
      WariRouteStage(
          id: '6',
          stageName: 'Lonand (लोणंद)',
          sequenceOrder: 6,
          position: WariLatLng(18.0415, 74.1906)),
      WariRouteStage(
          id: '7',
          stageName: 'Phaltan (फलटण)',
          sequenceOrder: 7,
          position: WariLatLng(17.9877, 74.4312)),
      WariRouteStage(
          id: '8',
          stageName: 'Pandharpur (पंढरपूर धाम)',
          sequenceOrder: 8,
          position: WariLatLng(17.6777, 75.3283)),
    ];
  }

  @override
  Future<List<BhaktiMediaItem>> getBhaktiContent({String? category}) async {
    if (category == null || category == 'Featured') return sampleBhaktiContent;
    return sampleBhaktiContent.where((b) => b.category == category).toList();
  }

  @override
  Future<DindiDetail?> getDindiById(String id) async {
    return DindiDetail(
      id: id,
      dindiNumber: 'DND-001',
      name: 'Dindi No. 1 — Mauli Prasann',
      leaderId: '00000000-0000-0000-0000-000000000002',
      leaderName: 'Namdev Maharaj',
      leaderPhone: '+91 98765 43211',
      memberCount: 350,
      currentLocationName: 'Saswad Stay',
      position: const WariLatLng(18.3430, 74.0290),
      status: 'Active',
      startPoint: 'Alandi',
      destination: 'Pandharpur',
      currentHalt: 'Palkhi Talao Ground',
      roadStatus: 'clear',
      joinCode: 'DND101',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDindiMembers(String id) async {
    return const [
      {'id': 'MBR-1', 'display_name': 'Sopandev Varkari', 'role': 'member'},
      {'id': 'MBR-2', 'display_name': 'Santosh Gaikwad', 'role': 'member'},
    ];
  }

  @override
  Future<bool> joinDindi(String dindiId, {String? notes}) async {
    return true;
  }

  @override
  Future<List<CityPlace>> getCityPlaces() async {
    return const [
      CityPlace(
        id: 'PLC-1',
        name: 'Vitthal Mandir Premises',
        placeType: 'temple',
        position: WariLatLng(18.3400, 74.0330),
        description: 'Historic Mandir halt location in Saswad.',
      ),
    ];
  }

  @override
  Future<List<CityRoute>> getCityRoutes() async {
    return const [
      CityRoute(
        id: 'RTE-1',
        name: 'Dive Ghat Main Bypass',
        routeType: 'palkhi_route',
        status: 'open',
        description: 'Palkhi primary walking procession route.',
      ),
    ];
  }

  @override
  Future<DonationsInfo?> getDonationsInfo() async {
    return const DonationsInfo(
      bankName: 'State Bank of India',
      accountNumber: '34567890123',
      ifscCode: 'SBIN0001234',
      upiId: 'pandharpur@upi',
      trustName: 'Shree Vitthal Rukmini Mandir Samiti',
      notes: 'Direct donations to support Warkari water and food distribution camps.',
    );
  }

  @override
  Future<List<LostPersonReport>> getLostPersons() async {
    return const [
      LostPersonReport(
        id: 'LST-1',
        fullName: 'Ramrao Jadhav',
        age: 68,
        gender: 'Male',
        photoUrl: '',
        lastSeenLocation: 'Dive Ghat Top',
        position: WariLatLng(18.4326, 73.9536),
        contactPhone: '+91 98765 00000',
        status: 'missing',
      ),
    ];
  }

  @override
  Future<bool> reportLostPersonSighting(String lostPersonId, {required double latitude, required double longitude, required String locationName, String? details}) async {
    return true;
  }

  @override
  Future<List<LostPersonSighting>> getLostPersonSightings(String lostPersonId) async {
    return [
      LostPersonSighting(
        id: 'SGT-1',
        lostPersonId: lostPersonId,
        locationName: 'Saswad Bus Stand',
        position: const WariLatLng(18.3415, 74.0310),
        details: 'Spotted resting at medical camp.',
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<bool> reportEmergency({required String emergencyType, required double latitude, required double longitude, String? description}) async {
    return true;
  }

  final List<EmergencyRequest> _mockEmergencies = [
    EmergencyRequest(
      id: 'EMG-001',
      requestCode: 'EMG-1001',
      requesterId: '00000000-0000-0000-0000-000000000001',
      emergencyType: 'Medical',
      position: const WariLatLng(18.3411, 74.0305),
      locationName: 'Saswad Medical Desk',
      description: 'Dehydration & heat stroke assistance',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  @override
  Future<EmergencyRequest> createEmergencyRequest({
    required String emergencyType,
    required double latitude,
    required double longitude,
    String? locationName,
    String? description,
  }) async {
    final req = EmergencyRequest(
      id: 'EMG-${DateTime.now().millisecondsSinceEpoch}',
      requestCode: 'EMG-${DateTime.now().millisecondsSinceEpoch}',
      requesterId: '00000000-0000-0000-0000-000000000001',
      emergencyType: emergencyType,
      position: WariLatLng(latitude, longitude),
      locationName: locationName ?? 'Wari Location',
      description: description ?? '',
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _mockEmergencies.insert(0, req);
    return req;
  }

  @override
  Future<List<EmergencyRequest>> getEmergencyRequests() async {
    return List.unmodifiable(_mockEmergencies);
  }

  @override
  Future<TilakChatMessage> queryTilakAI(String prompt) async {
    final lower = prompt.toLowerCase();
    String answer;
    String? targetRoute;
    String? actionText;
    List<TilakAction> actions = [];

    if (lower.contains('palkhi') ||
        lower.contains('location') ||
        lower.contains('पालखी') ||
        lower.contains('स्थान')) {
      answer =
          'राम कृष्ण हरी! 🚩 Sant Dnyaneshwar Maharaj Palkhi (पालखी) सध्या सासवड मुक्काम (Saswad Stay) येथे आहे. पुढील टप्पा: जेजुरी.';
      actions = [
        const TilakAction(
          type: 'directions',
          id: 'PLK-001',
          label: '🧭 Start Navigation to Palkhi (0.2 km)',
          targetRoute: '/map?lat=18.3411&lng=74.0305&title=Sant%20Dnyaneshwar%20Maharaj%20Palkhi',
          latitude: 18.3411,
          longitude: 74.0305,
          title: 'Sant Dnyaneshwar Maharaj Palkhi',
        ),
      ];
    } else if (lower.contains('medical') ||
        lower.contains('doctor') ||
        lower.contains('वैद्यकीय') ||
        lower.contains('औषध')) {
      answer =
          'राम कृष्ण हरी! 🚩 सासवड मध्यवर्ती केंद्रापासून (Saswad Center) सर्वात जवळील वैद्यकीय केंद्र (Medical Camp):\n\n📍 "Saswad Central Medical Camp"\n• अंतर: 0.2 किमी (Saswad Bus Stand)\n• स्थिती: Open 24/7\n\nथेट मार्ग शोधण्यासाठी खालील बटणावर क्लिक करा.';
      actions = [
        const TilakAction(
          type: 'directions',
          id: 'SRV-MED-001',
          label: '🧭 Start Navigation (Saswad Central Medical Camp)',
          targetRoute: '/map?lat=18.3430&lng=74.0320&title=Saswad%20Central%20Medical%20Camp',
          latitude: 18.3430,
          longitude: 74.0320,
          title: 'Saswad Central Medical Camp',
        ),
      ];
    } else if (lower.contains('dindi') || lower.contains('दिंडी')) {
      answer =
          'राम कृष्ण हरी! 🚩 सासवड येथे जवळील नोंदणीकृत दिंडी (Dindi): माउली प्रसन्न दिंडी क्र. १ (सासवड मुक्काम).';
      targetRoute = '/dindi';
      actionText = 'View Nearby Dindis';
    } else if (lower.contains('water') ||
        lower.contains('पाणी') ||
        lower.contains('जल')) {
      answer =
          'राम कृष्ण हरी! 🚩 सासवड मध्यवर्ती केंद्रापासून (Saswad Center) सर्वात जवळील पिण्याचे पाणी केंद्र (Jal Seva Tank):\n\n📍 "Saswad Palkhi Water Camp"\n• अंतर: 0.1 किमी (Saswad Main Road)\n• स्थिती: Available\n\nथेट मार्ग शोधण्यासाठी खालील बटणावर क्लिक करा.';
      actions = [
        const TilakAction(
          type: 'directions',
          id: 'SRV-WTR-002',
          label: '🧭 Start Navigation (Saswad Palkhi Water Camp)',
          targetRoute: '/map?lat=18.3420&lng=74.0310&title=Saswad%20Palkhi%20Water%20Camp',
          latitude: 18.3420,
          longitude: 74.0310,
          title: 'Saswad Palkhi Water Camp',
        ),
      ];
    } else {
      answer =
          'राम कृष्ण हरी! 🚩 मी तिलक, आपला वारी मार्गदर्शक आहे. सासवड मध्यवर्ती केंद्रावरून पिण्याचे पाणी, वैद्यकीय मदत, पालखी स्थान किंवा अन्नछत्राची माहिती आणि नेव्हिगेशन मिळवण्यासाठी विचारू शकता.';
    }

    return TilakChatMessage(
      id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
      text: answer,
      isUser: false,
      timestamp: DateTime.now(),
      actions: actions,
      targetRoute: targetRoute,
      suggestedActionText: actionText,
    );
  }

  @override
  Future<List<TrafficAlert>> getTrafficAlerts() async {
    return [
      TrafficAlert(
        id: 'TRF-001',
        alertCode: 'TRF-DIVE-01',
        title: 'Dive Ghat Heavy Crowd Slowdown',
        description: 'Procession move speed slow near Dive Ghat hairpins. Heavy pedestrian crowd.',
        type: 'CROWD_DENSITY',
        severity: 'HIGH',
        status: 'ACTIVE',
        position: const WariLatLng(18.4100, 73.9700),
        createdBy: 'POLICE-ADMIN',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      TrafficAlert(
        id: 'TRF-002',
        alertCode: 'TRF-SASWAD-02',
        title: 'Saswad Ring Road Diversion',
        description: 'Vehicular traffic diverted via Saswad Bypass for Palkhi arrival.',
        type: 'DIVERSION',
        severity: 'MEDIUM',
        status: 'ACTIVE',
        position: const WariLatLng(18.3411, 74.0305),
        createdBy: 'TRAFFIC-CELL',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  Future<String?> transcribeAudio(List<int> audioBytes) async {
    return 'ज्ञानेश्वर माऊलींची पालखी सध्या कुठे आहे?';
  }

  @override
  Future<String?> synthesizeTTS(String text) async {
    return 'UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=';
  }
}

