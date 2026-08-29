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
      description: 'First aid, emergency doctors, ambulances, and free medicines.',
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
      description: 'Free nutritious Sabudana Khichdi, Poori Bhaji, and Tea for all Warkaris.',
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
      description: '50 separate mobile toilets for men and women with washing area.',
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
      description: 'Waterproof carpeted tents with mobile charging points and blankets.',
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
      description: 'Route information, lost & found announcements, and security help.',
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
      description: 'Free herbal foot massage, pain relief sprays, and bandage distribution.',
      contactPhone: '+91 97654 32109',
      isVerified: true,
    ),
  ];

  static final List<BhaktiMediaItem> sampleBhaktiContent = [
    const BhaktiMediaItem(
      id: 'YTB-sHVUlXAvCd0',
      youtubeVideoId: 'sHVUlXAvCd0',
      category: 'Vitthal Bhajans',
      title: '''Deh Vitthal (Song) | देह विठ्ठल | Avadhoot Gandhi, Prasad Prabhakar Shinde | WARI - वारी 2024''',
      thumbnailUrl: 'https://i.ytimg.com/vi/sHVUlXAvCd0/hqdefault.jpg',
      channelTitle: '''Panorama Music Marathi''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-wgCPZtfj3lY',
      youtubeVideoId: 'wgCPZtfj3lY',
      category: 'Vitthal Bhajans',
      title: '''🌺श्री विठ्ठलाचे अप्रतिम भजन🚩पांडुरंगाचे मनमोहक भजन#स्वरसाई #vitthalbhajanmarathi #विठ्ठलभजन #bhajan''',
      thumbnailUrl: 'https://i.ytimg.com/vi/wgCPZtfj3lY/hqdefault.jpg',
      channelTitle: '''स्वर साई''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-c25qRXGcuXM',
      youtubeVideoId: 'c25qRXGcuXM',
      category: 'Vitthal Bhajans',
      title: '''Top 15 सकाळचे भक्ती गीते विठ्ठल भक्तिगीते | Vitthal Bhaktigeete |  Vitthal Song Marathi''',
      thumbnailUrl: 'https://i.ytimg.com/vi/c25qRXGcuXM/hqdefault_live.jpg',
      channelTitle: '''Wings Ganesh Bhakti''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-sqrew1ABIC4',
      youtubeVideoId: 'sqrew1ABIC4',
      category: 'Vitthal Bhajans',
      title: '''Bolava Vitthal Pahava Vitthal बोलावा विठ्ठल पहावा विठ्ठल मराठी अभंग | भजन | Ketakee Mateygaonkar''',
      thumbnailUrl: 'https://i.ytimg.com/vi/sqrew1ABIC4/hqdefault.jpg',
      channelTitle: '''Ketakee Mateygaonkar''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-yltBOtKSG1Y',
      youtubeVideoId: 'yltBOtKSG1Y',
      category: 'Vitthal Bhajans',
      title: '''Top 12 Pralhad Shinde Special विठ्ठलाची भक्तिगीते | Pralhad Shinde Vitthal Song | मागतो मी पांडुरंगा''',
      thumbnailUrl: 'https://i.ytimg.com/vi/yltBOtKSG1Y/hqdefault.jpg',
      channelTitle: '''Wings Marathi Bhakti''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-_Y8NyXUSzDI',
      youtubeVideoId: '_Y8NyXUSzDI',
      category: 'Abhang',
      title: '''विठ्ठल पाहूणा आला माझ्या घरा  Vitthal Pahuna Aala Majhya Ghara | Sant Tukaram Maharaj Vitthal Abhang''',
      thumbnailUrl: 'https://i.ytimg.com/vi/_Y8NyXUSzDI/hqdefault.jpg',
      channelTitle: '''Vision Bhakti Marathi''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-qxpucRQFgGc',
      youtubeVideoId: 'qxpucRQFgGc',
      category: 'Abhang',
      title: '''संत मुक्ताबाई अभंग : आकाशीचा चंद्र शोभे माझ्या अंगणात | Aakashicha Chandra Shobhe | Vitthal Abhang''',
      thumbnailUrl: 'https://i.ytimg.com/vi/qxpucRQFgGc/hqdefault.jpg',
      channelTitle: '''Vitthal Bhakti - अभंग विठ्ठलाचे''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-hfwfL6MFLCo',
      youtubeVideoId: 'hfwfL6MFLCo',
      category: 'Abhang',
      title: '''प्रचंड गाजलेले अभंग | विठ्ठलाची गाणी | विठ्ठलाची भक्तीगीते | Vitthal Abhang | Vitthal Songs Marathi''',
      thumbnailUrl: 'https://i.ytimg.com/vi/hfwfL6MFLCo/hqdefault.jpg',
      channelTitle: '''Vitthal Bhakti - अभंग विठ्ठलाचे''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-sHVUlXAvCd0',
      youtubeVideoId: 'sHVUlXAvCd0',
      category: 'Abhang',
      title: '''Deh Vitthal (Song) | देह विठ्ठल | Avadhoot Gandhi, Prasad Prabhakar Shinde | WARI - वारी 2024''',
      thumbnailUrl: 'https://i.ytimg.com/vi/sHVUlXAvCd0/hqdefault.jpg',
      channelTitle: '''Panorama Music Marathi''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-sqrew1ABIC4',
      youtubeVideoId: 'sqrew1ABIC4',
      category: 'Abhang',
      title: '''Bolava Vitthal Pahava Vitthal बोलावा विठ्ठल पहावा विठ्ठल मराठी अभंग | भजन | Ketakee Mateygaonkar''',
      thumbnailUrl: 'https://i.ytimg.com/vi/sqrew1ABIC4/hqdefault.jpg',
      channelTitle: '''Ketakee Mateygaonkar''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-p0_AiK8Xxj0',
      youtubeVideoId: 'p0_AiK8Xxj0',
      category: 'Wari Songs',
      title: '''Pandharichi Wari (पंढरीची वारी जयाचिये कुळीं )''',
      thumbnailUrl: 'https://i.ytimg.com/vi/p0_AiK8Xxj0/hqdefault.jpg',
      channelTitle: '''amitpune1''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-sHVUlXAvCd0',
      youtubeVideoId: 'sHVUlXAvCd0',
      category: 'Wari Songs',
      title: '''Deh Vitthal (Song) | देह विठ्ठल | Avadhoot Gandhi, Prasad Prabhakar Shinde | WARI - वारी 2024''',
      thumbnailUrl: 'https://i.ytimg.com/vi/sHVUlXAvCd0/hqdefault.jpg',
      channelTitle: '''Panorama Music Marathi''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-iMKoY1xJD2U',
      youtubeVideoId: 'iMKoY1xJD2U',
      category: 'Wari Songs',
      title: '''Bhakta Pundalika Saathi Ubha Rahila Vithevari - Shri Vitthal Bhakti Geet - Sumeet Music''',
      thumbnailUrl: 'https://i.ytimg.com/vi/iMKoY1xJD2U/hqdefault.jpg',
      channelTitle: '''Sumeet Music''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-5BTqInkHiI4',
      youtubeVideoId: '5BTqInkHiI4',
      category: 'Wari Songs',
      title: '''Pandharpurat Kay Vajat Gajat - Vitthal Songs Marathi विठ्ठलाची गाणी | Sonyach Bashing Lagin Devach''',
      thumbnailUrl: 'https://i.ytimg.com/vi/5BTqInkHiI4/hqdefault.jpg',
      channelTitle: '''Nova Marathi Bhakti''',
    ),
    const BhaktiMediaItem(
      id: 'YTB--ovKz1RtjBo',
      youtubeVideoId: '-ovKz1RtjBo',
      category: 'Wari Songs',
      title: '''Dharila Pandharicha Chor Anuradha Paudwal Superhit Song | धरिला पंढरीचा चोर | Pandharichi Vari |''',
      thumbnailUrl: 'https://i.ytimg.com/vi/-ovKz1RtjBo/hqdefault.jpg',
      channelTitle: '''Rajshree Marathibana''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-0vGoZrDKtsg',
      youtubeVideoId: '0vGoZrDKtsg',
      category: 'Aarti',
      title: '''Vitthal Aarti | विठ्ठलाची आरती | Kanadau Vitthalu | Sagarika Bhakati''',
      thumbnailUrl: 'https://i.ytimg.com/vi/0vGoZrDKtsg/hqdefault.jpg',
      channelTitle: '''Sagarika Devotional''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-tgvr9u6mvs0',
      youtubeVideoId: 'tgvr9u6mvs0',
      category: 'Aarti',
      title: '''Yuge Atthavis - Vitthal Aarti BY Anuradha Paudwal - Marathi Aarti | आषाढ़ी एकादशी''',
      thumbnailUrl: 'https://i.ytimg.com/vi/tgvr9u6mvs0/hqdefault.jpg',
      channelTitle: '''T-Series Bhakti Marathi''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-8O7FU5KD5bE',
      youtubeVideoId: '8O7FU5KD5bE',
      category: 'Aarti',
      title: '''Yei O Vitthale Maze Mauli Ye | Vitthal Aarti | Marathi Devotional Song | Ashadhi Ekadashi Special''',
      thumbnailUrl: 'https://i.ytimg.com/vi/8O7FU5KD5bE/hqdefault.jpg',
      channelTitle: '''Rajshri Soul''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-rahKfNNp2FI',
      youtubeVideoId: 'rahKfNNp2FI',
      category: 'Aarti',
      title: '''Yuge Atthavis Vitthala Aarti | Ashadhi Ekadashi Special | | युगे अठ्ठावीस आरती | Rajshri Soul''',
      thumbnailUrl: 'https://i.ytimg.com/vi/rahKfNNp2FI/hqdefault.jpg',
      channelTitle: '''Rajshri Soul''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-IZalBEAg5Ng',
      youtubeVideoId: 'IZalBEAg5Ng',
      category: 'Aarti',
      title: '''श्री विठ्ठलाची आरती | विठ्ठल रखुमाई आरती | संपूर्ण आरती | आषाढी एकादशी विशेष | Vitthal Aarti''',
      thumbnailUrl: 'https://i.ytimg.com/vi/IZalBEAg5Ng/hqdefault.jpg',
      channelTitle: '''DivineEchoVibrations by SaRanga''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-WZFiFlaHnAI',
      youtubeVideoId: 'WZFiFlaHnAI',
      category: 'Pandurang',
      title: '''विठ्ठल भक्तीगीते | विठू माऊली तू माऊली जगाची : Vithu Mauli Tu Mauli Jagachi | Vitthal Songs Marathi''',
      thumbnailUrl: 'https://i.ytimg.com/vi/WZFiFlaHnAI/hqdefault.jpg',
      channelTitle: '''माझी मराठी गाणी''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-EpWxm_eXdE0',
      youtubeVideoId: 'EpWxm_eXdE0',
      category: 'Pandurang',
      title: '''Dhavuni Ye Vitthala Satwari - Shree Vitthal Bhaktigeet Vithalachi Gani- Sumeet Music''',
      thumbnailUrl: 'https://i.ytimg.com/vi/EpWxm_eXdE0/hqdefault.jpg',
      channelTitle: '''Sumeet Music''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-_Y8NyXUSzDI',
      youtubeVideoId: '_Y8NyXUSzDI',
      category: 'Pandurang',
      title: '''विठ्ठल पाहूणा आला माझ्या घरा  Vitthal Pahuna Aala Majhya Ghara | Sant Tukaram Maharaj Vitthal Abhang''',
      thumbnailUrl: 'https://i.ytimg.com/vi/_Y8NyXUSzDI/hqdefault.jpg',
      channelTitle: '''Vision Bhakti Marathi''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-uj2QKZ7uj94',
      youtubeVideoId: 'uj2QKZ7uj94',
      category: 'Pandurang',
      title: '''भक्त पुंडलिकासाठी#विठ्ठल भजन# पांडुरंग भजन#हरी भजन# Vitthal bhajan#Pandurang bhajan#''',
      thumbnailUrl: 'https://i.ytimg.com/vi/uj2QKZ7uj94/hqdefault.jpg',
      channelTitle: '''आपली आदर्श आई''',
    ),
    const BhaktiMediaItem(
      id: 'YTB-sqrew1ABIC4',
      youtubeVideoId: 'sqrew1ABIC4',
      category: 'Pandurang',
      title: '''Bolava Vitthal Pahava Vitthal बोलावा विठ्ठल पहावा विठ्ठल मराठी अभंग | भजन | Ketakee Mateygaonkar''',
      thumbnailUrl: 'https://i.ytimg.com/vi/sqrew1ABIC4/hqdefault.jpg',
      channelTitle: '''Ketakee Mateygaonkar''',
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
  Future<List<BhaktiMediaItem>> getBhaktiContent({String? category}) async {
    if (category == null || category == 'Featured') return sampleBhaktiContent;
    return sampleBhaktiContent.where((b) => b.category == category).toList();
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
      answer = 'Sant Dnyaneshwar Maharaj Palkhi is currently at Saswad (सासवड मुक्काम). The next stop is Jejuri.';
      targetRoute = '/palkhi';
      actionText = 'View Palkhi Route';
    } else if (lower.contains('medical') ||
        lower.contains('doctor') ||
        lower.contains('औषध')) {
      answer = 'The nearest medical facility is Saswad Central Medical Camp (SRV-MED-001) near Saswad Bus Stand. Open 24/7.';
      targetRoute = '/services';
      actionText = 'Show Medical Camps';
    } else if (lower.contains('dindi') || lower.contains('दिंडी')) {
      answer = 'You are currently near Dindi No. 1 (Mauli Prasann) and Dindi No. 12 (Gyanoba Tukaram).';
      targetRoute = '/dindi';
      actionText = 'View Nearby Dindis';
    } else if (lower.contains('water') ||
        lower.contains('पानी') ||
        lower.contains('जल')) {
      answer = 'Clean Jal Seva Tank 1 (SRV-WTR-002) is located at the Dive Ghat Exit Point.';
      targetRoute = '/services';
      actionText = 'Locate Water Points';
    } else {
      answer = 'Jay Jay Ram Krishna Hari! I am Tilak, your Wari AI guide. How can I help you navigate services, Palkhi locations, or emergency assistance today?';
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
