import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../common/constants/app_colors.dart';
import '../../admin/models/admin_models.dart' show PalkhiHalt;
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';
import '../services/location_service.dart';
import '../services/map_config.dart';
import '../services/map_service_interface.dart';
import 'map_marker_card.dart';

/// Presentational Interactive Map Canvas displaying MapLibre + MapTiler / OSM data layers,
/// user location, Palkhi marker, Dindis, and categorized service markers.
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
  MapLibreMapController? _mapController;
  final LocationService _locationService = LocationService();
  double _zoomLevel = 11.0;

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
        _addRouteLineAndMarkers();
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

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
    _addRouteLineAndMarkers();
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

    // 1. Live Palkhi Locations
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

      // 2. Palkhi Planned Halts
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

    // 3. Dindi Markers — STRICT DINDI PRIVACY ENFORCEMENT (Rule 11)
    // Only show Dindi marker if authenticated pilgrim is an active member of that specific Dindi
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

    // 4. Categorized Service Markers
    for (final s in _effectiveServices) {
      if (!_isValidCoordinate(s.position.latitude, s.position.longitude)) {
        continue; // Skip invalid/missing coordinates
      }
      if (_effectiveCategoryFilter != null && s.category != _effectiveCategoryFilter) {
        continue; // Filter by category
      }
      MapLocationType sType;
      switch (s.category) {
        case ServiceCategory.medical:
          sType = MapLocationType.serviceMedical;
          break;
        case ServiceCategory.food:
          sType = MapLocationType.serviceFood;
          break;
        case ServiceCategory.water:
          sType = MapLocationType.serviceWater;
          break;
        case ServiceCategory.police:
          sType = MapLocationType.servicePolice;
          break;
        case ServiceCategory.toilet:
          sType = MapLocationType.serviceToilet;
          break;
        case ServiceCategory.shelter:
          sType = MapLocationType.serviceShelter;
          break;
        default:
          sType = MapLocationType.serviceOther;
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
    if (_mapController == null || entities.isEmpty) return;

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
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 13.0),
      );
    } else {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          left: 50,
          top: 90,
          right: 50,
          bottom: 90,
        ),
      );
    }
  }

  Future<void> _addRouteLineAndMarkers() async {
    if (_mapController == null) return;

    final List<LatLng> coords = [];
    if (_localRouteStages.isNotEmpty) {
      coords.addAll(
        _localRouteStages.map(
          (st) => LatLng(st.position.latitude, st.position.longitude),
        ),
      );
    } else if (_effectivePalkhi != null) {
      coords.addAll(
        _effectivePalkhi!.routePoints.map(
          (pt) => LatLng(pt.latitude, pt.longitude),
        ),
      );
    }

    if (coords.isNotEmpty) {
      await _mapController?.addLine(
        LineOptions(
          geometry: coords,
          lineColor: '#E65100',
          lineWidth: 5.0,
          lineOpacity: 0.85,
        ),
      );
    }

    final entities = _buildNormalizedLocationEntities();
    for (final e in entities) {
      await _mapController?.addSymbol(
        SymbolOptions(
          geometry: LatLng(e.latitude, e.longitude),
          iconImage: 'marker-15',
          iconSize: 1.2,
          // Removed textField text overlays! Markers are compact icon pins only.
        ),
      );
    }

    if (entities.isNotEmpty) {
      _fitCameraToBounds(entities);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = widget.mapService.mapTilerApiKey ?? MapConfig.mapTilerApiKey;
    final hasKey = apiKey.trim().isNotEmpty;
    final styleUrl = MapConfig.mapTilerStyleUrl.isNotEmpty
        ? MapConfig.mapTilerStyleUrl
        : 'https://api.maptiler.com/maps/streets-v2/style.json?key=$apiKey';

    return Stack(
      children: [
        // MapLibre Basemap or Fallback Canvas
        if (hasKey)
          MapLibreMap(
            styleString: styleUrl,
            initialCameraPosition: const CameraPosition(
              target: LatLng(18.3411, 74.0305), // Saswad / Wari Center
              zoom: 11.0,
            ),
            onMapCreated: _onMapCreated,
            trackCameraPosition: true,
            myLocationEnabled: false,
          )
        else
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE8ECEF),
            child: CustomPaint(
              painter: _MapCanvasPainter(
                zoomLevel: _zoomLevel,
                selectedCategory: _effectiveCategoryFilter,
                dindisCount: _effectiveDindis.length,
                servicesCount: _effectiveServices.length,
              ),
              child: _effectiveIsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.expand(),
            ),
          ),

        // Missing API Key Notification Banner
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
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'MapTiler API Key required for basemap tiles.\nRun app with --dart-define=MAPTILER_API_KEY=YOUR_KEY',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Interactive Map Layers Overlay
        if (!_effectiveIsLoading) ...[
          // Palkhi Banner & Quick Access
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
                      onTrackSelected: () {
                        if (widget.onPalkhiSelected != null) {
                          widget.onPalkhiSelected!();
                        }
                      },
                      onAskTilakSelected: () {
                        if (widget.onAskTilakPrompt != null) {
                          widget.onAskTilakPrompt!('Where is the Palkhi right now?');
                        }
                      },
                    );
                  } else if (widget.onPalkhiSelected != null) {
                    widget.onPalkhiSelected!();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _effectivePalkhi?.name ?? 'Palkhi Live Track',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Stage: ${_effectivePalkhi?.currentStage}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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

          // Category Chips Overlay
          Positioned(
            top: 76,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    selected: _effectiveCategoryFilter == null,
                    label: const Text('All Services'),
                    selectedColor: AppColors.primaryLight.withAlpha(50),
                    onSelected: (_) => _handleCategoryFilter(null),
                  ),
                  const SizedBox(width: 8),
                  ...ServiceCategory.values.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _effectiveCategoryFilter == cat,
                        avatar: Icon(cat.icon, size: 16, color: cat.color),
                        label: Text(cat.label),
                        selectedColor: cat.color.withAlpha(40),
                        onSelected: (_) => _handleCategoryFilter(cat),
                      ),
                    ),
                  ),
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

          // Zoom, Refresh & Re-Center Controls
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refreshing Wari map data...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomIn',
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  onPressed: () {
                    if (_mapController != null) {
                      _mapController!.animateCamera(CameraUpdate.zoomIn());
                    } else {
                      setState(() {
                        _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 3.0);
                      });
                    }
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  onPressed: () {
                    if (_mapController != null) {
                      _mapController!.animateCamera(CameraUpdate.zoomOut());
                    } else {
                      setState(() {
                        _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 3.0);
                      });
                    }
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'recenter',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    if (_mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          const LatLng(18.3411, 74.0305),
                          11.0,
                        ),
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Centered on location: ${_effectiveUserLocation?.name}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // Map Legend & Marker Filter Indicators
          Positioned(
            left: 12,
            bottom: 36,
            child: _buildMapLegend(),
          ),

          // Map Attribution (MapLibre + MapTiler / OpenStreetMap Data)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '© OpenStreetMap contributors | MapLibre + MapTiler',
                style: TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ),
          ),

          // Interactive Overlay Markers (Renders cleanly over both MapLibre and Canvas basemaps)
          Positioned.fill(
            child: _buildInteractiveOverlayPins(_buildNormalizedLocationEntities()),
          ),
        ],
      ],
    );
  }

  Widget _buildInteractiveOverlayPins(List<MapLocationEntity> entities) {
    if (entities.isEmpty) return const SizedBox.shrink();

    const double minLat = 17.5;
    const double maxLat = 19.5;
    const double minLng = 73.5;
    const double maxLng = 77.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: entities.map((e) {
            final normY = (1.0 - (e.latitude - minLat) / (maxLat - minLat)).clamp(0.12, 0.82);
            final normX = ((e.longitude - minLng) / (maxLng - minLng)).clamp(0.06, 0.90);

            final posX = constraints.maxWidth * normX;
            final posY = constraints.maxHeight * normY;

            return Positioned(
              left: posX - 16,
              top: posY - 16,
              child: GestureDetector(
                onTap: () => _handleLocationTap(e),
                child: Tooltip(
                  message: e.title,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: e.type.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Icon(e.type.icon, color: Colors.white, size: 14),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
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

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendDot(MapLocationType.palkhiLive),
          const SizedBox(width: 6),
          _buildLegendDot(MapLocationType.palkhiHalt),
          const SizedBox(width: 6),
          _buildLegendDot(MapLocationType.dindi),
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
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: type.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          type.label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

/// Custom Painter drawing fallback Wari route polylines and map grid.
class _MapCanvasPainter extends CustomPainter {
  final double zoomLevel;
  final ServiceCategory? selectedCategory;
  final int dindisCount;
  final int servicesCount;

  _MapCanvasPainter({
    required this.zoomLevel,
    this.selectedCategory,
    required this.dindisCount,
    required this.servicesCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFD0D7DE)
      ..strokeWidth = 1.0;

    final routePaint = Paint()
      ..color = AppColors.primary.withAlpha(200)
      ..strokeWidth = 5.0 * zoomLevel
      ..style = PaintingStyle.stroke;

    // Draw Grid
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Wari Polyline Path (Pune -> Saswad -> Jejuri -> Pandharpur)
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.7,
      size.width * 0.9,
      size.height * 0.85,
    );

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.selectedCategory != selectedCategory ||
        oldDelegate.dindisCount != dindisCount ||
        oldDelegate.servicesCount != servicesCount;
  }
}
