import 'package:flutter/material.dart';
import '../../data/models/service_report.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../../widgets/status_badge.dart';

class ServiceReportListScreen extends StatefulWidget {
  const ServiceReportListScreen({super.key});

  @override
  State<ServiceReportListScreen> createState() =>
      _ServiceReportListScreenState();
}

class _ServiceReportListScreenState extends State<ServiceReportListScreen> {
  final _repo = PoliceDemoRepository.instance;
  static const _green = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    final reports = _repo.serviceReports;
    final open = reports.where((r) => r.status == ServiceReportStatus.open).length;
    final review = reports.where((r) => r.status == ServiceReportStatus.inReview).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: _green,
        title: const Text(
          'Service Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: Navigator.of(context).canPop(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary row
          Row(
            children: [
              _summaryChip('Open', open, const Color(0xFFD32F2F)),
              const SizedBox(width: 10),
              _summaryChip('In Review', review, const Color(0xFFF57F17)),
            ],
          ),
          const SizedBox(height: 16),
          ...reports.map((r) => _reportCard(r)),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(ServiceReport r) {
    Color statusColor;
    switch (r.status) {
      case ServiceReportStatus.open:
        statusColor = const Color(0xFFD32F2F);
        break;
      case ServiceReportStatus.inReview:
        statusColor = const Color(0xFFF57F17);
        break;
      case ServiceReportStatus.verified:
      case ServiceReportStatus.updated:
        statusColor = const Color(0xFF388E3C);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                r.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF888888),
                ),
              ),
              const Spacer(),
              StatusBadge(label: r.statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            r.serviceName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF555555).withAlpha(15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              r.reasonLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (r.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              '"${r.notes}"',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF666666),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (r.status == ServiceReportStatus.open ||
              r.status == ServiceReportStatus.inReview) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _actionBtn(
                  'Verify',
                  const Color(0xFF388E3C),
                  () => setState(() => r.status = ServiceReportStatus.verified),
                ),
                const SizedBox(width: 8),
                _actionBtn(
                  'In Review',
                  const Color(0xFFF57F17),
                  () => setState(() => r.status = ServiceReportStatus.inReview),
                ),
                const SizedBox(width: 8),
                _actionBtn(
                  'Update',
                  const Color(0xFF1565C0),
                  () => setState(() => r.status = ServiceReportStatus.updated),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
