import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';
import '../repositories/api_pilgrim_repository.dart';
import '../repositories/pilgrim_repository.dart';
import '../services/map_service_interface.dart';

import '../widgets/pilgrim_bottom_nav.dart';
import '../widgets/pilgrim_drawer.dart';
import '../widgets/pilgrim_map_widget.dart';
import '../widgets/pilgrim_profile_modal.dart';

import 'bhakti_screen.dart';
import 'help_screen.dart';
import 'palkhi_screen.dart';
import 'services_screen.dart';
import 'tilak_ai_screen.dart';

/// Main Pilgrim Home Screen — Centered around the Wari Interactive Map.
/// Acts as the Controller layer managing repository state loading & refresh.
class PilgrimHomeScreen extends StatefulWidget {
  final PilgrimRepository? repository;
  final MapServiceInterface? mapService;

  const PilgrimHomeScreen({
    super.key,
    this.repository,
    this.mapService,
  });

  @override
  State<PilgrimHomeScreen> createState() => _PilgrimHomeScreenState();
}

class _PilgrimHomeScreenState extends State<PilgrimHomeScreen> {
  late final PilgrimRepository _repository;
  late final MapServiceInterface _mapService;
  int _currentNavIndex =
      0; // 0: Home/Map, 1: Palkhi, 2: Services, 3: Tilak AI, 4: Bhakti, 5: Help

  PalkhiInfo? _palkhi;
  List<DindiMarkerInfo> _dindis = [];
  List<WariService> _services = [];
  List<WariRouteStage> _routeStages = [];
  List<TrafficAlert> _trafficAlerts = [];
  PilgrimLocation? _userLocation;
  bool _isLoading = true;
  ServiceCategory? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    // Default to ApiPilgrimRepository for live backend queries with Mock fallback
    _repository = widget.repository ?? ApiPilgrimRepository();
    _mapService = widget.mapService ?? DefaultMapService();
    _loadData();
  }

  Future<void> _loadData({ServiceCategory? category}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final location = await _repository.getCurrentUserLocation();
      final palkhi = await _repository.getPalkhiInfo();
      final dindis = await _repository.getNearbyDindis();
      final services = await _repository.getServices(
        category: category ?? _selectedCategoryFilter,
      );
      final routeStages = await _repository.getWariRoute();
      final trafficAlerts = await _repository.getTrafficAlerts();

      if (mounted) {
        setState(() {
          _userLocation = location;
          _palkhi = palkhi;
          _dindis = dindis;
          _services = services;
          _routeStages = routeStages;
          _trafficAlerts = trafficAlerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[PilgrimHomeScreen] Error loading map state: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onCategoryFilterSelected(ServiceCategory? category) {
    setState(() {
      _selectedCategoryFilter = category;
    });
    _loadData(category: category);
  }

  void _onNavTap(int index) {
    if (index == 3) {
      _openTilakAiModal();
    } else {
      setState(() {
        _currentNavIndex = index;
      });
    }
  }

  void _openTilakAiModal({String? initialPrompt}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: TilakAiScreen(
          repository: _repository,
          onNavigateAction: (route) {
            Navigator.pop(context);
            if (route == '/map' || route.startsWith('/map')) {
              setState(() => _currentNavIndex = 0);
            } else if (route == '/palkhi') {
              setState(() => _currentNavIndex = 1);
            } else if (route == '/services') {
              setState(() => _currentNavIndex = 2);
            } else if (route == '/help' || route == '/emergency' || route == '/sos') {
              setState(() => _currentNavIndex = 5);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentNavIndex) {
      case 1:
        return PalkhiScreen(repository: _repository);
      case 2:
        return ServicesScreen(repository: _repository);
      case 4:
        return BhaktiScreen(repository: _repository);
      case 5:
        return HelpScreen(repository: _repository);
      case 0:
      default:
        return PilgrimMapWidget(
          repository: _repository,
          mapService: _mapService,
          palkhi: _palkhi,
          dindis: _dindis,
          services: _services,
          routeStages: _routeStages,
          trafficAlerts: _trafficAlerts,
          userLocation: _userLocation,
          isLoading: _isLoading,
          selectedCategoryFilter: _selectedCategoryFilter,
          onCategoryFilterSelected: _onCategoryFilterSelected,
          onRefresh: () => _loadData(),
          onPalkhiSelected: () {
            setState(() => _currentNavIndex = 1);
          },
          onAskTilakPrompt: (prompt) {
            _openTilakAiModal(initialPrompt: prompt);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_walk, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Maza Pandurang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => PilgrimProfileModal.show(context),
          ),
        ],
      ),
      drawer: PilgrimDrawer(
        onProfileTap: () => PilgrimProfileModal.show(context),
      ),
      body: _buildBody(),
      bottomNavigationBar: PilgrimBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
