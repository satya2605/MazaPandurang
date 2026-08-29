import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/navigation/app_routes.dart';
import '../auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  final List<Map<String, String>> _devPersonas = [
    {
      'name': 'Satyajit',
      'role': 'Pilgrim',
      'email': 'satyajit@mazapandurang.local',
      'uuid': '00000000-0000-0000-0000-000000000001',
    },
    {
      'name': 'Sanket',
      'role': 'Dindi Leader',
      'email': 'sanket@mazapandurang.local',
      'uuid': '00000000-0000-0000-0000-000000000002',
    },
    {
      'name': 'Yogeshwari',
      'role': 'Police',
      'email': 'yogeshwari@mazapandurang.local',
      'uuid': '00000000-0000-0000-0000-000000000003',
    },
    {
      'name': 'Shrutika',
      'role': 'NGO',
      'email': 'shrutika@mazapandurang.local',
      'uuid': '00000000-0000-0000-0000-000000000004',
    },
    {
      'name': 'Gauri',
      'role': 'Citizen',
      'email': 'gauri@mazapandurang.local',
      'uuid': '00000000-0000-0000-0000-000000000005',
    },
    {
      'name': 'Admin',
      'role': 'Admin',
      'email': 'admin@mazapandurang.local',
      'uuid': '00000000-0000-0000-0000-000000000006',
    },
  ];

  void _fillPersona(Map<String, String> persona) {
    _emailController.text = persona['email']!;
    _passwordController.text = 'Wari2026!Demo';
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter an email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // For dev personas using .local, route directly based on profile
      final persona = _devPersonas.firstWhere(
        (p) => p['email'] == email,
        orElse: () => {},
      );

      if (persona.isNotEmpty) {
        _navigateByRole(persona['role']!.toLowerCase().replaceAll(' ', '_'), 'active');
        return;
      }

      final profile = await _authService.fetchProfileById(persona.isNotEmpty ? persona['uuid']! : '00000000-0000-0000-0000-000000000001');

      if (profile != null && mounted) {
        final role = profile['role'] ?? 'local_citizen';
        final status = profile['status'] ?? 'active';
        _navigateByRole(role, status);
      } else if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
      }
    } catch (e) {
      _showMessage('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateByRole(String role, String status) {
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.admin);
    } else if (role == 'dindi_leader') {
      if (status == 'pending') {
        _showDindiStatusDialog('Your Dindi Leader application is awaiting Admin approval.');
      } else if (status == 'rejected') {
        _showDindiStatusDialog('Your Dindi Leader application was not approved.');
      } else if (status == 'suspended') {
        _showDindiStatusDialog('Your Dindi Leader access has been suspended.');
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.dindi);
      }
    } else if (role == 'police_authority' || role == 'police') {
      Navigator.pushReplacementNamed(context, AppRoutes.police);
    } else if (role == 'ngo_volunteer' || role == 'ngo') {
      Navigator.pushReplacementNamed(context, AppRoutes.ngo);
    } else if (role == 'local_citizen' || role == 'citizen') {
      Navigator.pushReplacementNamed(context, AppRoutes.citizen);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
    }
  }

  void _showDindiStatusDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dindi Leader Status'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
            },
            child: const Text('Continue as Pilgrim'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maza Pandurang Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supabase Auth Sign In',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in with your registered email and password',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '⚡ Quick Dev Switcher (6 Personas)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _devPersonas.map((p) {
                  return ActionChip(
                    avatar: const Icon(Icons.person, size: 16),
                    label: Text('${p['name']} (${p['role']})'),
                    onPressed: () {
                      _fillPersona(p);
                      _handleLogin();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
