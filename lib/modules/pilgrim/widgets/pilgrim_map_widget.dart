import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../common/constants/app_colors.dart';
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
    final location = await _locationService.getCurrentLocation();
    final palkhi = await widget.repository.getPalkhiInfo();
    final dindis = await widget.repository.getNearbyDindis();
    final services = await widget.repository.getServices(
      category: _localSelectedCategoryFilter,
    );
    final routeStages = await widget.repository.getWariRoute();
    final trafficAlerts = await widget.repository.getTrafficAlerts();

    if (mounted) {
      setState(() {
        _localUserLocation = location;
        _localPalkhi = palkhi;
        _localDindis = dindis;
        _localServices = services;
        _localRouteStages = routeStages;
        _localTrafficAlerts = trafficAlerts;
        _localIsLoading = false;
      });
    }
  }

  PalkhiInfo? get _effectivePalkhi => widget.palkhi ?? _localPalkhi;
  List<DindiMarkerInfo> get _effectiveDindis => widget.dindis ?? _localDindis;
  List<WariService> get _effectiveServices => widget.services ?? _localServices;
  List<WariRouteStage> get _effectiveRouteStages => widget.routeStages ?? _localRouteStages;
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

  void _addRouteLineAndMarkers() async {
    if (_mapController == null) return;

    final List<LatLng> coords = [];
    if (_effectiveRouteStages.isNotEmpty) {
      coords.addAll(
        _effectiveRouteStages.map(
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
        ],
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
