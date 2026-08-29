import 'package:flutter/material.dart';
import '../models/ngo_organization.dart';
import '../services/ngo_repository.dart';

/// Banner widget displaying current NGO verification and approval status.
class ApprovalStatusBanner extends StatelessWidget {
  final NgoApprovalStatus status;

  const ApprovalStatusBanner({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String title;
    String description;

    switch (status) {
      case NgoApprovalStatus.approved:
        backgroundColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF81C784);
        iconColor = const Color(0xFF2E7D32);
        icon = Icons.verified_user;
        title = 'Verified NGO Partner (Approved)';
        description =
            'Your organization is approved by Admin and all services are active on the public Wari map.';
        break;

      case NgoApprovalStatus.pending:
        backgroundColor = const Color(0xFFFFF8E1);
        borderColor = const Color(0xFFFFD54F);
        iconColor = const Color(0xFFF57F17);
        icon = Icons.hourglass_top;
        title = 'Approval Pending (Under Review)';
        description =
            'Application submitted. Waiting for Admin verification. Services can be added and published once approved.';
        break;

      case NgoApprovalStatus.rejected:
        backgroundColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFE57373);
        iconColor = const Color(0xFFC62828);
        icon = Icons.gpp_bad;
        title = 'Registration Rejected';
        description =
            'Your NGO registration was not approved. Please contact administrative authorities for details.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  NgoRepository().toggleDemoApprovalStatus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demo: Toggled NGO Approval Status!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: iconColor.withAlpha(80)),
                  ),
                  child: Text(
                    'Demo Toggle',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: iconColor.withAlpha(220),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
