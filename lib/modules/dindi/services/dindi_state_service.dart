import 'package:flutter/foundation.dart';
import '../models/dindi_announcement.dart';
import '../models/dindi_group.dart';
import '../models/dindi_member.dart';
import '../repositories/dindi_repository.dart';
import '../repositories/supabase_dindi_repository.dart';
import 'dindi_identity_provider.dart';

/// State management service for the Dindi Leader module.
///
/// Exclusively backed by the real Supabase PostgreSQL database via [SupabaseDindiRepository].
/// Decoupled from concrete authentication via [DindiIdentityProvider].
class DindiStateService extends ChangeNotifier {
  static final DindiStateService _instance = DindiStateService._internal();

  factory DindiStateService({
    DindiRepository? repository,
    DindiIdentityProvider? identityProvider,
  }) {
    if (repository != null) {
      _instance._repository = repository;
    }
    if (identityProvider != null) {
      _instance._identityProvider = identityProvider;
    }
    return _instance;
  }

  DindiStateService._internal() {
    _identityProvider = const AuthDindiIdentityProvider();
    _repository = SupabaseDindiRepository();
  }

  late DindiRepository _repository;
  late DindiIdentityProvider _identityProvider;

  final List<DindiGroup> _dindis = [];
  final List<DindiMember> _members = [];
  final List<DindiAnnouncement> _announcements = [];
  String? _selectedDindiId;
  bool _isLoading = false;
  String? _errorMessage;

