import 'package:flutter/material.dart';
import '../models/ngo_service.dart';
import '../services/ngo_repository.dart';

/// Form screen for creating a new Seva Service or editing an existing service.
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
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationNameController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _capacityController;
  late TextEditingController _hoursController;
  late TextEditingController _phoneController;

  NgoServiceCategory _selectedCategory = NgoServiceCategory.food;
  ServiceAvailability _selectedAvailability = ServiceAvailability.available;

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
    _phoneController = TextEditingController(
        text: edit?.contactPhone ?? NgoRepository().organization.phone);

    if (edit != null) {
      _selectedCategory = edit.category;
      _selectedAvailability = edit.availability;
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

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final double lat = double.tryParse(_latController.text.trim()) ?? 17.6775;
      final double lng = double.tryParse(_lngController.text.trim()) ?? 75.3260;

      final isEditing = widget.serviceToEdit != null;

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
        capacity: _capacityController.text.trim(),
        operatingHours: _hoursController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        availability: _selectedAvailability,
        lastUpdatedAt: DateTime.now(),
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
              : 'New Seva Service created & active!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );

      Navigator.of(context).pop();
    }
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
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update Service Details' : 'Seva Service Listing',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name *',
                    hintText: 'e.g. Annachhatra / Medical Camp Name',
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
                        'e.g., Free meals 24/7, doctor availability, blister treatment...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter service description'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Location & Coordinates (Map Data)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _locationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Location / Landmark Address *',
                    hintText: 'e.g., Pandharpur Bypass Road, Near Temple Chowk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter location landmark'
                      : null,
                ),
                const SizedBox(height: 10),
                // Wari Location Presets
                const Text(
                  'Preset Wari Locations:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
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
                  ],
                ),
                const SizedBox(height: 10),
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
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Invalid' : null,
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
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Service Capacity',
                          hintText: 'e.g. 500 meals/hr',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController,
                        decoration: const InputDecoration(
                          labelText: 'Operating Hours',
                          hintText: 'e.g. 24 Hours Open',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<ServiceAvailability>(
                  initialValue: _selectedAvailability,
                  decoration: const InputDecoration(
                    labelText: 'Initial Availability Status',
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
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _saveService,
                  icon: Icon(isEditing ? Icons.save : Icons.add_circle),
                  label: Text(isEditing
                      ? 'Update Service Details'
                      : 'Publish Seva Service'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
