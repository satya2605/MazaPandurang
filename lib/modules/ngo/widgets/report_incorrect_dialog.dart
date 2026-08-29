import 'package:flutter/material.dart';
import '../models/ngo_service.dart';
import '../models/service_report.dart';
import '../services/ngo_repository.dart';

/// Modal dialog for reporting incorrect NGO service information.
class ReportIncorrectDialog extends StatefulWidget {
  final NgoService service;

  const ReportIncorrectDialog({
    super.key,
    required this.service,
  });

  @override
  State<ReportIncorrectDialog> createState() => _ReportIncorrectDialogState();
}

class _ReportIncorrectDialogState extends State<ReportIncorrectDialog> {
  final _formKey = GlobalKey<FormState>();
  ReportReason _selectedReason = ReportReason.wrongAvailability;
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _reporterNameController =
      TextEditingController(text: 'Pilgrim Volunteer');

  @override
  void dispose() {
    _commentsController.dispose();
    _reporterNameController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      NgoRepository().submitReport(
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        reporterName: _reporterNameController.text.trim(),
        reason: _selectedReason,
        comments: _commentsController.text.trim(),
      );

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.report_problem_outlined, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Report Incorrect Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporting service: "${widget.service.name}"',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reason for Report',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<ReportReason>(
                initialValue: _selectedReason,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: ReportReason.values.map((reason) {
                  final tempReport = ServiceReport(
                    id: '',
                    serviceId: '',
                    serviceName: '',
                    reporterName: '',
                    reason: reason,
                    comments: '',
                    timestamp: DateTime.now(),
                  );
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(tempReport.reasonLabel,
                        style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedReason = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Your Name / Role (Optional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _reporterNameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Warkari, NGO Volunteer',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Details / Correct Information',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _commentsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Describe what is wrong (e.g., food supply ran out, camp moved 200m ahead)...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the issue.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade800,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _submitReport,
          icon: const Icon(Icons.send, size: 16),
          label: const Text('Submit Report'),
        ),
      ],
    );
  }
}
