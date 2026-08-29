import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../repositories/mock_pilgrim_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockPilgrimRepository();
    _mapService = widget.mapService ?? DefaultMapService();
  }

  void _onNavTap(int index) {
    if (index == 3) {
      // Tilak AI action opens as a modal or full-screen view
      _openTilakAiModal();
    } else {
      setState(() {
        _currentNavIndex = index;
      });
    }
  }

  void _openTilakAiModal() {
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
            if (route == '/palkhi') {
              setState(() => _currentNavIndex = 1);
            } else if (route == '/services') {
              setState(() => _currentNavIndex = 2);
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
        return const HelpScreen();
      case 0:
      default:
        return PilgrimMapWidget(
          repository: _repository,
          mapService: _mapService,
          onPalkhiSelected: () {
            setState(() => _currentNavIndex = 1);
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
            tooltip: 'Open Menu',
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
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
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
