import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';
import '../repositories/api_pilgrim_repository.dart';
import '../repositories/pilgrim_repository.dart';
import '../services/location_service.dart';
import '../widgets/emergency_sos_button.dart';
import '../widgets/emergency_status_card.dart';

/// Unified Emergency & Safety Screen for Pilgrim Module.
class EmergencyScreen extends StatefulWidget {
  final PilgrimRepository? repository;
  final String? initialEmergencyType;

  const EmergencyScreen({
    super.key,
    this.repository,
    this.initialEmergencyType,
  });

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  late final PilgrimRepository _repository;
  final LocationService _locationService = LocationService();
  final TextEditingController _descController = TextEditingController();

  String _selectedType = 'Medical';
  PilgrimLocation? _userLocation;
  LocationPermissionStatus _locationStatus = LocationPermissionStatus.notRequested;
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;

  EmergencyRequest? _latestDispatchedSos;
  List<EmergencyRequest> _myRequests = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ApiPilgrimRepository();
    if (widget.initialEmergencyType != null && widget.initialEmergencyType!.isNotEmpty) {
      _selectedType = widget.initialEmergencyType!;
    }
    _initLocationAndHistory();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndHistory() async {
    setState(() => _isLoadingLocation = true);

    final status = await _locationService.requestPermission();
    final location = await _locationService.getCurrentLocation();
    final history = await _repository.getEmergencyRequests();

    if (mounted) {
      setState(() {
        _locationStatus = status;
        _userLocation = location;
        _isLoadingLocation = false;
        _myRequests = history;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _handleSosDispatch() async {
    setState(() => _isSubmitting = true);
    final lat = _userLocation?.position.latitude ?? 18.3411;
    final lng = _userLocation?.position.longitude ?? 74.0305;
    final locationName = _userLocation != null
        ? 'Near ${_userLocation!.name} (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})'
        : 'Wari Route (Location Unavailable)';

    try {
      final req = await _repository.createEmergencyRequest(
        emergencyType: _selectedType,
        latitude: lat,
        longitude: lng,
        locationName: locationName,
        description: _descController.text.trim(),
      );

      final updatedHistory = await _repository.getEmergencyRequests();

      if (mounted) {
        setState(() {
          _latestDispatchedSos = req;
          _myRequests = updatedHistory;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text('✅ Emergency SOS ${req.requestCode} dispatched!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('❌ Unable to reach emergency service: $e'),
          ),
        );
      }
    }
  }

  Widget _buildGpsStatusBanner() {
    if (_isLoadingLocation) {
      return const LinearProgressIndicator();
    }

    final isGranted = _locationStatus == LocationPermissionStatus.granted;
    final bannerColor = isGranted ? Colors.blue.shade50 : Colors.amber.shade50;
    final textColor = isGranted ? Colors.blue.shade900 : Colors.amber.shade900;
    final icon = isGranted ? Icons.gps_fixed : Icons.gps_off;

    final subtitle = isGranted
        ? 'GPS coordinates ready: ${_userLocation?.position.latitude.toStringAsFixed(4)}, ${_userLocation?.position.longitude.toStringAsFixed(4)}'
        : 'Location unavailable. Your SOS can still be submitted safely.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchedConfirmation() {
    final req = _latestDispatchedSos!;
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 52),
            const SizedBox(height: 10),
            const Text(
              'SOS DISPATCHED',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 6),
            Text(
              'Request ID: ${req.requestCode}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('Type: ${req.emergencyType} | Status: ${req.status.toUpperCase()}'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _latestDispatchedSos = null);
                    },
                    child: const Text('Send Another SOS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency & Safety (आपत्कालीन सेवा)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGpsStatusBanner(),
            const SizedBox(height: 16),

            if (_latestDispatchedSos != null) ...[
              _buildDispatchedConfirmation(),
              const SizedBox(height: 20),
            ],

            // Emergency SOS Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Emergency Assistance Type',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Medical', 'Police', 'Lost Person', 'Other'].map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: Colors.red.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.red.shade900 : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => setState(() => _selectedType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: 'Optional details (situation, landmark, condition)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    EmergencySosButton(
                      emergencyType: _selectedType,
                      isLoading: _isSubmitting,
                      onConfirmedSubmit: _handleSosDispatch,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Request History
            const Text(
              'My Emergency Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_myRequests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No past emergency requests found.', style: TextStyle(color: Colors.grey)),
              )
            else
              ..._myRequests.map((req) => EmergencyStatusCard(request: req)),
          ],
        ),
      ),
    );
  }
}
