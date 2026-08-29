import 'package:flutter/material.dart';

/// Reusable, high-visibility Emergency SOS Button with confirmation dialog.
class EmergencySosButton extends StatefulWidget {
  final String label;
  final String emergencyType;
  final bool isLoading;
  final Future<void> Function() onConfirmedSubmit;

  const EmergencySosButton({
    super.key,
    this.label = '🚨 SEND EMERGENCY SOS',
    this.emergencyType = 'Medical',
    this.isLoading = false,
    required this.onConfirmedSubmit,
  });

  @override
  State<EmergencySosButton> createState() => _EmergencySosButtonState();
}

class _EmergencySosButtonState extends State<EmergencySosButton> {
  bool _isSubmitting = false;

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Confirm Emergency SOS'),
          ],
        ),
        content: Text(
          'Are you sure you want to dispatch a ${widget.emergencyType} Emergency SOS to Wari safety responders?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isSubmitting = true);
              try {
                await widget.onConfirmedSubmit();
              } finally {
                if (mounted) {
                  setState(() => _isSubmitting = false);
                }
              }
            },
            child: const Text('DISPATCH SOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.isLoading || _isSubmitting;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: busy ? null : _showConfirmationDialog,
        icon: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Icon(Icons.emergency, size: 24),
        label: Text(
          busy ? 'DISPATCHING SOS...' : widget.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
