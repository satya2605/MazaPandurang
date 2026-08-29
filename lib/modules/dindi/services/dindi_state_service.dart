import 'package:flutter/foundation.dart';
import '../models/dindi_announcement.dart';
import '../models/dindi_group.dart';
import '../models/dindi_member.dart';
import '../repositories/dindi_repository.dart';
import '../repositories/in_memory_dindi_repository.dart';

/// In-memory state service for the Dindi Leader module.
/// Decoupled from concrete data source via [DindiRepository] for future Supabase substitution.
class DindiStateService extends ChangeNotifier {
  static final DindiStateService _instance = DindiStateService._internal();

  factory DindiStateService({DindiRepository? repository}) {
    if (repository != null) {
      _instance._repository = repository;
    }
    return _instance;
  }

  DindiStateService._internal() {
    _repository = InMemoryDindiRepository.instance;
    _initData();
  }

  late DindiRepository _repository;
  final List<DindiGroup> _dindis = [];
  final List<DindiMember> _members = [];
  final List<DindiAnnouncement> _announcements = [];
  String _selectedDindiId = 'dindi-12';

  // ----------------------------------------------------
  // Getters
  // ----------------------------------------------------
  List<DindiGroup> get dindis => List.unmodifiable(_dindis);
  String get selectedDindiId => _selectedDindiId;

  /// The currently selected Dindi (defaults to dindi-12).
  DindiGroup get dindiGroup {
    final index = _dindis.indexWhere((d) => d.id == _selectedDindiId);
    if (index != -1) {
      return _dindis[index];
    }
    return _dindis.isNotEmpty
        ? _dindis.first
        : const DindiGroup(
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
  }

  /// Members belonging to the currently selected Dindi.
  List<DindiMember> get members => List.unmodifiable(
        _members.where((m) => m.dindiId == _selectedDindiId),
      );

  List<DindiMember> get activeMembers => _members
      .where((m) =>
          m.dindiId == _selectedDindiId &&
          m.status == DindiMemberStatus.approved)
      .toList();

  List<DindiMember> get pendingMembers => _members
      .where((m) =>
          m.dindiId == _selectedDindiId &&
          m.status == DindiMemberStatus.pending)
      .toList();

  int get totalMemberCount => activeMembers.length;
  int get pendingRequestCount => pendingMembers.length;

  /// Announcements belonging to the currently selected Dindi.
  List<DindiAnnouncement> get announcements => List.unmodifiable(
        _announcements.where((a) => a.dindiId == _selectedDindiId),
      );

  // ----------------------------------------------------
  // Lifecycle & Initial Data Load
  // ----------------------------------------------------
  void _initData() {
    _refreshSync();
  }

  void _refreshSync() {
    final repo = _repository;
    if (repo is InMemoryDindiRepository) {
      _dindis.clear();
      _dindis.addAll(repo.internalDindis);
      _members.clear();
      _members.addAll(repo.internalMembers);
      _announcements.clear();
      _announcements.addAll(repo.internalAnnouncements);
    }
  }

  Future<void> loadDindis() async {
    final list = await _repository.getDindis();
    _dindis.clear();
    _dindis.addAll(list);

    _members.clear();
    _announcements.clear();
    for (final d in _dindis) {
      final m = await _repository.getMembers(d.id);
      _members.addAll(m);
      final a = await _repository.getAnnouncements(d.id);
      _announcements.addAll(a);
    }
    notifyListeners();
  }

  void resetDemoData() {
    if (_repository is InMemoryDindiRepository) {
      (_repository as InMemoryDindiRepository).reset();
    }
    _selectedDindiId = 'dindi-12';
    _refreshSync();
    notifyListeners();
  }

  // ----------------------------------------------------
  // Selection
  // ----------------------------------------------------
  void selectDindi(String dindiId) {
    _selectedDindiId = dindiId;
    notifyListeners();
  }

  // ----------------------------------------------------
  // Dindi CRUD
  // ----------------------------------------------------
  Future<DindiGroup> createDindi({
    required String name,
    required String dindiNumber,
    required String leaderName,
    required String leaderPhone,
    required String startPoint,
    required String destination,
    required String currentHalt,
    required String roadStatus,
    required String joinCode,
    String leaderUserId = 'leader-sanket-1',
  }) async {
    final id = 'dindi-${DateTime.now().millisecondsSinceEpoch}';
    final newDindi = DindiGroup(
      id: id,
      name: name,
      dindiNumber: dindiNumber,
      leaderName: leaderName,
      leaderPhone: leaderPhone,
      startPoint: startPoint,
      destination: destination,
      currentHalt: currentHalt,
      roadStatus: roadStatus,
      joinCode: joinCode,
      leaderUserId: leaderUserId,
    );

    await _repository.createDindi(newDindi);
    _dindis.add(newDindi);
    _selectedDindiId = newDindi.id;
    notifyListeners();
    return newDindi;
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
    final current = dindiGroup;
    final updated = current.copyWith(
      name: name,
      dindiNumber: dindiNumber,
      leaderName: leaderName,
      leaderPhone: leaderPhone,
      startPoint: startPoint,
      destination: destination,
      currentHalt: currentHalt,
      roadStatus: roadStatus,
    );

    _repository.updateDindi(updated);
    final index = _dindis.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _dindis[index] = updated;
    }
    notifyListeners();
  }

  void updateRoadStatus(String newRoadStatus) {
    final current = dindiGroup;
    final updated = current.copyWith(roadStatus: newRoadStatus);
    _repository.updateDindi(updated);
    final index = _dindis.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _dindis[index] = updated;
    }
    notifyListeners();
  }

  // ----------------------------------------------------
  // Member Operations (Scoped to Selected Dindi)
  // ----------------------------------------------------
  void approveMember(String memberId) {
    _repository.updateMemberStatus(
      memberId,
      DindiMemberStatus.approved,
    );
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(
        status: DindiMemberStatus.approved,
      );
    }
    notifyListeners();
  }

  void rejectMember(String memberId) {
    _repository.removeMember(memberId);
    _members.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  // ----------------------------------------------------
  // Announcement Operations (Scoped to Selected Dindi)
  // ----------------------------------------------------
  void addAnnouncement({
    required String title,
    required String message,
    bool isUrgent = false,
  }) {
    final newAnn = DindiAnnouncement(
      id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
      dindiId: _selectedDindiId,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      isUrgent: isUrgent,
    );

    _repository.addAnnouncement(newAnn);
    _announcements.insert(0, newAnn);
    notifyListeners();
  }
}
