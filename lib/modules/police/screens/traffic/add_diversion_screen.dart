import 'package:flutter/material.dart';
import '../../data/models/traffic_alert.dart';
import '../../data/repositories/police_demo_repository.dart';

/// Form to create a new traffic alert / road diversion.
class AddDiversionScreen extends StatefulWidget {
  const AddDiversionScreen({super.key});

  @override
  State<AddDiversionScreen> createState() => _AddDiversionScreenState();
}

class _AddDiversionScreenState extends State<AddDiversionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = PoliceDemoRepository.instance;

  static const _amber = Color(0xFFF57F17);

  final _roadController = TextEditingController();
  final _messageController = TextEditingController();

  TrafficAlertType _type = TrafficAlertType.diversion;
  TrafficSeverity _severity = TrafficSeverity.medium;

  final _typeLabels = {
    TrafficAlertType.roadBlock: 'Road Block',
    TrafficAlertType.diversion: 'Diversion',
    TrafficAlertType.slow: 'Slow Traffic',
    TrafficAlertType.cleared: 'Cleared',
  };

  final _severityLabels = {
    TrafficSeverity.low: 'Low',
    TrafficSeverity.medium: 'Medium',
    TrafficSeverity.high: 'High',
    TrafficSeverity.critical: 'Critical',
  };

  bool _isPublishing = false;

  @override
  void dispose() {
    _roadController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    _repo.addTrafficAlert(
      TrafficAlert(
        id: _repo.nextTrafficAlertId,
        title: _roadController.text.trim(),
        description: _messageController.text.trim(),
        type: _type,
        // Default to Jejuri area for demo
        latitude: 18.0996,
        longitude: 74.3390,
        severity: _severity,
        status: TrafficAlertStatus.active,
        createdBy: _repo.currentUser.policeId,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Traffic alert published successfully.'),
        backgroundColor: Color(0xFF388E3C),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: _amber,
        title: const Text(
          'Create Traffic Alert',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Road / Location Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _roadController,
                      decoration: _inputDecoration('e.g. Jejuri Main Road'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Road name is required'
                              : null,
                    ),
                    const SizedBox(height: 20),

                    _label('Alert Type'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TrafficAlertType>(
                      initialValue: _type,
                      decoration: _inputDecoration(''),
                      items: TrafficAlertType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_typeLabels[t]!),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                    const SizedBox(height: 20),

                    _label('Severity'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TrafficSeverity>(
                      initialValue: _severity,
                      decoration: _inputDecoration(''),
                      items: TrafficSeverity.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_severityLabels[s]!),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _severity = v!),
                    ),
                    const SizedBox(height: 20),

                    _label('Reason / Message'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        'e.g. Palkhi procession movement',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Please provide a reason'
                              : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info note for cross-module propagation
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _amber.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _amber.withAlpha(60)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Alert will be broadcast to Pilgrim and Citizen modules once cross-module contracts are established.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF555555)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isPublishing ? null : _publish,
                  icon: const Icon(Icons.send),
                  label: _isPublishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Publish Alert',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _amber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Color(0xFF555555),
    ),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8),
      ],
    ),
    child: child,
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFF57F17), width: 2),
    ),
    filled: true,
    fillColor: const Color(0xFFFAFAFA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}
