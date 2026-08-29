import 'package:flutter/material.dart';
import '../models/ngo_service.dart';
import '../services/ngo_repository.dart';
import '../widgets/report_incorrect_dialog.dart';
import 'service_form_screen.dart';

/// Detailed view of a specific NGO Seva Service.
class ServiceDetailScreen extends StatefulWidget {
  final NgoService service;

  const ServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late NgoService _currentService;

  @override
  void initState() {
    super.initState();
    _currentService = widget.service;
    NgoRepository().addListener(_onRepoUpdate);
  }

  @override
  void dispose() {
    NgoRepository().removeListener(_onRepoUpdate);
    super.dispose();
  }

  void _onRepoUpdate() {
    final updated = NgoRepository().services.firstWhere(
        (s) => s.id == _currentService.id,
        orElse: () => _currentService);
    if (mounted) {
      setState(() {
        _currentService = updated;
      });
    }
  }

  void _openReportDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ReportIncorrectDialog(service: _currentService),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Thank you! Report submitted for admin & NGO verification.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _openEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceFormScreen(serviceToEdit: _currentService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = _currentService;

    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Service',
            onPressed: _openEditScreen,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  service.categoryLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),

              // Availability Card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Availability Status',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.availabilityLabel,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: service.availability ==
                                      ServiceAvailability.available
                                  ? const Color(0xFF2E7D32)
                                  : (service.availability ==
                                          ServiceAvailability.limited
                                      ? Colors.orange.shade800
                                      : Colors.red),
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton<ServiceAvailability>(
                        itemBuilder: (context) =>
                            ServiceAvailability.values.map((avail) {
                          return PopupMenuItem(
                            value: avail,
                            child: Text(avail.name.toUpperCase()),
                          );
                        }).toList(),
                        onSelected: (newAvail) {
                          NgoRepository()
                              .updateServiceAvailability(service.id, newAvail);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Change Status',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                              Icon(Icons.arrow_drop_down,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Description & Facilities',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                service.description,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 20),

              const Text(
                'Location & Coordinates',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            service.locationName,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Lat: ${service.latitude}',
                            style: const TextStyle(
                                fontSize: 13, fontFamily: 'monospace')),
                        Text('Long: ${service.longitude}',
                            style: const TextStyle(
                                fontSize: 13, fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Hours',
                      value: service.operatingHours,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.groups,
                      title: 'Capacity',
                      value: service.capacity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Incorrect Information Report Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.report_problem,
                            color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Found Incorrect Information?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Help maintain accurate data for Warkaris during Wari. Report closed camps, wrong locations, or inaccurate numbers.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.orange.shade900),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade900,
                        side: BorderSide(color: Colors.orange.shade800),
                        minimumSize: const Size.fromHeight(42),
                      ),
                      onPressed: _openReportDialog,
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Report Incorrect Information'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
