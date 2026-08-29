import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_service.dart';

/// Privileged Palkhi Location Operator Screen.
/// Provides assigned location operators with a dedicated, isolated interface
/// to transmit live GPS coordinates and stage updates for their assigned Palkhi.
class PalkhiOperatorScreen extends StatefulWidget {
  const PalkhiOperatorScreen({super.key});

  @override
  State<PalkhiOperatorScreen> createState() => _PalkhiOperatorScreenState();
}

class _PalkhiOperatorScreenState extends State<PalkhiOperatorScreen> {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _assignedPalkhi;
  String? _errorMessage;

  final TextEditingController _stageController = TextEditingController();
  final TextEditingController _nextStopController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAssignedPalkhi();
  }

  @override
  void dispose() {
    _stageController.dispose();
    _nextStopController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchAssignedPalkhi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiClient.get('/palkhi');
      Map<String, dynamic>? target;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List && decoded.isNotEmpty) {
          target = decoded.first as Map<String, dynamic>;
        } else if (decoded is Map<String, dynamic>) {
          target = decoded;
        }
      }

      if (mounted) {
        setState(() {
          _assignedPalkhi = target;
          _isLoading = false;
          if (target != null) {
            _stageController.text = target['currentStage']?.toString() ?? '';
            _nextStopController.text = target['nextStop']?.toString() ?? '';
            _latController.text = target['latitude']?.toString() ?? '18.3411';
            _lngController.text = target['longitude']?.toString() ?? '74.0305';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not fetch assigned Palkhi. Error: $e';
        });
      }
    }
  }

  Future<void> _submitLocationUpdate() async {
    if (_assignedPalkhi == null) return;
    final palkhiId = _assignedPalkhi!['id']?.toString();
    if (palkhiId == null) return;

    setState(() => _isUpdating = true);

    try {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());

      if (lat == null || lng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid numeric latitude and longitude coordinates.')),
        );
        setState(() => _isUpdating = false);
        return;
      }

      await _apiClient.patch('/palkhi/$palkhiId/location', body: {
        'latitude': lat,
        'longitude': lng,
        'current_stage': _stageController.text.trim(),
        'next_stop': _nextStopController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚡ Palkhi live location updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchAssignedPalkhi();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location update failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _authService.currentProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Palkhi Location Operator (पालखी ट्रॅकर)'),
        backgroundColor: Colors.orange.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAssignedPalkhi,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.orange.shade50,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.orange.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Operator: ${profile?['display_name'] ?? 'Privileged Operator'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'LOCATION OPERATOR',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            _assignedPalkhi != null
                                ? 'Assigned Palkhi: ${_assignedPalkhi!['name'] ?? 'Sant Dnyaneshwar Maharaj Palkhi'}'
                                : 'Your account has not been assigned an active Palkhi.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (_assignedPalkhi != null) ...[
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Update Live Palkhi Location',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _stageController,
                              decoration: const InputDecoration(
                                labelText: 'Current Stage / Location Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _nextStopController,
                              decoration: const InputDecoration(
                                labelText: 'Next Stop / Destination Stage',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.navigation),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _latController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Latitude',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _lngController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Longitude',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isUpdating ? null : _submitLocationUpdate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              icon: _isUpdating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(_isUpdating ? 'Transmitting...' : 'TRANSMIT LIVE LOCATION'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
