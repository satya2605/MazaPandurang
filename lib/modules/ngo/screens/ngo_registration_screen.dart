import 'package:flutter/material.dart';
import '../services/ngo_repository.dart';

/// Screen for NGO organization onboarding and self-registration.
class NgoRegistrationScreen extends StatefulWidget {
  const NgoRegistrationScreen({super.key});

  @override
  State<NgoRegistrationScreen> createState() => _NgoRegistrationScreenState();
}

class _NgoRegistrationScreenState extends State<NgoRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedCategory = 'Food & Medical Seva';

  final List<String> _categories = [
    'Food & Medical Seva',
    'Drinking Water & Sanitation',
    'Shelter & Accommodation',
    'General Wari Volunteer Support',
    'Lost & Found Assistance',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _regNoController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      NgoRepository().registerOrganization(
        name: _nameController.text.trim(),
        registrationNo: _regNoController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        primaryCategory: _selectedCategory,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'NGO Registration Submitted! Status: PENDING Admin Approval.'),
          backgroundColor: Color(0xFFE65100),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Onboarding Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Register Your Seva Organization',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Provide your trust/organization details. Registered NGOs require administrative verification before listings appear on the public map.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'NGO / Trust Name *',
                    hintText: 'e.g. Sant Dnyaneshwar Seva Mandal',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter NGO Name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _regNoController,
                  decoration: const InputDecoration(
                    labelText: 'Government Registration / Trust No. *',
                    hintText: 'e.g. NGO/MH/2022/9900',
                    prefixIcon: Icon(Icons.verified),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter Registration No.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Person Name *',
                    hintText: 'e.g. Ramesh Patil (Trustee)',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter Contact Person'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Phone Number *',
                    hintText: '+91 98000 00000',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().length < 10
                      ? 'Enter valid phone number'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'contact@sevamandal.org',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Primary Seva Focus Category',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
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
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _submitRegistration,
                  icon: const Icon(Icons.how_to_reg),
                  label: const Text('Submit NGO Registration'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
