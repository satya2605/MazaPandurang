import 'package:flutter/material.dart';

/// Reusable quick-action tile used on the Citizen Home Screen.
/// Owned by: Gauri — Local Citizen Module
///
/// Each tile has an icon, a label, a Marathi label, and a colour.
/// Tapping it calls [onTap].
class CitizenQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String marathiLabel;
  final Color color;
  final VoidCallback onTap;

  const CitizenQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.marathiLabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withAlpha(35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              marathiLabel,
              style: TextStyle(
                fontSize: 11,
                color: color.withAlpha(180),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
