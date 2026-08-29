import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _nameController = TextEditingController();

  String _selectedRole = 'pilgrim';
  bool _isSignUpMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password.');
      return;
    }

    if (_isSignUpMode && password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic>? profile;
      if (_isSignUpMode) {
        profile = await _authService.signUpWithEmailPassword(
          email: email,
          password: password,
          displayName: name.isNotEmpty ? name : null,
          role: _selectedRole,
        );
      } else {
        profile = await _authService.signInWithEmailPassword(
          email: email,
          password: password,
        );
      }

      if (mounted) {
        if (profile != null) {
          _routeUserByProfile(profile);
        } else {
          // If auth succeeded but profile lookup pending, default route to pilgrim
          Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Authentication failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Google Sign-In failed: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _routeUserByProfile(Map<String, dynamic> profile) {
    final String role = (profile['role'] ?? 'pilgrim').toString().toLowerCase();
    final String status = (profile['status'] ?? 'active').toString().toLowerCase();

    if (status == 'suspended') {
      _showStatusAlert('Account Suspended', 'Your account has been suspended by platform administration.');
      return;
    }

    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
        break;
      case 'dindi_leader':
        if (status == 'pending') {
          _showStatusAlert('Dindi Leader Application Pending', 'Your Dindi Leader application is awaiting Admin approval.');
        } else if (status == 'rejected') {
          _showStatusAlert('Application Not Approved', 'Your Dindi Leader application was not approved by Admin.');
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.dindi);
        }
        break;
      case 'police_authority':
      case 'police':
        Navigator.pushReplacementNamed(context, AppRoutes.police);
        break;
      case 'ngo_volunteer':
      case 'ngo':
        Navigator.pushReplacementNamed(context, AppRoutes.ngo);
        break;
      case 'local_citizen':
      case 'citizen':
        Navigator.pushReplacementNamed(context, AppRoutes.citizen);
        break;
      case 'palkhi_operator':
        Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
        break;
      case 'pilgrim':
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.pilgrim);
        break;
    }
  }

  void _showStatusAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.temple_hindu, color: AppColors.primary, size: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'माझा पांडुरंग',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignUpMode ? 'Create a new pilgrim account' : 'Sign in to access your Wari dashboard',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // Error Alert Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Sign Up Display Name & Role Selection
                      if (_isSignUpMode) ...[
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Select Your Role / भूमिका निवडा',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'pilgrim',
                              child: Text('🚩 Pilgrim (वारकरी / ॲप वापरकर्ता)'),
                            ),
                            DropdownMenuItem(
                              value: 'local_citizen',
                              child: Text('🏡 Local Citizen (स्थानिक नागरिक)'),
                            ),
                            DropdownMenuItem(
                              value: 'dindi_leader',
                              child: Text('🚩 Dindi Leader (दिंडी प्रमुख)'),
                            ),
                            DropdownMenuItem(
                              value: 'ngo_volunteer',
                              child: Text('🤝 NGO Volunteer (सेवाभावी संस्था)'),
                            ),
                            DropdownMenuItem(
                              value: 'police_authority',
                              child: Text('👮 Police Authority (पोलीस प्रशासन)'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedRole = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Primary Action Button (Sign In / Sign Up)
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleEmailAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isSignUpMode ? 'Create Account' : 'Sign In',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Divider Or
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Google Sign In Button
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleAuth,
                        icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                        label: const Text(
                          'Continue with Google',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Toggle Sign In / Sign Up Mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _isSignUpMode ? 'Already have an account?' : "Don't have an account?",
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUpMode = !_isSignUpMode;
                                _errorMessage = null;
                              });
                            },
                            child: Text(
                              _isSignUpMode ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
