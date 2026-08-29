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
    currentStage: 'Saswad Stay (सासवड मुक्काम)',
    nextStop: 'Jejuri (जेजुरी)',
    currentPosition: saswadLocation,
    routePoints: wariRoute,
    lastUpdated: DateTime.now(),
  );

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

  @override
  Future<TilakChatMessage> queryTilakAI(String prompt) async {
    final lower = prompt.toLowerCase();
    String answer;
    String? targetRoute;
    String? actionText;

    if (lower.contains('palkhi') ||
        lower.contains('location') ||
        lower.contains('स्थान')) {
      answer =
          'Sant Dnyaneshwar Maharaj Palkhi is currently at Saswad (सासवड मुक्काम). The next stop is Jejuri.';
      targetRoute = '/palkhi';
      actionText = 'View Palkhi Route';
    } else if (lower.contains('medical') ||
        lower.contains('doctor') ||
        lower.contains('औषध')) {
      answer =
          'The nearest medical facility is Saswad Central Medical Camp (SRV-MED-001) near Saswad Bus Stand. Open 24/7.';
      targetRoute = '/services';
      actionText = 'Show Medical Camps';
    } else if (lower.contains('dindi') || lower.contains('दिंडी')) {
      answer =
          'You are currently near Dindi No. 1 (Mauli Prasann) and Dindi No. 12 (Gyanoba Tukaram).';
      targetRoute = '/dindi';
      actionText = 'View Nearby Dindis';
    } else if (lower.contains('water') ||
        lower.contains('पानी') ||
        lower.contains('जल')) {
      answer =
          'Clean Jal Seva Tank 1 (SRV-WTR-002) is located at the Dive Ghat Exit Point.';
      targetRoute = '/services';
      actionText = 'Locate Water Points';
    } else {
      answer =
          'Jay Jay Ram Krishna Hari! I am Tilak, your Wari AI guide. How can I help you navigate services, Palkhi locations, or emergency assistance today?';
    }

    return TilakChatMessage(
      id: 'MSG-${DateTime.now().millisecondsSinceEpoch}',
      text: answer,
      isUser: false,
      timestamp: DateTime.now(),
      targetRoute: targetRoute,
      suggestedActionText: actionText,
    );
  }
}