  // ----------------------------------------------------
  // Getters
  // ----------------------------------------------------
  DindiRepository get repository => _repository;
  DindiIdentityProvider get identityProvider => _identityProvider;
  List<DindiGroup> get dindis => List.unmodifiable(_dindis);
  String? get selectedDindiId => _selectedDindiId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// The currently selected Dindi or empty object if none available.
  DindiGroup get dindiGroup {
    if (_selectedDindiId != null) {
      final index = _dindis.indexWhere((d) => d.id == _selectedDindiId);
      if (index != -1) {
        return _dindis[index];
      }
    }
    if (_dindis.isNotEmpty) {
      return _dindis.first;
    }
    return const DindiGroup(
      id: '',
      name: '',
      dindiNumber: '',
      leaderName: '',
      leaderPhone: '',
      startPoint: '',
      destination: '',
      currentHalt: '',
      roadStatus: 'Clear & Moving',
      joinCode: '',
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
  // Lifecycle & Real Data Load
  // ----------------------------------------------------
  /// Loads the leader's Dindis and members from the real database repository.
  ///
  /// Strictly surfaces errors and empty states without fake fallback data.
  Future<void> loadDindis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _repository.getDindis(
        leaderUserId: _identityProvider.currentUserId,
      );

      _dindis.clear();
      _dindis.addAll(list);

      // Select first dindi if previous selection is invalid or null
      if (_selectedDindiId == null ||
          !_dindis.any((d) => d.id == _selectedDindiId)) {
        if (_dindis.isNotEmpty) {
          _selectedDindiId = _dindis.first.id;
        } else {
          _selectedDindiId = null;
        }
      }

      // Populate members and announcements for all Dindis
      _members.clear();
      _announcements.clear();
      for (final d in _dindis) {
        final m = await _repository.getMembers(d.id);
        _members.addAll(m);
        final a = await _repository.getAnnouncements(d.id);
        _announcements.addAll(a);
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      debugPrint('[DindiStateService] loadDindis error: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Refreshes members specifically for the selected Dindi.
  Future<void> loadMembersForSelectedDindi() async {
    if (_selectedDindiId == null || _selectedDindiId!.isEmpty) return;

    try {
      final m = await _repository.getMembers(_selectedDindiId!);
      _members.removeWhere((member) => member.dindiId == _selectedDindiId);
      _members.addAll(m);
      notifyListeners();
    } catch (e) {
      debugPrint('[DindiStateService] loadMembersForSelectedDindi error: $e');
      rethrow;
    }
  }

  /// Clears in-memory cache for state reset in test harnesses.
  void resetState() {
    _dindis.clear();
    _members.clear();
    _announcements.clear();
    _selectedDindiId = null;
    _isLoading = false;
    _errorMessage = null;
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
  // Dindi CRUD Operations
  // ----------------------------------------------------
  Future<DindiGroup> createDindi({
    required String name,
    required String dindiNumber,
    String? leaderName,
    String? leaderPhone,
    required String startPoint,
    required String destination,
    required String currentHalt,
    required String roadStatus,
    required String joinCode,
    String? leaderUserId,
    String? documentUrl,
    String? leaderImageUrl,
  }) async {
    final effectiveLeaderId = leaderUserId ?? _identityProvider.currentUserId;
    final effectiveLeaderName =
        leaderName ?? _identityProvider.currentLeaderName;
    final effectiveLeaderPhone =
        leaderPhone ?? _identityProvider.currentLeaderPhone;

    final newDindi = DindiGroup(
      id: '',
      name: name,
      dindiNumber: dindiNumber,
      leaderName: effectiveLeaderName,
      leaderPhone: effectiveLeaderPhone,
      startPoint: startPoint,
      destination: destination,
      currentHalt: currentHalt,
      roadStatus: roadStatus,
      joinCode: joinCode,
      leaderUserId: effectiveLeaderId,
      documentUrl: documentUrl ?? '',
      leaderImageUrl: leaderImageUrl ?? '',
    );

    final created = await _repository.createDindi(newDindi);

    _dindis.insert(0, created);
    _selectedDindiId = created.id;
    notifyListeners();
    return created;
  }

  Future<DindiGroup> updateDindiProfile({
    required String name,
    required String dindiNumber,
    String? leaderName,
    String? leaderPhone,
    required String startPoint,
    required String destination,
    required String currentHalt,
    required String roadStatus,
    String? status,
  }) async {
    final current = dindiGroup;
    final updated = current.copyWith(
      name: name,
      dindiNumber: dindiNumber,
      leaderName: leaderName ?? current.leaderName,
      leaderPhone: leaderPhone ?? current.leaderPhone,
      startPoint: startPoint,
      destination: destination,
      currentHalt: currentHalt,
      roadStatus: roadStatus,
      status: status ?? current.status,
    );

    final persisted = await _repository.updateDindi(updated);

    final index = _dindis.indexWhere((d) => d.id == persisted.id);
    if (index != -1) {
      _dindis[index] = persisted;
    } else {
      _dindis.add(persisted);
    }
    notifyListeners();
    return persisted;
  }

  Future<DindiGroup> updateRoadStatus(String newRoadStatus) async {
    final current = dindiGroup;
    final updated = current.copyWith(roadStatus: newRoadStatus);

    final persisted = await _repository.updateDindi(updated);

    final index = _dindis.indexWhere((d) => d.id == persisted.id);
    if (index != -1) {
      _dindis[index] = persisted;
    } else {
      _dindis.add(persisted);
    }
    notifyListeners();
    return persisted;
  }

  // ----------------------------------------------------
  // Member Operations (Scoped to Selected Dindi)
  // ----------------------------------------------------
  Future<void> approveMember(String memberId) async {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(
        status: DindiMemberStatus.approved,
      );
      notifyListeners();
    }

    try {
      await _repository.updateMemberStatus(
        memberId,
        DindiMemberStatus.approved,
      );
    } catch (e) {
      debugPrint('[DindiStateService] approveMember error: $e');
      rethrow;
    }
  }

  Future<void> rejectMember(String memberId) async {
    final index = _members.indexWhere((m) => m.id == memberId);
    DindiMember? previous;
    if (index != -1) {
      previous = _members[index];
      _members.removeAt(index);
      notifyListeners();
    }

    try {
      await _repository.removeMember(memberId);
    } catch (e) {
      if (previous != null) {
        _members.insert(index, previous);
        notifyListeners();
      }
      debugPrint('[DindiStateService] rejectMember error: $e');
      rethrow;
    }
  }

  // ----------------------------------------------------
  // Announcement Operations (Scoped to Selected Dindi)
  // ----------------------------------------------------
  void addAnnouncement({
    required String title,
    required String message,
    bool isUrgent = false,
  }) {
    if (_selectedDindiId == null) return;

    final newAnn = DindiAnnouncement(
      id: 'ann-${DateTime.now().millisecondsSinceEpoch}',
      dindiId: _selectedDindiId!,
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
