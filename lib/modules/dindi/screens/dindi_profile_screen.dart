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
  late String _selectedLifecycleStatus;

  bool _isSaving = false;

  static const List<String> _roadStatusOptions = [
    'Clear & Moving',
    'Slow',
    'Crowded',
    'Temporarily Blocked',
  ];

  static const List<String> _lifecycleStatusOptions = [
    'Active',
    'Halted',
    'Completed',
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
    _selectedLifecycleStatus = _lifecycleStatusOptions.contains(dindi.status)
        ? dindi.status
        : _lifecycleStatusOptions.first;
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

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _service.updateDindiProfile(
        name: _nameController.text.trim(),
        dindiNumber: _numberController.text.trim(),
        leaderName: _leaderNameController.text.trim(),
        leaderPhone: _phoneController.text.trim(),
        startPoint: _startPointController.text.trim(),
        destination: _destinationController.text.trim(),
        currentHalt: _haltController.text.trim(),
        roadStatus: _selectedRoadStatus,
        status: _selectedLifecycleStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dindi information updated successfully!'),
          backgroundColor: AppColors.dindiAccent,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update Dindi: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
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

  Color _getLifecycleStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green.shade700;
      case 'Halted':
        return Colors.amber.shade800;
      case 'Completed':
        return Colors.blue.shade700;
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
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _isSaving ? null : _saveProfile,
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
                    labelText: 'Dindi Troupe Name *',
                    hintText: 'e.g. Shree Tukaram Maharaj Dindi',
                    prefixIcon: const Icon(Icons.group_outlined),
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
                    labelText: 'Dindi Number *',
                    hintText: 'e.g. 12 or DND-001',
                    prefixIcon: const Icon(Icons.numbers_outlined),
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

                // Dindi Lifecycle Status Section
                const Text(
                  'Dindi Lifecycle Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set current operational lifecycle state for this Dindi:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedLifecycleStatus,
                  decoration: InputDecoration(
                    labelText: 'Operational Status *',
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                      color: _getLifecycleStatusColor(_selectedLifecycleStatus),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _lifecycleStatusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _getLifecycleStatusColor(status),
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
                        _selectedLifecycleStatus = value;
                      });
                    }
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
                    labelText: 'Leader Display Name *',
                    hintText: 'e.g. Sanket Maharaj',
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
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Leader Phone *',
                    hintText: '+91 98220 12345',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter contact phone';
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
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dindiAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Saving Changes...' : 'Save Dindi Information',
                    style: const TextStyle(
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
