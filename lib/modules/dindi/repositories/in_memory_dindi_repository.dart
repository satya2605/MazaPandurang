import '../models/dindi_announcement.dart';
import '../models/dindi_group.dart';
import '../models/dindi_member.dart';
import 'dindi_repository.dart';

/// In-memory implementation of [DindiRepository] with deterministic demo data.
class InMemoryDindiRepository implements DindiRepository {
  static final InMemoryDindiRepository instance =
      InMemoryDindiRepository._internal();

  factory InMemoryDindiRepository() => instance;

  InMemoryDindiRepository._internal() {
    reset();
  }

  final List<DindiGroup> _dindis = [];
  final List<DindiMember> _members = [];
  final List<DindiAnnouncement> _announcements = [];

  List<DindiGroup> get internalDindis => _dindis;
  List<DindiMember> get internalMembers => _members;
  List<DindiAnnouncement> get internalAnnouncements => _announcements;

  void reset() {
    _dindis.clear();
    _members.clear();
    _announcements.clear();

    // ----------------------------------------------------
    // Dindi A (dindi-12): Shree Tukaram Maharaj Dindi
    // ----------------------------------------------------
    _dindis.add(
      const DindiGroup(
        id: 'dindi-12',
        name: 'Shree Tukaram Maharaj Dindi',
        dindiNumber: '12',
        leaderName: 'Sanket Patil',
        leaderPhone: '+91 98220 12345',
        startPoint: 'Dehu',
        destination: 'Pandharpur',
        currentHalt: 'Akurdi Vitthal Mandir',
        roadStatus: 'Clear & Moving',
        joinCode: 'TK12W4',
        leaderUserId: 'leader-sanket-1',
      ),
    );

    // 5 Pending requests for Dindi 12
    _members.addAll([
      DindiMember(
        id: 'p-1',
        dindiId: 'dindi-12',
        name: 'Tukaram Shinde',
        phone: '+91 98221 45678',
        role: 'Taalvadak (टाळकरी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      DindiMember(
        id: 'p-2',
        dindiId: 'dindi-12',
        name: 'Ganesh More',
        phone: '+91 94230 78901',
        role: 'Warkari (वारकरी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      DindiMember(
        id: 'p-3',
        dindiId: 'dindi-12',
        name: 'Ananda Gaikwad',
        phone: '+91 97654 32109',
        role: 'Pakhawaj Player (पखवाज वादक)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      DindiMember(
        id: 'p-4',
        dindiId: 'dindi-12',
        name: 'Sunita Joshi',
        phone: '+91 98901 23456',
        role: 'Sevak (महिला सेवक)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      DindiMember(
        id: 'p-5',
        dindiId: 'dindi-12',
        name: 'Balasaheb Jagtap',
        phone: '+91 91234 56789',
        role: 'Dhwajdhari (ध्वजधारी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);

    // 128 Active members for Dindi 12
    final keyMembers12 = [
      DindiMember(
        id: 'a-1',
        dindiId: 'dindi-12',
        name: 'Ramesh Patil',
        phone: '+91 98222 11111',
        role: 'Veena Carrier (वीणेकरी)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DindiMember(
        id: 'a-2',
        dindiId: 'dindi-12',
        name: 'Suresh Deshmukh',
        phone: '+91 98222 22222',
        role: 'Taalvadak Pramukh (टाळकरी प्रमुख)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DindiMember(
        id: 'a-3',
        dindiId: 'dindi-12',
        name: 'Pandurang Chavan',
        phone: '+91 98222 33333',
        role: 'Annadan Samiti (अन्नदान समिती)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DindiMember(
        id: 'a-4',
        dindiId: 'dindi-12',
        name: 'Vilas Kadam',
        phone: '+91 98222 44444',
        role: 'Medical Volunteer (आरोग्य सेवक)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    _members.addAll(keyMembers12);

    for (int i = 5; i <= 128; i++) {
      _members.add(
        DindiMember(
          id: 'a-$i',
          dindiId: 'dindi-12',
          name: 'Warkari Member $i',
          phone: '+91 98000 ${10000 + i}',
          role: i % 4 == 0 ? 'Dhwajdhari' : 'Warkari',
          status: DindiMemberStatus.approved,
          joinedAt: DateTime.now().subtract(Duration(days: 2, hours: i % 12)),
        ),
      );
    }

    // 2 Announcements for Dindi 12
    _announcements.addAll([
      DindiAnnouncement(
        id: 'ann-1',
        dindiId: 'dindi-12',
        title: 'Prasthan Timing at Akurdi',
        message:
            'All Dindi members must assemble at Akurdi Vitthal Mandir tomorrow morning at 05:30 AM for Kakad Aarti.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isUrgent: true,
      ),
      DindiAnnouncement(
        id: 'ann-2',
        dindiId: 'dindi-12',
        title: 'Mahaprasad Arrangement',
        message:
            'Evening Mahaprasad will be served near the Community Hall by 07:30 PM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isUrgent: false,
      ),
    ]);

    // ----------------------------------------------------
    // Dindi B (dindi-18): Shree Dnyaneshwar Maharaj Dindi No. 18
    // ----------------------------------------------------
    _dindis.add(
      const DindiGroup(
        id: 'dindi-18',
        name: 'Shree Dnyaneshwar Maharaj Dindi No. 18',
        dindiNumber: '18',
        leaderName: 'Sanket Patil',
        leaderPhone: '+91 98220 12345',
        startPoint: 'Alandi',
        destination: 'Pandharpur',
        currentHalt: 'Saswad Sangam',
        roadStatus: 'Slow',
        joinCode: 'DN18W4',
        leaderUserId: 'leader-sanket-1',
      ),
    );

    // 3 Pending requests for Dindi 18
    _members.addAll([
      DindiMember(
        id: 'p-18-1',
        dindiId: 'dindi-18',
        name: 'Dnyandev Salunkhe',
        phone: '+91 98111 22334',
        role: 'Taalvadak (टाळकरी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      DindiMember(
        id: 'p-18-2',
        dindiId: 'dindi-18',
        name: 'Madhukar Rane',
        phone: '+91 98111 44556',
        role: 'Warkari (वारकरी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      DindiMember(
        id: 'p-18-3',
        dindiId: 'dindi-18',
        name: 'Suman Shirole',
        phone: '+91 98111 66778',
        role: 'Sevak (महिला सेवक)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ]);

    // 94 Active members for Dindi 18
    for (int i = 1; i <= 94; i++) {
      _members.add(
        DindiMember(
          id: 'a-18-$i',
          dindiId: 'dindi-18',
          name: i == 1 ? 'Vitthalrao Mahajan' : 'Dnyaneshwar Warkari $i',
          phone: '+91 97000 ${20000 + i}',
          role: i == 1
              ? 'Veena Carrier (वीणेकरी)'
              : (i % 3 == 0 ? 'Dhwajdhari' : 'Warkari'),
          status: DindiMemberStatus.approved,
          joinedAt: DateTime.now().subtract(Duration(days: 3, hours: i % 8)),
        ),
      );
    }

    // 1 Announcement for Dindi 18
    _announcements.add(
      DindiAnnouncement(
        id: 'ann-18-1',
        dindiId: 'dindi-18',
        title: 'Saswad Halt Guidance',
        message:
            'Dindi No. 18 will rest at Saswad Ground. Please keep baggage in designated truck.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isUrgent: false,
      ),
    );
  }

  @override
  Future<List<DindiGroup>> getDindis({String? leaderUserId}) async {
    if (leaderUserId != null) {
      return _dindis.where((d) => d.leaderUserId == leaderUserId).toList();
    }
    return List.unmodifiable(_dindis);
  }

  @override
  Future<DindiGroup?> getDindiById(String id) async {
    final index = _dindis.indexWhere((d) => d.id == id);
    if (index != -1) {
      return _dindis[index];
    }
    return null;
  }

  @override
  Future<DindiGroup> createDindi(DindiGroup dindi) async {
    _dindis.add(dindi);
    return dindi;
  }

  @override
  Future<DindiGroup> updateDindi(DindiGroup dindi) async {
    final index = _dindis.indexWhere((d) => d.id == dindi.id);
    if (index != -1) {
      _dindis[index] = dindi;
      return dindi;
    }
    _dindis.add(dindi);
    return dindi;
  }

  @override
  Future<List<DindiMember>> getMembers(String dindiId) async {
    return _members.where((m) => m.dindiId == dindiId).toList();
  }

  @override
  Future<void> updateMemberStatus(
    String memberId,
    DindiMemberStatus status,
  ) async {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(status: status);
    }
  }

  @override
  Future<void> removeMember(String memberId) async {
    _members.removeWhere((m) => m.id == memberId);
  }

  @override
  Future<List<DindiAnnouncement>> getAnnouncements(String dindiId) async {
    return _announcements.where((a) => a.dindiId == dindiId).toList();
  }

  @override
  Future<void> addAnnouncement(DindiAnnouncement announcement) async {
    _announcements.insert(0, announcement);
  }
}
