import 'package:flutter/foundation.dart';
import '../models/dindi_group.dart';
import '../models/dindi_member.dart';
import '../models/dindi_announcement.dart';

/// In-memory state service for the Dindi Leader module.
class DindiStateService extends ChangeNotifier {
  static final DindiStateService _instance = DindiStateService._internal();

  factory DindiStateService() => _instance;

  DindiStateService._internal() {
    _initDemoData();
  }

  late DindiGroup _dindiGroup;
  final List<DindiMember> _members = [];
  final List<DindiAnnouncement> _announcements = [];

  DindiGroup get dindiGroup => _dindiGroup;
  List<DindiMember> get members => List.unmodifiable(_members);
  List<DindiAnnouncement> get announcements =>
      List.unmodifiable(_announcements);

  List<DindiMember> get activeMembers =>
      _members.where((m) => m.status == DindiMemberStatus.approved).toList();

  List<DindiMember> get pendingMembers =>
      _members.where((m) => m.status == DindiMemberStatus.pending).toList();

  int get totalMemberCount => activeMembers.length;
  int get pendingRequestCount => pendingMembers.length;

  void _initDemoData() {
    _dindiGroup = const DindiGroup(
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
    );

    _members.clear();

    // 5 Pending requests
    _members.addAll([
      DindiMember(
        id: 'p-1',
        name: 'Tukaram Shinde',
        phone: '+91 98221 45678',
        role: 'Taalvadak (टाळकरी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      DindiMember(
        id: 'p-2',
        name: 'Ganesh More',
        phone: '+91 94230 78901',
        role: 'Warkari (वारकरी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      DindiMember(
        id: 'p-3',
        name: 'Ananda Gaikwad',
        phone: '+91 97654 32109',
        role: 'Pakhawaj Player (पखवाज वादक)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      DindiMember(
        id: 'p-4',
        name: 'Sunita Joshi',
        phone: '+91 98901 23456',
        role: 'Sevak (महिला सेवक)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      DindiMember(
        id: 'p-5',
        name: 'Balasaheb Jagtap',
        phone: '+91 91234 56789',
        role: 'Dhwajdhari (ध्वजधारी)',
        status: DindiMemberStatus.pending,
        joinedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);

    // 128 Active approved members (representing realistic headcount)
    final keyMembers = [
      DindiMember(
        id: 'a-1',
        name: 'Ramesh Patil',
        phone: '+91 98222 11111',
        role: 'Veena Carrier (वीणेकरी)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DindiMember(
        id: 'a-2',
        name: 'Suresh Deshmukh',
        phone: '+91 98222 22222',
        role: 'Taalvadak Pramukh (टाळकरी प्रमुख)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      DindiMember(
        id: 'a-3',
        name: 'Pandurang Chavan',
        phone: '+91 98222 33333',
        role: 'Annadan Samiti (अन्नदान समिती)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DindiMember(
        id: 'a-4',
        name: 'Vilas Kadam',
        phone: '+91 98222 44444',
        role: 'Medical Volunteer (आरोग्य सेवक)',
        status: DindiMemberStatus.approved,
        joinedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    _members.addAll(keyMembers);

    // Generate remaining to complete 128 active members
    for (int i = 5; i <= 128; i++) {
      _members.add(
        DindiMember(
          id: 'a-$i',
          name: 'Warkari Member $i',
          phone: '+91 98000 ${10000 + i}',
          role: i % 4 == 0 ? 'Dhwajdhari' : 'Warkari',
          status: DindiMemberStatus.approved,
          joinedAt: DateTime.now().subtract(Duration(days: 2, hours: i % 12)),
        ),
      );
    }

    _announcements.clear();
    _announcements.addAll([
      DindiAnnouncement(
        id: 'ann-1',
        title: 'Prasthan Timing at Akurdi',
        message:
            'All Dindi members must assemble at Akurdi Vitthal Mandir tomorrow morning at 05:30 AM for Kakad Aarti.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isUrgent: true,
      ),
      DindiAnnouncement(
        id: 'ann-2',
        title: 'Mahaprasad Arrangement',
        message:
            'Evening Mahaprasad will be served near the Community Hall by 07:30 PM.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isUrgent: false,
      ),
    ]);
  }

  void resetDemoData() {
    _initDemoData();
    notifyListeners();
  }

  void updateDindiProfile({
    required String name,
    required String dindiNumber,
    required String leaderName,
    required String leaderPhone,
    required String startPoint,
    required String destination,
    required String currentHalt,
    required String roadStatus,
  }) {
    _dindiGroup = _dindiGroup.copyWith(
      name: name,
      dindiNumber: dindiNumber,
      leaderName: leaderName,
      leaderPhone: leaderPhone,
      startPoint: startPoint,
      destination: destination,
      currentHalt: currentHalt,
      roadStatus: roadStatus,
    );
    notifyListeners();
  }

  void updateRoadStatus(String newRoadStatus) {
    _dindiGroup = _dindiGroup.copyWith(roadStatus: newRoadStatus);
    notifyListeners();
  }

  void approveMember(String memberId) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(
        status: DindiMemberStatus.approved,
      );
      notifyListeners();
    }
  }

  void rejectMember(String memberId) {
    _members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  void addAnnouncement({
    required String title,
    required String message,
    bool isUrgent = false,
  }) {
    final newAnn = DindiAnnouncement(
      id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isUrgent: isUrgent,
    );
    _announcements.insert(0, newAnn);
    notifyListeners();
  }
}
