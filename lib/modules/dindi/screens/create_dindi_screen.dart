import 'dart:math';
import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../services/dindi_state_service.dart';
import 'dindi_dashboard_screen.dart';

/// Screen allowing a Dindi Leader to create and register a new Dindi.
class CreateDindiScreen extends StatefulWidget {
  const CreateDindiScreen({super.key});

  @override
  State<CreateDindiScreen> createState() => _CreateDindiScreenState();
}

class _CreateDindiScreenState extends State<CreateDindiScreen> {
  final _formKey = GlobalKey<FormState>();
  final DindiStateService _service = DindiStateService();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _startPointController;
  late TextEditingController _destinationController;
  late TextEditingController _haltController;
  late TextEditingController _joinCodeController;

  String _selectedRoadStatus = 'Clear & Moving';
  bool _isSubmitting = false;

  static const List<String> _roadStatusOptions = [
    'Clear & Moving',
    'Slow',
    'Crowded',
    'Temporarily Blocked',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _startPointController = TextEditingController(text: 'Alandi');
    _destinationController = TextEditingController(text: 'Pandharpur');
    _haltController = TextEditingController();
    _joinCodeController = TextEditingController(text: _generateJoinCode());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _startPointController.dispose();
    _destinationController.dispose();
    _haltController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  void _regenerateJoinCode() {
    setState(() {
      _joinCodeController.text = _generateJoinCode();
    });
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final createdDindi = await _service.createDindi(
        name: _nameController.text.trim(),
        dindiNumber: _numberController.text.trim(),
        startPoint: _startPointController.text.trim(),
        destination: _destinationController.text.trim(),
        currentHalt: _haltController.text.trim(),
        roadStatus: _selectedRoadStatus,
        joinCode: _joinCodeController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dindi "${createdDindi.name}" created successfully!'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );

      // Open dashboard for the newly created Dindi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DindiDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create Dindi: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitForm,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Dindi'),
        backgroundColor: AppColors.dindiAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dindiAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dindiAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.dindiAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Registering as leader: ${_service.identityProvider.currentLeaderName}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Dindi Details
                const Text(
                  'Dindi Identification',
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
                    labelText: 'Dindi Number / Sequence *',
                    hintText: 'e.g. 12 or DND-012',
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

                // Journey & Route Section
                const Text(
                  'Route & Current Halt',
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
                          hintText: 'e.g. Alandi',
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
                  'Current Road Condition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRoadStatus,
                  decoration: InputDecoration(
                    labelText: 'Road Status *',
                    prefixIcon: const Icon(Icons.traffic),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _roadStatusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
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
                const SizedBox(height: 20),

                // Join Code Section
                const Text(
                  'Join Code for Warkaris',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Warkaris will use this code to send join requests to your Dindi:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _joinCodeController,
                  readOnly: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 18,
                    color: AppColors.dindiAccent,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Unique Join Code',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Regenerate Code',
                      onPressed: _regenerateJoinCode,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dindiAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_circle_outline),
                  label: Text(
                    _isSubmitting
                        ? 'Creating Dindi...'
                        : 'Register Dindi Procession',
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
