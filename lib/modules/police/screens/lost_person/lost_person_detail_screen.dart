import 'package:flutter/material.dart';
import '../../data/models/lost_person_case.dart';
import '../../data/models/lost_person_sighting.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../../widgets/status_badge.dart';

Color _statusColor(LostPersonStatus s) {
  switch (s) {
    case LostPersonStatus.pendingApproval:
      return const Color(0xFF7B1FA2);
    case LostPersonStatus.approved:
      return const Color(0xFF1565C0);
    case LostPersonStatus.resolved:
      return const Color(0xFF388E3C);
  }
}

class LostPersonDetailScreen extends StatefulWidget {
  final LostPersonCase person;
  const LostPersonDetailScreen({super.key, required this.person});

  @override
  State<LostPersonDetailScreen> createState() =>
      _LostPersonDetailScreenState();
}

class _LostPersonDetailScreenState extends State<LostPersonDetailScreen> {
  final _repo = PoliceDemoRepository.instance;
  LostPersonCase get _p => widget.person;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(_p.status);
    final sightings = _repo.sightingsForCase(_p.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          _p.id,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.person_search,
                        color: statusColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _p.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          StatusBadge(
                            label: _p.statusLabel,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _row('Description', _p.description),
                _row('Last Seen', _p.lastSeenDescription),
                _row(
                  'Broadcast Radius',
                  '${_p.broadcastRadiusKm.toStringAsFixed(1)} km',
                ),
                _row('Sightings', '${_p.sightingCount} reported'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Broadcast button (only if approved)
          if (_p.status == LostPersonStatus.approved)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Broadcast sent to users within ${_p.broadcastRadiusKm.toStringAsFixed(1)} km of last seen location.',
                      ),
                      backgroundColor: const Color(0xFF1565C0),
                    ),
                  );
                },
                icon: const Icon(Icons.campaign),
                label: const Text(
                  'Broadcast to Area',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else if (_p.status == LostPersonStatus.pendingApproval)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF7B1FA2).withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7B1FA2).withAlpha(60),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.hourglass_top,
                    color: Color(0xFF7B1FA2),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Awaiting admin approval before broadcast can be sent.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Sightings section
          if (sightings.isNotEmpty) ...[
            const Text(
              'Reported Sightings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            ...sightings.map((s) => _sightingCard(s)),
          ] else
            const Center(
              child: Text(
                'No sightings reported yet.',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sightingCard(LostPersonSighting s) {
    final isVerified = s.status == SightingStatus.verified;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isVerified
                  ? const Color(0xFF388E3C).withAlpha(80)
                  : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF1565C0), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.locationDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              StatusBadge(
                label: s.statusLabel,
                color:
                    isVerified
                        ? const Color(0xFF388E3C)
                        : const Color(0xFF888888),
              ),
            ],
          ),
          if (s.reporterMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              '"${s.reporterMessage}"',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Reported: ${s.reportedAt.hour}:${s.reportedAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
          if (s.status == SightingStatus.reported) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      s.status = SightingStatus.verified;
                    }),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Verify'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF388E3C),
                      side: const BorderSide(color: Color(0xFF388E3C)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      s.status = SightingStatus.dismissed;
                    }),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Dismiss'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                      side: const BorderSide(color: Color(0xFFD32F2F)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
          ),
        ),
      ],
    ),
  );
}
