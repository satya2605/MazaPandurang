import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../../common/constants/app_colors.dart';
import '../../admin/models/admin_models.dart' show PalkhiHalt;
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';
import '../services/location_service.dart';
import '../services/map_config.dart';
import '../services/map_service_interface.dart';
import 'map_marker_card.dart';

/// Presentational Interactive Map Canvas displaying georeferenced OpenStreetMap / MapTiler tile layers,
/// live Palkhi procession, planned halts, user location, and category-filtered service markers.
class PilgrimMapWidget extends StatefulWidget {
  final PilgrimRepository repository;
  final MapServiceInterface mapService;

  final PalkhiInfo? palkhi;
  final List<DindiMarkerInfo>? dindis;
  final List<WariService>? services;
  final List<WariRouteStage>? routeStages;
  final List<TrafficAlert>? trafficAlerts;
  final PilgrimLocation? userLocation;
  final bool? isLoading;
  final ServiceCategory? selectedCategoryFilter;
  final String? userDindiId;
  final Function(ServiceCategory?)? onCategoryFilterSelected;
  final VoidCallback? onRefresh;
  final Function(WariService)? onServiceSelected;
  final VoidCallback? onPalkhiSelected;
  final Function(TrafficAlert)? onTrafficAlertSelected;
  final Function(String prompt)? onAskTilakPrompt;

  const PilgrimMapWidget({
    super.key,
    required this.repository,
    required this.mapService,
    this.palkhi,
    this.dindis,
    this.services,
    this.routeStages,
    this.trafficAlerts,
    this.userLocation,
    this.isLoading,
    this.selectedCategoryFilter,
    this.userDindiId,
    this.onCategoryFilterSelected,
    this.onRefresh,
    this.onServiceSelected,
    this.onPalkhiSelected,
    this.onTrafficAlertSelected,
    this.onAskTilakPrompt,
  });

  @override
  State<PilgrimMapWidget> createState() => _PilgrimMapWidgetState();
}

