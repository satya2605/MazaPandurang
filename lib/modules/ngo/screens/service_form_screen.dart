import 'package:flutter/material.dart';
// Conditional import: web uses dart:html canvas picker; others use stub.
import 'package:maza_pandurang/modules/ngo/widgets/image_picker_stub.dart'
    if (dart.library.html) 'package:maza_pandurang/modules/ngo/widgets/image_picker_web.dart';

import '../models/ngo_service.dart';
import '../models/ngo_service_details.dart';
import '../services/ngo_image_service.dart';
import '../services/ngo_repository.dart';

/// Form screen for creating a new Seva Service or editing an existing service.
/// Features full category-specific fields, emergency support, ambulance setup,
/// emergency contacts management, facilities & accessibility chips, and image uploads.
class ServiceFormScreen extends StatefulWidget {
  final NgoService? serviceToEdit;

  const ServiceFormScreen({
    super.key,
    this.serviceToEdit,
  });

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Information
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  NgoServiceCategory _selectedCategory = NgoServiceCategory.food;

  // Photos
  final List<String> _imageUrls = [];
  bool _isUploadingImage = false;

  // Location & Coordinates
  late TextEditingController _locationNameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  // Availability & General Capacity
  late TextEditingController _capacityController;
  late TextEditingController _hoursController;
  bool _is24Hours = true;
  ServiceAvailability _selectedAvailability = ServiceAvailability.available;

  // ── Category-Specific Controllers ──────────────────────────────────────────
  // Food
  final TextEditingController _mealsPerDayController = TextEditingController();
  final TextEditingController _beneficiariesController =
      TextEditingController();
  final TextEditingController _mealTimingController = TextEditingController();
  final TextEditingController _foodTypeController = TextEditingController();

  // Medical & Emergency
  final TextEditingController _doctorsController = TextEditingController();
  final TextEditingController _nursesController = TextEditingController();
  final TextEditingController _bedsController = TextEditingController();
  final TextEditingController _medicinesController = TextEditingController();
  final TextEditingController _medicalTimingController =
      TextEditingController();
  bool _emergencySupportAvailable = false;
  bool _ambulanceAvailable = false;
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _ambulancePhoneController =
      TextEditingController();
  final TextEditingController _emergencyInstructionsController =
      TextEditingController();
  final List<Map<String, String>> _emergencyContacts = [];

  // Water
  final TextEditingController _waterLitresController = TextEditingController();
  final TextEditingController _waterPointsController = TextEditingController();
  final TextEditingController _refillAvailabilityController =
      TextEditingController();

  // Shelter
  final TextEditingController _shelterBedsController = TextEditingController();
  final TextEditingController _shelterOccupancyController =
      TextEditingController();
  final TextEditingController _remainingBedsController =
      TextEditingController();
  bool _separateWomenShelter = false;

  // Contact Information
  late TextEditingController _phoneController;
  final TextEditingController _altPhoneController = TextEditingController();
  bool _isWhatsAppAvailable = false;

  // Facilities & Accessibility (optional chips)
  final Set<String> _selectedFacilities = {};
  static const List<String> _facilityOptions = [
    'Wheelchair Accessible',
    'Drinking Water',
    'Seating Available',
    'Accessible Toilet',
    'Senior Citizen Friendly',
  ];

  // Important Instructions
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final edit = widget.serviceToEdit;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _descriptionController =
        TextEditingController(text: edit?.description ?? '');
    _locationNameController =
        TextEditingController(text: edit?.locationName ?? '');
    _latController =
        TextEditingController(text: edit?.latitude.toString() ?? '17.6775');
    _lngController =
        TextEditingController(text: edit?.longitude.toString() ?? '75.3260');
    _capacityController = TextEditingController(text: edit?.capacity ?? '');
    _hoursController =
        TextEditingController(text: edit?.operatingHours ?? '24 Hours Open');
    _is24Hours =
        (edit?.operatingHours.toLowerCase().contains('24') ?? true) == true;
    _phoneController = TextEditingController(
        text: edit?.contactPhone ?? NgoRepository().organization.phone);

