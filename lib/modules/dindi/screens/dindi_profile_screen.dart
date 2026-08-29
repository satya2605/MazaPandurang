import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../services/dindi_state_service.dart';

class DindiProfileScreen extends StatefulWidget {
  const DindiProfileScreen({super.key});

  @override
  State<DindiProfileScreen> createState() => _DindiProfileScreenState();
}

class _DindiProfileScreenState extends State<DindiProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final DindiStateService _service = DindiStateService();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _leaderNameController;
  late TextEditingController _phoneController;
  late TextEditingController _startPointController;
  late TextEditingController _destinationController;
  late TextEditingController _haltController;
  late String _selectedRoadStatus;

  static const List<String> _roadStatusOptions = [
    'Clear & Moving',
    'Slow',
    'Crowded',
    'Temporarily Blocked',
  ];

  @override
  void initState() {
    super.initState();
    final dindi = _service.dindiGroup;
    _nameController = TextEditingController(text: dindi.name);
    _numberController = TextEditingController(text: dindi.dindiNumber);
    _leaderNameController = TextEditingController(text: dindi.leaderName);
    _phoneController = TextEditingController(text: dindi.leaderPhone);
    _startPointController = TextEditingController(text: dindi.startPoint);
    _destinationController = TextEditingController(text: dindi.destination);
    _haltController = TextEditingController(text: dindi.currentHalt);
    _selectedRoadStatus = _roadStatusOptions.contains(dindi.roadStatus)
        ? dindi.roadStatus
        : _roadStatusOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _leaderNameController.dispose();
    _phoneController.dispose();
    _startPointController.dispose();
    _destinationController.dispose();
    _haltController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      _service.updateDindiProfile(
        name: _nameController.text.trim(),
        dindiNumber: _numberController.text.trim(),
        leaderName: _leaderNameController.text.trim(),
        leaderPhone: _phoneController.text.trim(),
        startPoint: _startPointController.text.trim(),
        destination: _destinationController.text.trim(),
        currentHalt: _haltController.text.trim(),
        roadStatus: _selectedRoadStatus,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dindi information updated successfully!'),
          backgroundColor: AppColors.dindiAccent,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    }
  }

  Color _getRoadStatusColor(String status) {
    switch (status) {
      case 'Clear & Moving':
        return Colors.green.shade700;
      case 'Slow':
      case 'Crowded':
        return Colors.orange.shade800;
      case 'Temporarily Blocked':
        return Colors.red.shade700;
      default:
        return AppColors.dindiAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dindi Information'),
        backgroundColor: AppColors.dindiAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // General Dindi Information Section
                const Text(
                  'Dindi Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Dindi Name *',
                    hintText: 'e.g. Shree Tukaram Maharaj Dindi',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Dindi name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Dindi Registration / Number *',
                    hintText: 'e.g. 12',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Dindi number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Leader Information Section
                const Text(
                  'Leader Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _leaderNameController,
                  decoration: InputDecoration(
                    labelText: 'Leader Name *',
                    hintText: 'e.g. Sanket Patil',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter leader name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Leader Phone / Contact *',
                    hintText: 'e.g. +91 98220 12345',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter leader contact';
                    }
                    if (value.trim().length < 8) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Journey & Route Section
                const Text(
                  'Journey & Current Halt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startPointController,
                        decoration: InputDecoration(
                          labelText: 'Origin *',
                          hintText: 'e.g. Dehu',
                          prefixIcon: const Icon(Icons.trip_origin),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter origin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: 'Destination *',
                          hintText: 'e.g. Pandharpur',
                          prefixIcon: const Icon(Icons.pin_drop_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter destination';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _haltController,
                  decoration: InputDecoration(
                    labelText: 'Current Halt Location *',
                    hintText: 'e.g. Akurdi Vitthal Mandir',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter current halt location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Road Status Section
                const Text(
                  'Road Status / Condition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select current road condition for your Dindi segment:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRoadStatus,
                  decoration: InputDecoration(
                    labelText: 'Road Condition *',
                    prefixIcon: Icon(
                      Icons.traffic,
                      color: _getRoadStatusColor(_selectedRoadStatus),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _roadStatusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _getRoadStatusColor(status),
                          ),
                          const SizedBox(width: 8),
                          Text(status),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRoadStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 28),

                // Save Button
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dindiAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Save Dindi Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