class _PilgrimMapWidgetState extends State<PilgrimMapWidget> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  PalkhiInfo? _localPalkhi;
  List<DindiMarkerInfo> _localDindis = [];
  List<WariService> _localServices = [];
  List<WariRouteStage> _localRouteStages = [];
  List<TrafficAlert> _localTrafficAlerts = [];
  PilgrimLocation? _localUserLocation;
  bool _localIsLoading = false;
  ServiceCategory? _localSelectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    if (widget.palkhi == null && widget.dindis == null) {
      _loadLocalData();
    }
  }

  Future<void> _loadLocalData() async {
    setState(() => _localIsLoading = true);
    try {
      final results = await Future.wait([
        widget.repository.getPalkhiInfo(),
        widget.repository.getNearbyDindis(),
        widget.repository.getServices(category: _effectiveCategoryFilter),
        widget.repository.getWariRoute(),
        widget.repository.getTrafficAlerts(),
        _locationService.getCurrentLocation(),
      ]);

      if (mounted) {
        setState(() {
          _localPalkhi = results[0] as PalkhiInfo?;
          _localDindis = results[1] as List<DindiMarkerInfo>;
          _localServices = results[2] as List<WariService>;
          _localRouteStages = results[3] as List<WariRouteStage>;
          _localTrafficAlerts = results[4] as List<TrafficAlert>;
          _localUserLocation = results[5] as PilgrimLocation?;
          _localIsLoading = false;
        });
        final entities = _buildNormalizedLocationEntities();
        if (entities.isNotEmpty) {
          _fitCameraToBounds(entities);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _localIsLoading = false);
      }
    }
  }

  PalkhiInfo? get _effectivePalkhi => widget.palkhi ?? _localPalkhi;
  List<DindiMarkerInfo> get _effectiveDindis => widget.dindis ?? _localDindis;
  List<WariService> get _effectiveServices => widget.services ?? _localServices;
  List<TrafficAlert> get _effectiveTrafficAlerts => widget.trafficAlerts ?? _localTrafficAlerts;
  PilgrimLocation? get _effectiveUserLocation => widget.userLocation ?? _localUserLocation;
  bool get _effectiveIsLoading => widget.isLoading ?? _localIsLoading;
  ServiceCategory? get _effectiveCategoryFilter => widget.selectedCategoryFilter ?? _localSelectedCategoryFilter;

  void _handleCategoryFilter(ServiceCategory? category) {
    if (widget.onCategoryFilterSelected != null) {
      widget.onCategoryFilterSelected!(category);
    } else {
      setState(() {
        _localSelectedCategoryFilter = category;
      });
      _loadLocalData();
    }
  }

  bool _isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat == 0.0 && lng == 0.0) return false;
    if (lat < -90.0 || lat > 90.0) return false;
    if (lng < -180.0 || lng > 180.0) return false;
    return true;
  }

  List<MapLocationEntity> _buildNormalizedLocationEntities() {
    final List<MapLocationEntity> list = [];

    if (_effectivePalkhi != null) {
      final p = _effectivePalkhi!;
      if (_isValidCoordinate(p.currentPosition.latitude, p.currentPosition.longitude)) {
        list.add(
          MapLocationEntity(
            id: p.palkhiId,
            type: MapLocationType.palkhiLive,
            title: p.name,
            subtitle: 'टप्पा: ${p.currentStage} • पुढील: ${p.nextStop}',
            latitude: p.currentPosition.latitude,
            longitude: p.currentPosition.longitude,
            status: 'ACTIVE',
            metadata: {'palkhi': p},
          ),
        );
      }

      for (final h in p.halts) {
        if (_isValidCoordinate(h.approxLatitude, h.approxLongitude)) {
          list.add(
            MapLocationEntity(
              id: h.id,
              type: MapLocationType.palkhiHalt,
              title: '${h.locationName} (दिवस ${h.dayNumber})',
              subtitle: 'तारीख: ${h.haltDate} • वेळ: ${h.expectedArrival ?? "दिवसभर"}',
              latitude: h.approxLatitude!,
              longitude: h.approxLongitude!,
              status: 'PLANNED',
              metadata: {'halt': h},
            ),
          );
        }
      }
    }

    if (widget.userDindiId != null && widget.userDindiId!.isNotEmpty) {
      for (final d in _effectiveDindis) {
        if (d.dindiId == widget.userDindiId && _isValidCoordinate(d.position.latitude, d.position.longitude)) {
          list.add(
            MapLocationEntity(
              id: d.dindiId,
              type: MapLocationType.dindi,
              title: d.name,
              subtitle: 'प्रमुख: ${d.leaderName} • सदस्य: ${d.memberCount}',
              latitude: d.position.latitude,
              longitude: d.position.longitude,
              status: d.currentStatus,
              metadata: {'dindi': d},
            ),
          );
        }
      }
    }

    for (final s in _effectiveServices) {
      if (!_isValidCoordinate(s.position.latitude, s.position.longitude)) continue;
      if (_effectiveCategoryFilter != null && s.category != _effectiveCategoryFilter) continue;
      
      MapLocationType sType;
      switch (s.category) {
        case ServiceCategory.medical: sType = MapLocationType.serviceMedical; break;
        case ServiceCategory.food: sType = MapLocationType.serviceFood; break;
        case ServiceCategory.water: sType = MapLocationType.serviceWater; break;
        case ServiceCategory.police: sType = MapLocationType.servicePolice; break;
        case ServiceCategory.toilet: sType = MapLocationType.serviceToilet; break;
        case ServiceCategory.shelter: sType = MapLocationType.serviceShelter; break;
        default: sType = MapLocationType.serviceOther;
      }

      list.add(
        MapLocationEntity(
          id: s.serviceId,
          type: sType,
          title: s.name,
          subtitle: '${s.availabilityStatus} • ${s.address}',
          latitude: s.position.latitude,
          longitude: s.position.longitude,
          status: s.availabilityStatus,
          metadata: {'service': s},
        ),
      );
    }
    return list;
  }

  void _fitCameraToBounds(List<MapLocationEntity> entities) {
    if (entities.isEmpty) return;

    double minLat = entities.first.latitude;
    double maxLat = entities.first.latitude;
    double minLng = entities.first.longitude;
    double maxLng = entities.first.longitude;

    for (final e in entities) {
      if (e.latitude < minLat) minLat = e.latitude;
      if (e.latitude > maxLat) maxLat = e.latitude;
      if (e.longitude < minLng) minLng = e.longitude;
      if (e.longitude > maxLng) maxLng = e.longitude;
    }

    if (minLat == maxLat && minLng == maxLng) {
      _mapController.move(ll.LatLng(minLat, minLng), 13.0);
    } else {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(
            ll.LatLng(minLat, minLng),
            ll.LatLng(maxLat, maxLng),
          ),
          padding: const EdgeInsets.only(top: 100, bottom: 100, left: 50, right: 50),
        ),
      );
    }
  }

  void _handleLocationTap(MapLocationEntity entity) {
    if (entity.type == MapLocationType.palkhiLive && entity.metadata['palkhi'] != null) {
      MapMarkerCard.showPalkhiCard(
        context: context,
        palkhi: entity.metadata['palkhi'] as PalkhiInfo,
        onTrackSelected: () {
          if (widget.onPalkhiSelected != null) widget.onPalkhiSelected!();
        },
        onAskTilakSelected: () {
          if (widget.onAskTilakPrompt != null) widget.onAskTilakPrompt!('Where is the Palkhi right now?');
        },
      );
    } else if (entity.type == MapLocationType.palkhiHalt && entity.metadata['halt'] != null) {
      MapMarkerCard.showPalkhiHaltCard(
        context: context,
        halt: entity.metadata['halt'] as PalkhiHalt,
        onAskTilakSelected: () {
          if (widget.onAskTilakPrompt != null) widget.onAskTilakPrompt!('Tell me about ${entity.title}');
        },
      );
    } else if (entity.type == MapLocationType.dindi && entity.metadata['dindi'] != null) {
      MapMarkerCard.showDindiCard(
        context: context,
        dindi: entity.metadata['dindi'] as DindiMarkerInfo,
        onJoinSelected: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Joining Dindi: ${entity.title}')),
          );
        },
      );
    } else if (entity.metadata['service'] != null) {
      final s = entity.metadata['service'] as WariService;
      MapMarkerCard.showServiceCard(
        context: context,
        service: s,
        distanceKm: _effectiveUserLocation != null ? s.position.distanceToInKm(_effectiveUserLocation!.position) : null,
        onViewDetails: () {
          if (widget.onServiceSelected != null) widget.onServiceSelected!(s);
        },
        onGetDirections: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Directions to ${s.name} (${s.address})')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = widget.mapService.mapTilerApiKey ?? MapConfig.mapTilerApiKey;
    final hasKey = apiKey.trim().isNotEmpty;

    final tileUrl = hasKey
        ? 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$apiKey'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    final entities = _buildNormalizedLocationEntities();

    final routeCoords = <ll.LatLng>[];
    if (_localRouteStages.isNotEmpty) {
      routeCoords.addAll(
        _localRouteStages.map((st) => ll.LatLng(st.position.latitude, st.position.longitude)),
      );
    } else if (_effectivePalkhi != null) {
      routeCoords.addAll(
        _effectivePalkhi!.routePoints.map((pt) => ll.LatLng(pt.latitude, pt.longitude)),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: ll.LatLng(18.3411, 74.0305),
            initialZoom: 11.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: tileUrl,
              userAgentPackageName: 'org.mazapandurang.app',
            ),
            if (routeCoords.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeCoords,
                    color: const Color(0xFFE65100),
                    strokeWidth: 4.5,
                  ),
                ],
              ),
            MarkerLayer(
              markers: entities.map((e) {
                return Marker(
                  point: ll.LatLng(e.latitude, e.longitude),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _handleLocationTap(e),
                    child: Tooltip(
                      message: e.title,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: e.type.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Icon(e.type.icon, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        if (!hasKey)
          Positioned(
            top: 140,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade900,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'MapTiler API Key optional for basemap tiles.\nFallback OpenStreetMap tiles active.',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (!_effectiveIsLoading) ...[
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_effectivePalkhi != null) {
                    MapMarkerCard.showPalkhiCard(
                      context: context,
                      palkhi: _effectivePalkhi!,
                      onTrackSelected: () => widget.onPalkhiSelected?.call(),
                      onAskTilakSelected: () => widget.onAskTilakPrompt?.call('Where is the Palkhi right now?'),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(50), shape: BoxShape.circle),
                        child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _effectivePalkhi?.name ?? 'संत तुकाराम महाराज पालखी',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _effectivePalkhi != null
                                  ? 'टप्पा: ${_effectivePalkhi!.currentStage} • पुढील: ${_effectivePalkhi!.nextStop}'
                                  : 'मार्ग: देहू ➔ पंढरपूर (सासवड मुक्काम)',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 76,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip(null, 'All Services (सर्व सेवा)', Icons.grid_view_rounded),
                  _buildCategoryChip(ServiceCategory.medical, 'Medical (वैद्यकीय)', Icons.local_hospital_rounded),
                  _buildCategoryChip(ServiceCategory.water, 'Water (पिण्याचे पाणी)', Icons.water_drop_rounded),
                  _buildCategoryChip(ServiceCategory.food, 'Food (अन्नछत्र)', Icons.restaurant_rounded),
                  _buildCategoryChip(ServiceCategory.toilet, 'Toilet (स्वच्छता गृह)', Icons.wc_rounded),
                  _buildCategoryChip(ServiceCategory.shelter, 'Shelter (विश्राम धाम)', Icons.night_shelter_rounded),
                  _buildCategoryChip(ServiceCategory.police, 'Police (पोलीस मदत)', Icons.local_police_rounded),
                ],
              ),
            ),
          ),

          // Active Traffic Alert Bar
          if (_effectiveTrafficAlerts.isNotEmpty)
            Positioned(
              top: 124,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final firstAlert = _effectiveTrafficAlerts.first;
                    MapMarkerCard.showTrafficCard(
                      context: context,
                      alert: firstAlert,
                      onAskTilakSelected: () {
                        if (widget.onAskTilakPrompt != null) {
                          widget.onAskTilakPrompt!('Is there traffic ahead?');
                        }
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ ${_effectiveTrafficAlerts.first.title}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text('Details ➔', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'mapRefresh',
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    if (widget.onRefresh != null) {
                      widget.onRefresh!();
                    } else {
                      _loadLocalData();
                    }
                  },
                  child: const Icon(Icons.refresh_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'mapRecenter',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    final entities = _buildNormalizedLocationEntities();
                    if (entities.isNotEmpty) {
                      _fitCameraToBounds(entities);
                    } else if (_effectiveUserLocation != null) {
                      _mapController.move(
                        ll.LatLng(_effectiveUserLocation!.position.latitude, _effectiveUserLocation!.position.longitude),
                        13.0,
                      );
                    }
                  },
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),

          Positioned(
            left: 12,
            bottom: 36,
            child: _buildMapLegend(),
          ),

          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(6)),
              child: const Text(
                '© OpenStreetMap contributors | MapTiler',
                style: TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryChip(ServiceCategory? category, String label, IconData icon) {
    final isSelected = _effectiveCategoryFilter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textPrimary),
        label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : AppColors.textPrimary)),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border, width: 1),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        onSelected: (_) => _handleCategoryFilter(category),
      ),
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withAlpha(240), borderRadius: BorderRadius.circular(6), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendDot(MapLocationType.palkhiLive),
          const SizedBox(width: 6),
          _buildLegendDot(MapLocationType.palkhiHalt),
          const SizedBox(width: 6),
          _buildLegendDot(MapLocationType.serviceMedical),
          const SizedBox(width: 6),
          _buildLegendDot(MapLocationType.serviceWater),
          const SizedBox(width: 6),
          _buildLegendDot(MapLocationType.serviceFood),
        ],
      ),
    );
  }

  Widget _buildLegendDot(MapLocationType type) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: type.color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(type.label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