    if (edit != null) {
      _selectedCategory = edit.category;
      _selectedAvailability = edit.availability;
      if (edit.imageUrl != null) _imageUrls.add(edit.imageUrl!);
      _imageUrls.addAll(edit.additionalImageUrls);

      _altPhoneController.text = edit.alternateContactPhone ?? '';
      _isWhatsAppAvailable = edit.whatsappAvailable;
      _instructionsController.text = edit.importantInstructions ?? '';

      _emergencySupportAvailable = edit.emergencySupportAvailable;
      _ambulanceAvailable = edit.ambulanceAvailable;
      _emergencyPhoneController.text = edit.emergencyContactPhone ?? '';
      _ambulancePhoneController.text = edit.ambulanceContactPhone ?? '';
      _emergencyInstructionsController.text = edit.emergencyInstructions ?? '';

      for (final contact in edit.emergencyContacts) {
        _emergencyContacts.add({
          'name': contact['name']?.toString() ?? '',
          'phone': contact['phone']?.toString() ?? '',
          'role': contact['role']?.toString() ?? 'Coordinator',
        });
      }

      if (edit.wheelchairAccessible) {
        _selectedFacilities.add('Wheelchair Accessible');
      }
      if (edit.drinkingWaterAvailable) {
        _selectedFacilities.add('Drinking Water');
      }
      if (edit.seatingAvailable) {
        _selectedFacilities.add('Seating Available');
      }
      if (edit.accessibleToilet) {
        _selectedFacilities.add('Accessible Toilet');
      }
      if (edit.seniorCitizenFriendly) {
        _selectedFacilities.add('Senior Citizen Friendly');
      }

      // Pre-populate category-specific fields from details or categoryDetails
      final details = edit.details;
      final catDetails = edit.categoryDetails;
      _mealsPerDayController.text = details?.mealsPerDay?.toString() ??
          catDetails['meals_per_day']?.toString() ??
          '';
      _beneficiariesController.text =
          details?.beneficiariesPerDay?.toString() ??
              catDetails['beneficiaries_per_day']?.toString() ??
              '';
      _mealTimingController.text = catDetails['meal_timing']?.toString() ?? '';
      _foodTypeController.text = catDetails['food_type']?.toString() ?? '';

      _doctorsController.text = details?.doctorsAvailable?.toString() ??
          catDetails['doctors_available']?.toString() ??
          '';
      _nursesController.text = catDetails['nurses_available']?.toString() ?? '';
      _bedsController.text = details?.bedsAvailable?.toString() ??
          catDetails['beds_available']?.toString() ??
          '';
      _medicinesController.text = details?.medicinesAvailable ??
          catDetails['medicines_first_aid_available']?.toString() ??
          '';
      _medicalTimingController.text =
          catDetails['medical_timing']?.toString() ?? '';

      _waterLitresController.text =
          details?.waterCapacityLitresPerDay?.toString() ??
              catDetails['water_capacity_litres_per_day']?.toString() ??
              '';
      _waterPointsController.text = details?.waterTapsCount?.toString() ??
          catDetails['water_taps']?.toString() ??
          '';
      _refillAvailabilityController.text =
          catDetails['refill_availability']?.toString() ?? '';

      _shelterBedsController.text = details?.availableSpaces?.toString() ??
          catDetails['available_beds_spaces']?.toString() ??
          '';
      _shelterOccupancyController.text = details?.currentOccupancy ??
          catDetails['current_occupancy']?.toString() ??
          '';
      _remainingBedsController.text =
          catDetails['remaining_beds']?.toString() ?? '';
      _separateWomenShelter = catDetails['separate_women_shelter'] == true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _capacityController.dispose();
    _hoursController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _mealsPerDayController.dispose();
    _beneficiariesController.dispose();
    _mealTimingController.dispose();
    _foodTypeController.dispose();
    _doctorsController.dispose();
    _nursesController.dispose();
    _bedsController.dispose();
    _medicinesController.dispose();
    _medicalTimingController.dispose();
    _emergencyPhoneController.dispose();
    _ambulancePhoneController.dispose();
    _emergencyInstructionsController.dispose();
    _waterLitresController.dispose();
    _waterPointsController.dispose();
    _refillAvailabilityController.dispose();
    _shelterBedsController.dispose();
    _shelterOccupancyController.dispose();
    _remainingBedsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _applyLocationPreset(String name, double lat, double lng) {
    setState(() {
      _locationNameController.text = name;
      _latController.text = lat.toString();
      _lngController.text = lng.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected Wari location preset: $name')),
    );
  }

  Future<void> _pickAndAddImage() async {
    setState(() => _isUploadingImage = true);

    try {
      final picked = await webPickAndCompressImage(
        maxDimension: 800,
        quality: 0.78,
      );
      if (picked == null || !mounted) return;

      // Add local preview immediately
      setState(() {
        _imageUrls.add(picked.dataUrl);
      });

      // Background upload to Supabase Storage
      final tempId = widget.serviceToEdit?.id ??
          'srv-${DateTime.now().millisecondsSinceEpoch}';
      final supabaseUrl = await NgoImageService.uploadServiceImage(
        serviceId: tempId,
        jpegBytes: picked.bytes,
      );

      if (mounted && supabaseUrl != null) {
        setState(() {
          final idx = _imageUrls.indexOf(picked.dataUrl);
          if (idx != -1) {
            _imageUrls[idx] = supabaseUrl;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _addEmergencyContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedRole = 'Doctor';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_call, color: Color(0xFFD32F2F)),
              SizedBox(width: 8),
              Text('Add Emergency Contact', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Name / Team *',
                  hintText: 'e.g., Dr. Ramesh Patil',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '+91 98230 11223',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role / Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Doctor', child: Text('Doctor / Physician')),
                  DropdownMenuItem(
                      value: 'Ambulance',
                      child: Text('Ambulance Driver / Unit')),
                  DropdownMenuItem(
                      value: 'Nurse', child: Text('Nurse / Paramedic')),
                  DropdownMenuItem(
                      value: 'Coordinator', child: Text('Camp Coordinator')),
                  DropdownMenuItem(
                      value: 'Emergency', child: Text('24/7 Emergency Line')),
                ],
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedRole = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty &&
                    phoneCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _emergencyContacts.add({
                      'name': nameCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'role': selectedRole,
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _buildCategoryDetailsJson() {
    final map = <String, dynamic>{};
    switch (_selectedCategory) {
      case NgoServiceCategory.food:
        if (_mealsPerDayController.text.trim().isNotEmpty) {
          map['meals_per_day'] =
              int.tryParse(_mealsPerDayController.text.trim()) ??
                  _mealsPerDayController.text.trim();
        }
        if (_beneficiariesController.text.trim().isNotEmpty) {
          map['beneficiaries_per_day'] =
              int.tryParse(_beneficiariesController.text.trim()) ??
                  _beneficiariesController.text.trim();
        }
        if (_mealTimingController.text.trim().isNotEmpty) {
          map['meal_timing'] = _mealTimingController.text.trim();
        }
        if (_foodTypeController.text.trim().isNotEmpty) {
          map['food_type'] = _foodTypeController.text.trim();
        }
        break;
      case NgoServiceCategory.medical:
        if (_doctorsController.text.trim().isNotEmpty) {
          map['doctors_available'] =
              int.tryParse(_doctorsController.text.trim()) ??
                  _doctorsController.text.trim();
        }
        if (_nursesController.text.trim().isNotEmpty) {
          map['nurses_available'] =
              int.tryParse(_nursesController.text.trim()) ??
                  _nursesController.text.trim();
        }
        if (_bedsController.text.trim().isNotEmpty) {
          map['beds_available'] = int.tryParse(_bedsController.text.trim()) ??
              _bedsController.text.trim();
        }
        if (_medicinesController.text.trim().isNotEmpty) {
          map['medicines_first_aid_available'] =
              _medicinesController.text.trim();
        }
        if (_medicalTimingController.text.trim().isNotEmpty) {
          map['medical_timing'] = _medicalTimingController.text.trim();
        }
        break;
      case NgoServiceCategory.water:
        if (_waterLitresController.text.trim().isNotEmpty) {
          map['water_capacity_litres_per_day'] =
              int.tryParse(_waterLitresController.text.trim()) ??
                  _waterLitresController.text.trim();
        }
        if (_waterPointsController.text.trim().isNotEmpty) {
          map['water_taps'] =
              int.tryParse(_waterPointsController.text.trim()) ??
                  _waterPointsController.text.trim();
        }
        if (_refillAvailabilityController.text.trim().isNotEmpty) {
          map['refill_availability'] =
              _refillAvailabilityController.text.trim();
        }
        break;
      case NgoServiceCategory.shelter:
        if (_shelterBedsController.text.trim().isNotEmpty) {
          map['available_beds_spaces'] =
              int.tryParse(_shelterBedsController.text.trim()) ??
                  _shelterBedsController.text.trim();
        }
        if (_shelterOccupancyController.text.trim().isNotEmpty) {
          map['current_occupancy'] = _shelterOccupancyController.text.trim();
        }
        if (_remainingBedsController.text.trim().isNotEmpty) {
          map['remaining_beds'] = _remainingBedsController.text.trim();
        }
        map['separate_women_shelter'] = _separateWomenShelter;
        break;
      default:
        break;
    }

    if (_emergencyContacts.isNotEmpty) {
      map['emergency_contacts'] = _emergencyContacts;
    }
    return map;
  }

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final double lat = double.tryParse(_latController.text.trim()) ?? 17.6775;
      final double lng = double.tryParse(_lngController.text.trim()) ?? 75.3260;
      final isEditing = widget.serviceToEdit != null;

      final primaryImage = _imageUrls.isNotEmpty ? _imageUrls.first : null;
      final additionalImages =
          _imageUrls.length > 1 ? _imageUrls.sublist(1) : <String>[];

      final serviceDetails = NgoServiceDetails(
        serviceCapacity: _capacityController.text.trim().isNotEmpty
            ? _capacityController.text.trim()
            : _getCategorySpecificCapacitySummary(),
        operatingHours:
            _is24Hours ? '24 Hours Open' : _hoursController.text.trim(),
        isOpen24Hours: _is24Hours,
        mealsPerDay: int.tryParse(_mealsPerDayController.text.trim()),
        beneficiariesPerDay: int.tryParse(_beneficiariesController.text.trim()),
        doctorsAvailable: int.tryParse(_doctorsController.text.trim()),
        bedsAvailable: int.tryParse(_bedsController.text.trim()),
        medicinesAvailable: _medicinesController.text.trim().isNotEmpty
            ? _medicinesController.text.trim()
            : null,
        waterCapacityLitresPerDay:
            int.tryParse(_waterLitresController.text.trim()),
        waterTapsCount: int.tryParse(_waterPointsController.text.trim()),
        availableSpaces: int.tryParse(_shelterBedsController.text.trim()),
        currentOccupancy: _shelterOccupancyController.text.trim().isNotEmpty
            ? _shelterOccupancyController.text.trim()
            : null,
        alternateContactPhone: _altPhoneController.text.trim().isNotEmpty
            ? _altPhoneController.text.trim()
            : null,
        whatsappAvailable: _isWhatsAppAvailable,
        wheelchairAccessible:
            _selectedFacilities.contains('Wheelchair Accessible'),
        drinkingWater: _selectedFacilities.contains('Drinking Water'),
        seatingAvailable: _selectedFacilities.contains('Seating Available'),
        accessibleToilet: _selectedFacilities.contains('Accessible Toilet'),
        seniorCitizenFriendly:
            _selectedFacilities.contains('Senior Citizen Friendly'),
        importantInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      );

      final service = NgoService(
        id: isEditing
            ? widget.serviceToEdit!.id
            : 'srv-${DateTime.now().millisecondsSinceEpoch}',
        ngoId: NgoRepository().organization.id,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        latitude: lat,
        longitude: lng,
        locationName: _locationNameController.text.trim(),
        capacity: _capacityController.text.trim().isNotEmpty
            ? _capacityController.text.trim()
            : _getCategorySpecificCapacitySummary(),
        operatingHours:
            _is24Hours ? '24 Hours Open' : _hoursController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        availability: _selectedAvailability,
        lastUpdatedAt: DateTime.now(),
        isApproved: isEditing
            ? widget.serviceToEdit!.isApproved
            : false, // Moderation gate: awaits Admin verification
        imageUrl: primaryImage,
        additionalImageUrls: additionalImages,
        alternateContactPhone: _altPhoneController.text.trim().isNotEmpty
            ? _altPhoneController.text.trim()
            : null,
        whatsappAvailable: _isWhatsAppAvailable,
        wheelchairAccessible:
            _selectedFacilities.contains('Wheelchair Accessible'),
        drinkingWaterAvailable: _selectedFacilities.contains('Drinking Water'),
        seatingAvailable: _selectedFacilities.contains('Seating Available'),
        accessibleToilet: _selectedFacilities.contains('Accessible Toilet'),
        seniorCitizenFriendly:
            _selectedFacilities.contains('Senior Citizen Friendly'),
        importantInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
        emergencySupportAvailable: _emergencySupportAvailable,
        ambulanceAvailable: _ambulanceAvailable,
        emergencyContactPhone: _emergencyPhoneController.text.trim().isNotEmpty
            ? _emergencyPhoneController.text.trim()
            : null,
        ambulanceContactPhone: _ambulancePhoneController.text.trim().isNotEmpty
            ? _ambulancePhoneController.text.trim()
            : null,
        emergencyInstructions:
            _emergencyInstructionsController.text.trim().isNotEmpty
                ? _emergencyInstructionsController.text.trim()
                : null,
        emergencyContacts: _emergencyContacts,
        details: serviceDetails,
        categoryDetails: _buildCategoryDetailsJson(),
      );

      if (isEditing) {
        NgoRepository().updateService(service);
      } else {
        NgoRepository().addService(service);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? 'Seva Service details updated successfully!'
              : 'New Seva Service submitted! Awaiting Admin verification before appearing publicly.'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  String _getCategorySpecificCapacitySummary() {
    switch (_selectedCategory) {
      case NgoServiceCategory.food:
        if (_mealsPerDayController.text.trim().isNotEmpty) {
          return '${_mealsPerDayController.text.trim()} meals/day';
        }
        break;
      case NgoServiceCategory.medical:
        if (_bedsController.text.trim().isNotEmpty) {
          return '${_bedsController.text.trim()} beds available';
        }
        break;
      case NgoServiceCategory.water:
        if (_waterLitresController.text.trim().isNotEmpty) {
          return '${_waterLitresController.text.trim()} L/day';
        }
        break;
      case NgoServiceCategory.shelter:
        if (_shelterBedsController.text.trim().isNotEmpty) {
          return '${_shelterBedsController.text.trim()} beds/spaces';
        }
        break;
      default:
        break;
    }
    return 'Open Capacity';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.serviceToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Seva Service' : 'Add New Seva Service'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Update Service Details'
                      : 'Register New Seva Service',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Provide detailed seva facility information for Warkaris. New submissions undergo Admin moderation before public map display.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 18),

                // ─────────────────────────────────────────────────────────────
                // Section 1: Basic Information
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Basic Information',
                  icon: Icons.info_outline,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Service Name *',
                        hintText: 'e.g., Vitthal Seva Annachhatra Camp',
                        prefixIcon: Icon(Icons.volunteer_activism),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter service name'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<NgoServiceCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Service Category *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: NgoServiceCategory.values.map((cat) {
                        final dummy = NgoService(
                          id: '',
                          ngoId: '',
                          name: '',
                          category: cat,
                          description: '',
                          latitude: 0,
                          longitude: 0,
                          locationName: '',
                          capacity: '',
                          operatingHours: '',
                          contactPhone: '',
                          availability: ServiceAvailability.available,
                          lastUpdatedAt: DateTime.now(),
                        );
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(dummy.categoryLabel),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description / Facilities Offered *',
                        hintText:
                            'e.g., Free hot meals 24/7, clean seating, resting area for pilgrims...',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter service description'
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 2: Service Photos
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Service Photos',
                  icon: Icons.photo_camera,
                  children: [
                    const Text(
                      'Upload photos of your actual seva facility or service.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 12),
                    if (_imageUrls.isNotEmpty) ...[
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _imageUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final url = _imageUrls[index];
                            final isCover = index == 0;
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 140,
                                    height: 100,
                                    child: _buildThumbnailImage(url),
                                  ),
                                ),
                                if (isCover)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E7D32),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'COVER',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    OutlinedButton.icon(
                      onPressed: _isUploadingImage ? null : _pickAndAddImage,
                      icon: _isUploadingImage
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_photo_alternate),
                      label: Text(_imageUrls.isEmpty
                          ? 'Add Cover Photo'
                          : 'Add Additional Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        minimumSize: const Size.fromHeight(44),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 3: Category-Specific Details & Capacity
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title:
                      '${_selectedCategory.name.toUpperCase()} Seva Specifics & Capacity',
                  icon: Icons.tune,
                  children: [
                    _buildCategorySpecificFields(),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(
                        labelText: 'General Service Capacity',
                        hintText: 'e.g., 500 meals/hr, 50 beds, 5000 Litres',
                        prefixIcon: Icon(Icons.people_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 4: Medical Emergency & Ambulance Support (If Medical or Enabled)
                // ─────────────────────────────────────────────────────────────
                if (_selectedCategory == NgoServiceCategory.medical ||
                    _emergencySupportAvailable)
                  _buildSectionCard(
                    title: 'Emergency Medical & Ambulance Support',
                    icon: Icons.emergency,
                    accentColor: const Color(0xFFD32F2F),
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('24/7 Emergency Medical Support',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                            'Immediate on-site triage, doctor on call, or emergency first aid'),
                        value: _emergencySupportAvailable,
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFFD32F2F),
                        onChanged: (val) =>
                            setState(() => _emergencySupportAvailable = val),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dedicated Ambulance Available',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                            'Ambulance vehicle stationed at this seva location'),
                        value: _ambulanceAvailable,
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFFD32F2F),
                        onChanged: (val) =>
                            setState(() => _ambulanceAvailable = val),
                      ),
                      if (_ambulanceAvailable) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _ambulancePhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Ambulance Driver / Unit Hotline',
                            hintText: '+91 98230 99999',
                            prefixIcon: Icon(Icons.airport_shuttle,
                                color: Color(0xFFD32F2F)),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Medical Contact Number',
                          hintText: '+91 98230 11223',
                          prefixIcon: Icon(Icons.phone_in_talk,
                              color: Color(0xFFD32F2F)),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emergencyInstructionsController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Response Instructions',
                          hintText:
                              'e.g., Direct emergency walk-ins to Gate 1 medical tent; call ambulance unit immediately.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                if (_selectedCategory == NgoServiceCategory.medical ||
                    _emergencySupportAvailable)
                  const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 5: Emergency & Key Contacts Directory
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Emergency Contacts & On-Ground Team',
                  icon: Icons.contact_phone,
                  children: [
                    if (_emergencyContacts.isNotEmpty) ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _emergencyContacts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final c = _emergencyContacts[idx];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      const Color(0xFF2E7D32).withAlpha(30),
                                  child: const Icon(Icons.person,
                                      size: 18, color: Color(0xFF2E7D32)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        '${c['role']} • ${c['phone']}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _emergencyContacts.removeAt(idx);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    OutlinedButton.icon(
                      onPressed: _addEmergencyContactDialog,
                      icon: const Icon(Icons.add_call),
                      label:
                          const Text('Add On-Ground Contact / Doctor / Driver'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        minimumSize: const Size.fromHeight(42),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 6: Location & Coordinates
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Location & Coordinates',
                  icon: Icons.location_on,
                  children: [
                    TextFormField(
                      controller: _locationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Location / Landmark Address *',
                        hintText:
                            'e.g., Pandharpur Bypass Road, Near Temple Chowk',
                        prefixIcon: Icon(Icons.pin_drop),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter location landmark'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Preset Wari Locations:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          label: const Text('Pandharpur Solapur Naka'),
                          onPressed: () => _applyLocationPreset(
                              'Pandharpur Solapur Naka', 17.6775, 75.3260),
                        ),
                        ActionChip(
                          label: const Text('Wakhari Ringan Ground'),
                          onPressed: () => _applyLocationPreset(
                              'Wakhari Ringan Ground', 17.6820, 75.3180),
                        ),
                        ActionChip(
                          label: const Text('ISKCON Chowk'),
                          onPressed: () => _applyLocationPreset(
                              'ISKCON Chowk', 17.6740, 75.3310),
                        ),
                        ActionChip(
                          label: const Text('Saswad Palkhi Ground'),
                          onPressed: () => _applyLocationPreset(
                              'Saswad Palkhi Ground', 18.3411, 74.0305),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Latitude *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Invalid'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Longitude *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Invalid'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 7: Operating Hours & Live Availability
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Operating Hours & Availability',
                  icon: Icons.event_available,
                  children: [
                    TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Operating Hours',
                        hintText: 'e.g., 24 Hours Open or 6:00 AM - 10:00 PM',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Open 24 Hours',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle:
                          const Text('Facility operational round-the-clock'),
                      value: _is24Hours,
                      // ignore: deprecated_member_use
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (val) {
                        setState(() {
                          _is24Hours = val;
                          if (val) {
                            _hoursController.text = '24 Hours Open';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<ServiceAvailability>(
                      initialValue: _selectedAvailability,
                      decoration: const InputDecoration(
                        labelText: 'Initial Availability Status',
                        prefixIcon: Icon(Icons.traffic),
                        border: OutlineInputBorder(),
                      ),
                      items: ServiceAvailability.values.map((avail) {
                        return DropdownMenuItem(
                          value: avail,
                          child: Text(avail.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedAvailability = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 8: Primary Contact
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Primary Contact',
                  icon: Icons.phone,
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Primary Contact Phone Number',
                        hintText: '+91 98000 00000',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Alternate Contact Number (Optional)',
                        hintText: '+91 98000 00001',
                        prefixIcon: Icon(Icons.phone_iphone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('WhatsApp Available on Contact Number'),
                      value: _isWhatsAppAvailable,
                      activeColor: const Color(0xFF2E7D32),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setState(() {
                          _isWhatsAppAvailable = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 9: Facilities & Accessibility
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Facilities & Accessibility',
                  icon: Icons.accessible,
                  children: [
                    const Text(
                      'Select available amenities for pilgrims:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _facilityOptions.map((facility) {
                        final isSelected =
                            _selectedFacilities.contains(facility);
                        return FilterChip(
                          label: Text(facility),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2E7D32).withAlpha(40),
                          checkmarkColor: const Color(0xFF2E7D32),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFacilities.add(facility);
                              } else {
                                _selectedFacilities.remove(facility);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─────────────────────────────────────────────────────────────
                // Section 10: Important Instructions
                // ─────────────────────────────────────────────────────────────
                _buildSectionCard(
                  title: 'Important Instructions / Notes',
                  icon: Icons.notes,
                  children: [
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Important Instructions (Optional)',
                        hintText:
                            'Add any important information pilgrims should know before using this service (e.g., token system, entry gates)...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveService,
                  icon: Icon(isEditing ? Icons.save : Icons.add_circle),
                  label: Text(
                    isEditing
                        ? 'Update Service Details'
                        : 'Submit Seva Service for Verification',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final color = accentColor ?? const Color(0xFF2E7D32);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: accentColor != null
                ? color.withAlpha(100)
                : const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor ?? const Color(0xFF212121),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpecificFields() {
    switch (_selectedCategory) {
      case NgoServiceCategory.food:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mealsPerDayController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Meals Per Day',
                      hintText: 'e.g., 5000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _beneficiariesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Approx. Beneficiaries/Day',
                      hintText: 'e.g., 3000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mealTimingController,
                    decoration: const InputDecoration(
                      labelText: 'Meal Serving Timings',
                      hintText: 'e.g., 11:00 AM - 3:00 PM & 7:00 PM - 10:00 PM',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _foodTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Type of Food / Menu',
                      hintText: 'e.g., Mahaprasad, Khichdi, Tea',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case NgoServiceCategory.medical:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _doctorsController,
                    decoration: const InputDecoration(
                      labelText: 'Doctors Available',
                      hintText: 'e.g., 4 General Physicians',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _nursesController,
                    decoration: const InputDecoration(
                      labelText: 'Nurses / Medical Staff',
                      hintText: 'e.g., 6 Paramedics',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Beds Available',
                      hintText: 'e.g., 10 Beds',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _medicalTimingController,
                    decoration: const InputDecoration(
                      labelText: 'Doctor OPD Hours',
                      hintText: 'e.g., 24/7 or 8 AM - 8 PM',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _medicinesController,
              decoration: const InputDecoration(
                labelText: 'Medicines / First Aid Available',
                hintText:
                    'e.g., Pain relief, IV fluids, blister dressings, ORS',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case NgoServiceCategory.water:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _waterLitresController,
                    decoration: const InputDecoration(
                      labelText: 'Water Capacity (Litres/Day)',
                      hintText: 'e.g., 10000 Litres',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _waterPointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'No. of Water Taps/Points',
                      hintText: 'e.g., 12 Taps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _refillAvailabilityController,
              decoration: const InputDecoration(
                labelText: 'Refill & Tanker Availability',
                hintText:
                    'e.g., Municipal tanker connected, refilled every 4 hours',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      case NgoServiceCategory.shelter:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _shelterBedsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Capacity (Beds/Spaces)',
                      hintText: 'e.g., 150',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _shelterOccupancyController,
                    decoration: const InputDecoration(
                      labelText: 'Current Occupancy',
                      hintText: 'e.g., 40 / 150',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _remainingBedsController,
              decoration: const InputDecoration(
                labelText: 'Remaining Available Spaces',
                hintText: 'e.g., 110 spaces free',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Separate Area for Women & Families'),
              value: _separateWomenShelter,
              activeColor: const Color(0xFF2E7D32),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) =>
                  setState(() => _separateWomenShelter = val ?? false),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildThumbnailImage(String url) {
    if (url.startsWith('data:')) {
      try {
        final bytes = UriData.fromString(url).contentAsBytes();
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(color: Colors.grey.shade200);
      }
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
