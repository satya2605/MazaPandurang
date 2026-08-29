import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maza_pandurang/modules/ngo/widgets/image_picker_stub.dart'
    if (dart.library.html) 'package:maza_pandurang/modules/ngo/widgets/image_picker_web.dart';

import '../models/ambulance_record.dart';
import '../models/doctor_record.dart';
import '../models/ngo_service.dart';
import '../services/ngo_image_service.dart';
import '../services/ngo_repository.dart';
import 'service_form_screen.dart';

/// Universal Pilgrim-Facing & Volunteer Seva Detail Screen Template.
/// Dynamically renders common structural layout + type-specific category modules.
class ServiceDetailScreen extends StatefulWidget {
  final NgoService service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late NgoService _currentService;
  bool _imageUploading = false;
  String? _uploadStatus;
  bool _showAllDoctors = true;

  @override
  void initState() {
    super.initState();
    _currentService = widget.service;
  }

  void _makeCall(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_forwarded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Calling $phoneNumber (Copied to dialer)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openMap(double lat, double lng, String locationName) {
    Clipboard.setData(ClipboardData(text: '$lat, $lng'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.map, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Opening Map for "$locationName" ($lat, $lng)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1976D2),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openEditScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceFormScreen(serviceToEdit: _currentService),
        settings: const RouteSettings(name: '/edit_service'),
      ),
    );

    final updated = NgoRepository().services.firstWhere(
        (s) => s.id == _currentService.id,
        orElse: () => _currentService);
    if (mounted) {
      setState(() {
        _currentService = updated;
      });
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  void _openChangeStatusDialog() {
    ServiceAvailability selectedAvail = _currentService.availability;
    final bedsTotalCtrl = TextEditingController(
        text: _currentService.totalBeds?.toString() ?? '50');
    final bedsAvailCtrl = TextEditingController(
        text: _currentService.availableBedsCount?.toString() ?? '12');
    final bedsOccupiedCtrl = TextEditingController(
        text: _currentService.occupiedBeds?.toString() ?? '38');

    final docTotalCtrl = TextEditingController(
        text: _currentService.totalDoctors?.toString() ?? '4');
    final docAvailCtrl = TextEditingController(
        text: _currentService.availableDoctorsCount?.toString() ?? '2');
    final docOnDutyCtrl = TextEditingController(
        text: _currentService.onDutyDoctors?.toString() ?? '2');

    final ambTotalCtrl = TextEditingController(
        text: _currentService.totalAmbulances?.toString() ?? '3');
    final ambAvailCtrl = TextEditingController(
        text: _currentService.availableAmbulancesCount?.toString() ?? '1');
    final ambOnTripCtrl = TextEditingController(
        text: _currentService.onTripAmbulances?.toString() ?? '2');

    final mealsCtrl = TextEditingController(
        text: _currentService.details?.mealsPerDay?.toString() ?? '5000');
    final spacesCtrl = TextEditingController(
        text: _currentService.details?.availableSpaces?.toString() ?? '160');
    final waterCtrl = TextEditingController(
        text: _currentService.details?.waterCapacityLitresPerDay?.toString() ??
            '10000');

    bool emergencySupport = _currentService.emergencySupportAvailable;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Live Status & Resource Controls',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Overall Service Availability:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('AVAILABLE')),
                        selected:
                            selectedAvail == ServiceAvailability.available,
                        selectedColor: const Color(0xFF2E7D32),
                        labelStyle: TextStyle(
                          color: selectedAvail == ServiceAvailability.available
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() =>
                                selectedAvail = ServiceAvailability.available);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('LIMITED')),
                        selected: selectedAvail == ServiceAvailability.limited,
                        selectedColor: const Color(0xFFF57C00),
                        labelStyle: TextStyle(
                          color: selectedAvail == ServiceAvailability.limited
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() =>
                                selectedAvail = ServiceAvailability.limited);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('UNAVAILABLE')),
                        selected:
                            selectedAvail == ServiceAvailability.unavailable,
                        selectedColor: const Color(0xFFD32F2F),
                        labelStyle: TextStyle(
                          color:
                              selectedAvail == ServiceAvailability.unavailable
                                  ? Colors.white
                                  : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() => selectedAvail =
                                ServiceAvailability.unavailable);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Category-specific Controls
                if (_currentService.category == NgoServiceCategory.medical) ...[
                  const Text('Bed Capacity Updates:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: bedsTotalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Beds',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: bedsAvailCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Available Beds',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: bedsOccupiedCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Occupied Beds',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Doctor Staffing Updates:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: docTotalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Doctors',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: docAvailCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Available Now',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: docOnDutyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'On Duty',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Ambulance Fleet Status:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ambTotalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Ambulances',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ambAvailCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Available',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: ambOnTripCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'On Trip',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (_currentService.category ==
                    NgoServiceCategory.food) ...[
                  const Text('Food & Meal Output Updates:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: mealsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Meals Output / Capacity (Meals/Day)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ] else if (_currentService.category ==
                    NgoServiceCategory.shelter) ...[
                  const Text('Shelter Capacity Updates:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: spacesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available Sleeping Spaces / Beds',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ] else if (_currentService.category ==
                    NgoServiceCategory.water) ...[
                  const Text('Water Capacity Updates:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: waterCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Water Capacity (Litres/Day)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Emergency Triage / Trauma Support Active',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: emergencySupport,
                  activeTrackColor: const Color(0xFFD32F2F),
                  onChanged: (val) =>
                      setModalState(() => emergencySupport = val),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final updated = _currentService.copyWith(
                        availability: selectedAvail,
                        totalBeds: int.tryParse(bedsTotalCtrl.text),
                        availableBeds: int.tryParse(bedsAvailCtrl.text),
                        occupiedBeds: int.tryParse(bedsOccupiedCtrl.text),
                        totalDoctors: int.tryParse(docTotalCtrl.text),
                        availableDoctors: int.tryParse(docAvailCtrl.text),
                        onDutyDoctors: int.tryParse(docOnDutyCtrl.text),
                        totalAmbulances: int.tryParse(ambTotalCtrl.text),
                        availableAmbulances: int.tryParse(ambAvailCtrl.text),
                        onTripAmbulances: int.tryParse(ambOnTripCtrl.text),
                        emergencySupportAvailable: emergencySupport,
                        lastUpdatedAt: DateTime.now(),
                      );
                      NgoRepository().updateService(updated);
                      setState(() => _currentService = updated);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Live status updated in real time'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    },
                    child: const Text('Save & Publish Live Status',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndAddImage() async {
    setState(() {
      _imageUploading = true;
      _uploadStatus = 'Selecting image...';
    });

    try {
      final picked = await webPickAndCompressImage(
        maxDimension: 800,
        quality: 0.78,
      );
      if (picked == null || !mounted) {
        setState(() {
          _imageUploading = false;
          _uploadStatus = null;
        });
        return;
      }

      setState(() => _uploadStatus = 'Uploading to Supabase storage...');
      final publicUrl = await NgoImageService.uploadServiceImage(
        serviceId: _currentService.id,
        jpegBytes: picked.bytes,
      );

      final updatedAdditional =
          List<String>.from(_currentService.additionalImageUrls);
      String? updatedPrimary = _currentService.imageUrl;

      if (updatedPrimary == null) {
        updatedPrimary = publicUrl ?? picked.dataUrl;
      } else {
        updatedAdditional.add(publicUrl ?? picked.dataUrl);
      }

      final updatedService = _currentService.copyWith(
        imageUrl: updatedPrimary,
        additionalImageUrls: updatedAdditional,
      );

      NgoRepository().updateService(updatedService);

      setState(() {
        _currentService = updatedService;
        _imageUploading = false;
        _uploadStatus = null;
      });
    } catch (e) {
      setState(() {
        _imageUploading = false;
        _uploadStatus = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload notice: $e'),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    }
  }

  void _removeImage(String url) {
    String? newPrimary = _currentService.imageUrl;
    final newAdditional =
        List<String>.from(_currentService.additionalImageUrls);

    if (newPrimary == url) {
      newPrimary = newAdditional.isNotEmpty ? newAdditional.removeAt(0) : null;
    } else {
      newAdditional.remove(url);
    }

    final updated = _currentService.copyWith(
      imageUrl: newPrimary,
      additionalImageUrls: newAdditional,
    );
    NgoRepository().updateService(updated);
    setState(() {
      _currentService = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _currentService;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          s.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Service Details',
            onPressed: _openEditScreen,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section 1: Header + Category Badge + Title ───────────────
              _buildHeaderSection(s),
              const SizedBox(height: 12),

              // ── Multi-image Gallery Container ────────────────────────────
              _ServiceImageGallery(
                service: s,
                isUploading: _imageUploading,
                uploadStatus: _uploadStatus,
                onAddImage: _pickAndAddImage,
                onRemoveImage: _removeImage,
              ),
              const SizedBox(height: 14),

              // ── Section 2: Live Availability Status Card ─────────────────
              _buildLiveAvailabilityStatusCard(s),
              const SizedBox(height: 14),

              // ── Section 3: Emergency Support (Conditional) ───────────────
              if (s.emergencySupportAvailable ||
                  s.ambulanceAvailable ||
                  s.category == NgoServiceCategory.emergency) ...[
                _buildEmergencyAndAmbulanceCard(s),
                const SizedBox(height: 14),
              ],

              // ── Section 4: Service-Specific Information (Dynamic Modules) ─
              _buildCategorySpecificModule(s),
              const SizedBox(height: 14),

              // ── Section 5: Seva Overview & Description ───────────────────
              _buildOverviewAndDescriptionCard(s),
              const SizedBox(height: 14),

              // ── Section 6: Location & Coordinates ────────────────────────
              _buildLocationCard(s),
              const SizedBox(height: 14),

              // ── Section 7: Contact & Inquiry ─────────────────────────────
              _buildContactCard(s),
              const SizedBox(height: 14),

              // ── Section 8: Last Updated Timestamp ────────────────────────
              _buildLastUpdatedFooter(s),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 1: HEADER + CATEGORY BADGE + TITLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeaderSection(NgoService s) {
    Color catColor = const Color(0xFF2E7D32);
    IconData catIcon = Icons.volunteer_activism;

    switch (s.category) {
      case NgoServiceCategory.medical:
        catColor = const Color(0xFFC62828);
        catIcon = Icons.local_hospital_outlined;
        break;
      case NgoServiceCategory.food:
        catColor = const Color(0xFFE65100);
        catIcon = Icons.restaurant_outlined;
        break;
      case NgoServiceCategory.water:
        catColor = const Color(0xFF0277BD);
        catIcon = Icons.water_drop_outlined;
        break;
      case NgoServiceCategory.shelter:
        catColor = const Color(0xFF4527A0);
        catIcon = Icons.night_shelter_outlined;
        break;
      case NgoServiceCategory.clothing:
        catColor = const Color(0xFFAD1457);
        catIcon = Icons.checkroom_outlined;
        break;
      case NgoServiceCategory.sanitation:
        catColor = const Color(0xFF00695C);
        catIcon = Icons.wc_outlined;
        break;
      case NgoServiceCategory.volunteer:
        catColor = const Color(0xFF1565C0);
        catIcon = Icons.support_agent_outlined;
        break;
      case NgoServiceCategory.emergency:
        catColor = const Color(0xFFD32F2F);
        catIcon = Icons.emergency_outlined;
        break;
      default:
        catColor = const Color(0xFF2E7D32);
        catIcon = Icons.volunteer_activism;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: catColor.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: catColor.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(catIcon, size: 14, color: catColor),
              const SizedBox(width: 6),
              Text(
                s.categoryLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: catColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Service Name Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                s.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  height: 1.25,
                ),
              ),
            ),
            if (s.isApproved) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified, size: 20, color: Color(0xFF2E7D32)),
            ],
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 2: LIVE AVAILABILITY STATUS CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLiveAvailabilityStatusCard(NgoService s) {
    Color badgeColor;
    String badgeText;
    switch (s.availability) {
      case ServiceAvailability.available:
        badgeColor = const Color(0xFF2E7D32);
        badgeText = 'AVAILABLE';
        break;
      case ServiceAvailability.limited:
        badgeColor = const Color(0xFFF57C00);
        badgeText = 'LIMITED';
        break;
      case ServiceAvailability.unavailable:
        badgeColor = const Color(0xFFD32F2F);
        badgeText = 'CLOSED';
        break;
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Status Badge + Change Status Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.sensors, size: 16, color: Color(0xFF2E7D32)),
                    SizedBox(width: 6),
                    Text(
                      'Live Availability Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeColor.withAlpha(70)),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _openChangeStatusDialog,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFF2E7D32).withAlpha(50)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.tune,
                                size: 13, color: Color(0xFF2E7D32)),
                            SizedBox(width: 4),
                            Text(
                              'Change Status',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Real-Time Availability Metrics (Only Category-Relevant Data)
            _buildCategoryRelevantSummaryRow(s),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRelevantSummaryRow(NgoService s) {
    switch (s.category) {
      case NgoServiceCategory.medical:
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.hotel,
              label: 'Beds',
              countText: '${s.availableBedsCount ?? 12} Available',
              color: const Color(0xFF1976D2),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.medical_services,
              label: 'Doctors',
              countText: '${s.availableDoctorsCount ?? 2} Available',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.emergency,
              label: 'Ambulances',
              countText: '${s.availableAmbulancesCount ?? 1} Available',
              color: const Color(0xFFD32F2F),
            ),
          ],
        );

      case NgoServiceCategory.food:
        final meals = s.details?.mealsPerDay ?? 5000;
        final beneficiaries = s.details?.beneficiariesPerDay ?? 3500;
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.restaurant,
              label: 'Meals Today',
              countText: '$meals Capacity',
              color: const Color(0xFFE65100),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.people,
              label: 'Pilgrims Served',
              countText: '$beneficiaries+ Served',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.access_time,
              label: 'Batch Status',
              countText: s.availability == ServiceAvailability.available
                  ? 'Ready to Serve'
                  : 'Batch Prep',
              color: const Color(0xFF1565C0),
            ),
          ],
        );

      case NgoServiceCategory.shelter:
        final total = s.details?.availableSpaces ?? 200;
        final avail = s.details?.availableSpaces != null
            ? (s.details!.availableSpaces! * 0.8).toInt()
            : 160;
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.night_shelter,
              label: 'Sleeping Spaces',
              countText: '$avail Spaces Avail',
              color: const Color(0xFF4527A0),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.family_restroom,
              label: 'Total Capacity',
              countText: '$total Pilgrims',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.bed,
              label: 'Bedding',
              countText: 'Clean Mats & Shawls',
              color: const Color(0xFF0277BD),
            ),
          ],
        );

      case NgoServiceCategory.water:
        final litres = s.details?.waterCapacityLitresPerDay ?? 10000;
        final taps = s.details?.waterTapsCount ?? 20;
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.water_drop,
              label: 'Water Capacity',
              countText: '$litres Litres/Day',
              color: const Color(0xFF0277BD),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.water,
              label: 'Dispenser Points',
              countText: '$taps Active Taps',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.verified_user,
              label: 'Water Source',
              countText: 'RO Filtered Pure',
              color: const Color(0xFF1565C0),
            ),
          ],
        );

      case NgoServiceCategory.clothing:
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.checkroom,
              label: 'Vastra Stock',
              countText: '500+ Sets in Stock',
              color: const Color(0xFFAD1457),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.directions_walk,
              label: 'Paduka / Footwear',
              countText: 'Available Free',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.volunteer_activism,
              label: 'Daily Output',
              countText: '1,500 Sets/Day',
              color: const Color(0xFFE65100),
            ),
          ],
        );

      case NgoServiceCategory.sanitation:
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.wc,
              label: 'Bio-Toilets',
              countText: '26 Available Now',
              color: const Color(0xFF00695C),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.cleaning_services,
              label: 'Cleanliness',
              countText: 'Continuous Sanitized',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.shower,
              label: 'Running Water',
              countText: '24/7 Water Supply',
              color: const Color(0xFF0277BD),
            ),
          ],
        );

      case NgoServiceCategory.volunteer:
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.groups,
              label: 'On-Duty Volunteers',
              countText: '12 Active Now',
              color: const Color(0xFF1565C0),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.translate,
              label: 'Languages',
              countText: '5 Languages',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.record_voice_over,
              label: 'PA System',
              countText: 'Live Announcements',
              color: const Color(0xFFE65100),
            ),
          ],
        );

      case NgoServiceCategory.emergency:
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.emergency,
              label: 'Ambulance Units',
              countText: '${s.availableAmbulancesCount ?? 2} Standby',
              color: const Color(0xFFD32F2F),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.shield,
              label: 'Rescue Teams',
              countText: '2 Teams Active',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.medical_services,
              label: 'Trauma Readiness',
              countText: 'Code Green Active',
              color: const Color(0xFF1565C0),
            ),
          ],
        );

      default:
        return Row(
          children: [
            _buildSummaryBadge(
              icon: Icons.volunteer_activism,
              label: 'Capacity',
              countText: s.capacity,
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            _buildSummaryBadge(
              icon: Icons.schedule,
              label: 'Operating',
              countText: s.operatingHours,
              color: const Color(0xFF1565C0),
            ),
          ],
        );
    }
  }

  Widget _buildSummaryBadge({
    required IconData icon,
    required String label,
    required String countText,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              countText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 3: EMERGENCY SUPPORT & AMBULANCE (CONDITIONAL)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEmergencyAndAmbulanceCard(NgoService service) {
    final total = service.totalAmbulances ?? 3;
    final available = service.availableAmbulancesCount ?? 1;
    final onTrip = service.onTripAmbulances ?? 2;

    final ambulances = service.ambulancesList.isNotEmpty
        ? service.ambulancesList
        : [
            AmbulanceRecord(
              id: 'amb-1',
              vehicleNumber: 'MH-12-AB-1234',
              ambulanceType: 'BLS (Basic Life Support)',
              contactNumber: service.ambulanceContactPhone ?? '+91 98230 99999',
              status: 'Available',
              driverName: 'Ramesh Shinde',
              currentLocation: 'Camp Standby Gate 1',
            ),
            const AmbulanceRecord(
              id: 'amb-2',
              vehicleNumber: 'MH-12-CD-5678',
              ambulanceType: 'ALS (Advanced Cardiac Care)',
              contactNumber: '+91 98230 56789',
              status: 'On Trip',
              driverName: 'Santosh Pawar',
              currentLocation: 'En Route to Civil Hospital',
            ),
            const AmbulanceRecord(
              id: 'amb-3',
              vehicleNumber: 'MH-12-EF-9012',
              ambulanceType: 'BLS (Patient Transport)',
              contactNumber: '+91 98230 90123',
              status: 'On Trip',
              driverName: 'Vijay Jadhav',
              currentLocation: 'Palkhi Route KM 14',
            ),
          ];

    return Card(
      elevation: 0,
      color: const Color(0xFFFFF5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFEF5350), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emergency, color: Color(0xFFD32F2F), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Emergency Support & Ambulance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '24/7 ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Emergency Instructions banner
            if (service.emergencyInstructions != null &&
                service.emergencyInstructions!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service.emergencyInstructions!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF424242),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Fleet Summary Badges
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricPill(
                      label: 'Total Ambulances',
                      value: '$total',
                      color: const Color(0xFFB71C1C),
                    ),
                  ),
                  Container(width: 1, height: 28, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildMetricPill(
                      label: 'Available Now',
                      value: '$available',
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  Container(width: 1, height: 28, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildMetricPill(
                      label: 'On Trip',
                      value: '$onTrip',
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'OPERATIONAL AMBULANCE VEHICLES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Individual Ambulance Cards
            ...ambulances.map((amb) => _buildAmbulanceUnitCard(amb)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbulanceUnitCard(AmbulanceRecord amb) {
    final isAvail = amb.isAvailable;
    final statusColor =
        isAvail ? const Color(0xFF2E7D32) : const Color(0xFFE65100);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.emergency, size: 16, color: statusColor),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amb.vehicleNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        amb.ambulanceType,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withAlpha(60)),
                ),
                child: Text(
                  amb.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (amb.driverName != null || amb.currentLocation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (amb.driverName != null) ...[
                  Icon(Icons.person_pin, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Driver: ${amb.driverName}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 12),
                ],
                if (amb.currentLocation != null) ...[
                  Icon(Icons.location_on_outlined,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      amb.currentLocation!,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _makeCall(amb.contactNumber),
              icon: const Icon(Icons.phone, size: 16),
              label: const Text(
                'Call Ambulance',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 4: SERVICE-SPECIFIC INFORMATION (DYNAMIC MODULES)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCategorySpecificModule(NgoService s) {
    switch (s.category) {
      case NgoServiceCategory.medical:
        return _buildMedicalModule(s);
      case NgoServiceCategory.food:
        return _buildFoodModule(s);
      case NgoServiceCategory.shelter:
        return _buildShelterModule(s);
      case NgoServiceCategory.water:
        return _buildWaterModule(s);
      case NgoServiceCategory.clothing:
        return _buildClothingModule(s);
      case NgoServiceCategory.sanitation:
        return _buildSanitationModule(s);
      case NgoServiceCategory.volunteer:
        return _buildVolunteerModule(s);
      case NgoServiceCategory.emergency:
        return _buildEmergencyRescueModule(s);
      default:
        return _buildGeneralModule(s);
    }
  }

  // ── MODULE A: MEDICAL ──────────────────────────────────────────────────────
  Widget _buildMedicalModule(NgoService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBedAvailabilityCard(service),
        const SizedBox(height: 14),
        _buildDoctorAvailabilityCard(service),
      ],
    );
  }

  Widget _buildBedAvailabilityCard(NgoService service) {
    final total = service.totalBeds ?? 50;
    final avail = service.availableBedsCount ?? 12;
    final occupied = service.occupiedBeds ?? (total - avail);
    final generalAvail =
        service.generalBedsAvailable ?? (avail > 2 ? avail - 2 : avail);
    final icuAvail = service.icuBedsAvailable ?? (avail > 2 ? 2 : 0);

    final availFraction = total > 0 ? (avail / total).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hotel, size: 18, color: Color(0xFF1976D2)),
                SizedBox(width: 8),
                Text(
                  'Bed Availability',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metric Counters
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Beds',
                    value: '$total',
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Available Now',
                    value: '$avail',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Occupied',
                    value: '$occupied',
                    color: const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Capacity Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: availFraction,
                minHeight: 8,
                backgroundColor: Colors.orange.shade100,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            ),
            const SizedBox(height: 12),

            // Breakdown Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.single_bed,
                  label: 'General Beds: $generalAvail available',
                  color: const Color(0xFF1976D2),
                ),
                _buildSubtypeChip(
                  icon: Icons.local_hospital,
                  label: 'ICU Beds: $icuAvail available',
                  color: const Color(0xFFD32F2F),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorAvailabilityCard(NgoService service) {
    final total = service.totalDoctors ?? 4;
    final avail = service.availableDoctorsCount ?? 2;
    final onDuty = service.onDutyDoctors ?? 2;
    final emergency = service.emergencyDoctorsCount ?? 1;

    final doctors = service.doctorsList.isNotEmpty
        ? service.doctorsList
        : [
            const DoctorRecord(
              id: 'doc-1',
              name: 'Dr. Rajesh Kulkarni',
              specialization: 'MBBS, Emergency Medicine',
              status: 'Available Now',
              contactNumber: '+91 98230 44556',
              isEmergencyDoctor: true,
            ),
            const DoctorRecord(
              id: 'doc-2',
              name: 'Dr. Sneha Joshi',
              specialization: 'MD, General Physician',
              status: 'Available Now',
              contactNumber: '+91 98230 44557',
            ),
            const DoctorRecord(
              id: 'doc-3',
              name: 'Dr. Amit Deshmukh',
              specialization: 'Ortho & Trauma Specialist',
              status: 'On Duty',
              contactNumber: '+91 98230 44558',
            ),
            const DoctorRecord(
              id: 'doc-4',
              name: 'Dr. Priya Patil',
              specialization: 'Pediatric & Family Medicine',
              status: 'On Duty',
              contactNumber: '+91 98230 44559',
            ),
          ];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medical_services,
                        size: 18, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Doctor Availability',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _showAllDoctors = !_showAllDoctors),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFF2E7D32),
                  ),
                  child: Text(_showAllDoctors ? 'Hide List' : 'View Doctors'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Counters
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Doctors',
                    value: '$total',
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Available Now',
                    value: '$avail',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'On Duty',
                    value: '$onDuty',
                    color: const Color(0xFF1976D2),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Emergency',
                    value: '$emergency',
                    color: const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),

            if (_showAllDoctors) ...[
              const Divider(height: 24),
              const Text(
                'ON-GROUND MEDICAL TEAM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ...doctors.map((doc) => _buildDoctorRow(doc)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorRow(DoctorRecord doc) {
    final isAvail = doc.isAvailable;
    final statusColor =
        isAvail ? const Color(0xFF2E7D32) : const Color(0xFF1976D2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: statusColor.withAlpha(25),
            child: Icon(Icons.person, size: 18, color: statusColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        doc.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (doc.isEmergencyDoctor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFEF9A9A)),
                        ),
                        child: const Text(
                          'Emergency',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  doc.specialization,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              doc.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── MODULE B: FOOD / ANNACHHATRA ──────────────────────────────────────────
  Widget _buildFoodModule(NgoService s) {
    final meals = s.details?.mealsPerDay ?? 5000;
    final beneficiaries = s.details?.beneficiariesPerDay ?? 3500;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant_menu, size: 18, color: Color(0xFFE65100)),
                SizedBox(width: 8),
                Text(
                  'Food & Annachhatra Operations',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Meals / Day',
                    value: '$meals',
                    color: const Color(0xFFE65100),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Beneficiaries',
                    value: '$beneficiaries+',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Current Batch',
                    value: '850 Meals',
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'TODAY\'S SEVA MENU & FOOD DETAILS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.check_circle,
                  label: 'Hot Desi Ghee Khichdi',
                  color: const Color(0xFFE65100),
                ),
                _buildSubtypeChip(
                  icon: Icons.check_circle,
                  label: 'Pithla & Jowar Bhakri',
                  color: const Color(0xFF2E7D32),
                ),
                _buildSubtypeChip(
                  icon: Icons.check_circle,
                  label: 'Sabudana Khichdi (Upvas)',
                  color: const Color(0xFF1565C0),
                ),
                _buildSubtypeChip(
                  icon: Icons.check_circle,
                  label: 'Hot Herbal Tea & Jaggery',
                  color: const Color(0xFF6D4C41),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── MODULE C: SHELTER / VISHRAM DHAM ──────────────────────────────────────
  Widget _buildShelterModule(NgoService s) {
    final total = s.details?.availableSpaces ?? 200;
    final avail = (total * 0.8).toInt();
    final occupied = total - avail;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.night_shelter, size: 18, color: Color(0xFF4527A0)),
                SizedBox(width: 8),
                Text(
                  'Night Shelter & Rest Capacity',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Beds/Mats',
                    value: '$total',
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Available Now',
                    value: '$avail',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Occupied',
                    value: '$occupied',
                    color: const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total > 0 ? (avail / total) : 0.8,
                minHeight: 8,
                backgroundColor: Colors.purple.shade100,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4527A0)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.man,
                  label: 'Male Section: 80 Spaces',
                  color: const Color(0xFF1565C0),
                ),
                _buildSubtypeChip(
                  icon: Icons.woman,
                  label: 'Female & Children: 80 Spaces',
                  color: const Color(0xFFAD1457),
                ),
                _buildSubtypeChip(
                  icon: Icons.elderly,
                  label: 'Senior Citizen Priority: 40 Spaces',
                  color: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── MODULE D: WATER / JAL SEVA ────────────────────────────────────────────
  Widget _buildWaterModule(NgoService s) {
    final litres = s.details?.waterCapacityLitresPerDay ?? 10000;
    final taps = s.details?.waterTapsCount ?? 20;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.water_drop, size: 18, color: Color(0xFF0277BD)),
                SizedBox(width: 8),
                Text(
                  'Drinking Water & Jal Seva Hub',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Water Capacity',
                    value: '$litres L',
                    color: const Color(0xFF0277BD),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Active Taps',
                    value: '$taps Taps',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Refill Source',
                    value: 'Continuous Tanker',
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.ac_unit,
                  label: 'Chilled Filtered RO Water',
                  color: const Color(0xFF0277BD),
                ),
                _buildSubtypeChip(
                  icon: Icons.medication,
                  label: 'ORS Hydration Sachets Available',
                  color: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── MODULE E: CLOTHING / MATERIAL DISTRIBUTION ────────────────────────────
  Widget _buildClothingModule(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.checkroom, size: 18, color: Color(0xFFAD1457)),
                SizedBox(width: 8),
                Text(
                  'Vastra & Material Distribution',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Current Stock',
                    value: '500 Sets',
                    color: const Color(0xFFAD1457),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Daily Target',
                    value: '1,500 Sets',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Counter Status',
                    value: 'Open & Active',
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.checkroom,
                  label: 'Dhoti & Kurta Sets',
                  color: const Color(0xFFAD1457),
                ),
                _buildSubtypeChip(
                  icon: Icons.directions_walk,
                  label: 'Soft Foam Walking Chappals',
                  color: const Color(0xFF2E7D32),
                ),
                _buildSubtypeChip(
                  icon: Icons.umbrella,
                  label: 'Waterproof Raincoats',
                  color: const Color(0xFF0277BD),
                ),
                _buildSubtypeChip(
                  icon: Icons.bed,
                  label: 'Fleece Warm Blankets',
                  color: const Color(0xFF6D4C41),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── MODULE F: SANITATION / SWACCHATA ──────────────────────────────────────
  Widget _buildSanitationModule(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wc, size: 18, color: Color(0xFF00695C)),
                SizedBox(width: 8),
                Text(
                  'Bio-Toilet & Hygiene Complex',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Total Toilets',
                    value: '30 Units',
                    color: const Color(0xFF00695C),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Available Now',
                    value: '26 Units',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Sanitization',
                    value: 'Every 30 mins',
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.woman,
                  label: 'Ladies Changing & Bio-Toilets (14)',
                  color: const Color(0xFFAD1457),
                ),
                _buildSubtypeChip(
                  icon: Icons.man,
                  label: 'Gents Bio-Toilets (12)',
                  color: const Color(0xFF1565C0),
                ),
                _buildSubtypeChip(
                  icon: Icons.accessible,
                  label: 'Wheelchair Accessible Units (4)',
                  color: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── MODULE G: VOLUNTEER / HELP DESK ──────────────────────────────────────
  Widget _buildVolunteerModule(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent, size: 18, color: Color(0xFF1565C0)),
                SizedBox(width: 8),
                Text(
                  'Volunteer Assistance & Help Desk',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Active Volunteers',
                    value: '12 On Duty',
                    color: const Color(0xFF1565C0),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Languages',
                    value: '5 Supported',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'PA Speaker',
                    value: '24x7 Active',
                    color: const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.record_voice_over,
                  label: 'Lost Person PA Announcements',
                  color: const Color(0xFFE65100),
                ),
                _buildSubtypeChip(
                  icon: Icons.elderly,
                  label: 'Senior Citizen Route Escort',
                  color: const Color(0xFF2E7D32),
                ),
                _buildSubtypeChip(
                  icon: Icons.accessible,
                  label: 'Wheelchair Transit Assistance',
                  color: const Color(0xFF1565C0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── MODULE H: EMERGENCY / RESCUE ──────────────────────────────────────────
  Widget _buildEmergencyRescueModule(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield, size: 18, color: Color(0xFFD32F2F)),
                SizedBox(width: 8),
                Text(
                  'Emergency Disaster & River Rescue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Rescue Boats',
                    value: '4 Boats',
                    color: const Color(0xFF0277BD),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Standby Units',
                    value: '2 Teams',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Response Time',
                    value: '< 3 mins',
                    color: const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildSubtypeChip(
                  icon: Icons.sailing,
                  label: 'Chandrabhaga River Patrol',
                  color: const Color(0xFF0277BD),
                ),
                _buildSubtypeChip(
                  icon: Icons.medical_information,
                  label: 'Oxygen Resuscitation Onboard',
                  color: const Color(0xFFD32F2F),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── MODULE I: GENERAL FALLBACK ────────────────────────────────────────────
  Widget _buildGeneralModule(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Service Capacity & Timing',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Capacity',
                    value: s.capacity,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Operating Hours',
                    value: s.operatingHours,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 5: SEVA OVERVIEW & DESCRIPTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildOverviewAndDescriptionCard(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 18, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Seva Overview & Facilities',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              s.description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Operating Hours
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Operating Hours: ${s.operatingHours}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (s.operatingHours.toLowerCase().contains('24') ||
                      (s.details?.isOpen24Hours ?? false)) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '24x7 ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Facilities & Accessibility Checklist
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (s.wheelchairAccessible ||
                    (s.details?.wheelchairAccessible ?? false))
                  _buildFacilityChip(Icons.accessible, 'Wheelchair Accessible'),
                if (s.drinkingWaterAvailable ||
                    (s.details?.drinkingWater ?? false))
                  _buildFacilityChip(Icons.water_drop, 'Drinking Water'),
                if (s.seatingAvailable ||
                    (s.details?.seatingAvailable ?? false))
                  _buildFacilityChip(Icons.chair, 'Seating Available'),
                if (s.accessibleToilet ||
                    (s.details?.accessibleToilet ?? false))
                  _buildFacilityChip(Icons.wc, 'Clean Toilets'),
                if (s.seniorCitizenFriendly ||
                    (s.details?.seniorCitizenFriendly ?? false))
                  _buildFacilityChip(Icons.elderly, 'Senior Citizen Priority'),
                if (s.whatsappAvailable ||
                    (s.details?.whatsappAvailable ?? false))
                  _buildFacilityChip(Icons.chat, 'WhatsApp Updates Active'),
              ],
            ),

            if (s.importantInstructions != null &&
                s.importantInstructions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.campaign,
                        size: 16, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.importantInstructions!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 6: LOCATION & COORDINATES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLocationCard(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 18, color: Color(0xFF1976D2)),
                SizedBox(width: 8),
                Text(
                  'Location & Coordinates',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              s.locationName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coordinates: ${s.latitude.toStringAsFixed(4)}, ${s.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1976D2),
                  side: const BorderSide(color: Color(0xFF1976D2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () =>
                    _openMap(s.latitude, s.longitude, s.locationName),
                icon: const Icon(Icons.directions, size: 16),
                label: const Text(
                  'View on Map / Get Directions',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 7: CONTACT & INQUIRY
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildContactCard(NgoService s) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_in_talk, size: 18, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Contact & Inquiry',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF2E7D32).withAlpha(20),
                  child: const Icon(Icons.headset_mic,
                      size: 18, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'General Camp Desk / Inquiries',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        s.contactPhone,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (s.alternateContactPhone != null &&
                s.alternateContactPhone!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.phone,
                        size: 18, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alternate Helpline',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          s.alternateContactPhone!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _makeCall(s.contactPhone),
                icon: const Icon(Icons.call, size: 16),
                label: const Text(
                  'Call NGO',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION 8: LAST UPDATED FOOTER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLastUpdatedFooter(NgoService s) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.update, size: 13, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            'Last updated: ${_formatRelativeTime(s.lastUpdatedAt)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper UI Components ───────────────────────────────────────────────────

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSubtypeChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MULTI-IMAGE GALLERY WIDGET (REUSABLE ACROSS ALL CATEGORIES)
// ═════════════════════════════════════════════════════════════════════════════

class _ServiceImageGallery extends StatefulWidget {
  final NgoService service;
  final bool isUploading;
  final String? uploadStatus;
  final VoidCallback onAddImage;
  final void Function(String url) onRemoveImage;

  const _ServiceImageGallery({
    required this.service,
    required this.isUploading,
    required this.uploadStatus,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  State<_ServiceImageGallery> createState() => _ServiceImageGalleryState();
}

class _ServiceImageGalleryState extends State<_ServiceImageGallery> {
  int _selectedIndex = 0;

  List<String> get _allImages {
    final list = <String>[];
    if (widget.service.imageUrl != null &&
        widget.service.imageUrl!.isNotEmpty) {
      list.add(widget.service.imageUrl!);
    }
    for (final url in widget.service.additionalImageUrls) {
      if (url.isNotEmpty && !list.contains(url)) {
        list.add(url);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;
    final activeIndex = _selectedIndex < images.length ? _selectedIndex : 0;
    final activeUrl = images.isNotEmpty ? images[activeIndex] : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // Main Active Image Display
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (activeUrl != null) ...[
                    Image.network(
                      activeUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    _buildPlaceholder(),
                  ],

                  // Uploading overlay
                  if (widget.isUploading) ...[
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.uploadStatus ?? 'Uploading...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Top Action Buttons
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        if (activeUrl != null) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: Colors.white),
                              onPressed: () => widget.onRemoveImage(activeUrl),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF2E7D32),
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo,
                                size: 16, color: Colors.white),
                            tooltip: 'Add Photo',
                            onPressed: widget.onAddImage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Thumbnail Carousel if multiple images exist
            if (images.length > 1) ...[
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: Colors.white,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final isSelected = i == activeIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: Container(
                        width: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            images[i],
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                const Icon(Icons.broken_image, size: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 38,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 6),
            Text(
              'No facility photo uploaded',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
