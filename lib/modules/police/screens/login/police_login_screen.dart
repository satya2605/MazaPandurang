import 'package:flutter/material.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../dashboard/police_shell_screen.dart';

/// Police Login Screen.
/// Police accounts are pre-created by admin — no self-registration flow.
/// Demo credentials: POLICE001 / demo123
class PoliceLoginScreen extends StatefulWidget {
  const PoliceLoginScreen({super.key});

  @override
  State<PoliceLoginScreen> createState() => _PoliceLoginScreenState();
}

class _PoliceLoginScreenState extends State<PoliceLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  static const _policeNavy = Color(0xFF1565C0);
  static const _policeNavyLight = Color(0xFF1E88E5);

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate brief network delay for demo realism
    await Future.delayed(const Duration(milliseconds: 600));

    final valid = PoliceDemoRepository.instance.validateCredentials(
      _idController.text.trim().toUpperCase(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (valid) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PoliceShellScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid Police ID or password. Please try again.';
      });
    }
  }

  void _fillDemoCredentials() {
    _idController.text = PoliceDemoRepository.demoPoliceId;
    _passwordController.text = PoliceDemoRepository.demoPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Header ───────────────────────────────────────────────
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_policeNavy, _policeNavyLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _policeNavy.withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_police,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Police Command',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'माझा पांडुरंग — Authority Portal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF666688)),
              ),
              const SizedBox(height: 40),

              // ── Login Form ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Officer Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Police ID field
                      TextFormField(
                        controller: _idController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Police ID',
                          hintText: 'e.g. POLICE001',
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            color: _policeNavy,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _policeNavy,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FF),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Police ID is required'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: _policeNavy,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF888888),
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _policeNavy,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FF),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'Password is required'
                                : null,
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFD32F2F),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Login button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _policeNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Forgot password
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contact your station administrator to reset your password.',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: _policeNavy),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Demo Credentials Banner ────────────────────────────────
              GestureDetector(
                onTap: _fillDemoCredentials,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _policeNavy.withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _policeNavy.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: _policeNavy,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demo Credentials',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _policeNavy,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'ID: POLICE001   Password: demo123',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF444466),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Tap to fill',
                        style: TextStyle(
                          fontSize: 11,
                          color: _policeNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
