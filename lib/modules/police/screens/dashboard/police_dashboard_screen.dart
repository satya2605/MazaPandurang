import 'package:flutter/material.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../../widgets/police_stat_card.dart';
import '../emergency/emergency_list_screen.dart';
import '../traffic/traffic_list_screen.dart';
import '../lost_person/lost_person_list_screen.dart';
import '../reports/service_report_list_screen.dart';

/// Police Command Dashboard — the home screen after login.
/// Displays live stat counts and quick-action shortcuts.
class PoliceDashboardScreen extends StatefulWidget {
  const PoliceDashboardScreen({super.key});

  @override
  State<PoliceDashboardScreen> createState() => _PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState extends State<PoliceDashboardScreen> {
  final _repo = PoliceDemoRepository.instance;

  static const _policeNavy = Color(0xFF1565C0);

  void _navigate(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = _repo.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top App Bar ───────────────────────────────────────────
            SliverAppBar(
              backgroundColor: _policeNavy,
              expandedHeight: 130,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_police,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.station,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'WARI OPS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section: Operations Overview ─────────────────
                    _sectionTitle('Wari Operations'),
                    const SizedBox(height: 4),
                    Text(
                      'Live · Demo Data — ${DateTime.now().day} Aug 2026',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Stat Cards Grid ───────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        PoliceStatCard(
                          label: 'Active Emergencies',
                          count: _repo.activeEmergencyCount,
                          icon: Icons.emergency,
                          color: const Color(0xFFD32F2F),
                          onTap:
                              () => _navigate(const EmergencyListScreen()),
                        ),
                        PoliceStatCard(
                          label: 'Open Incidents',
                          count: _repo.openIncidentCount,
                          icon: Icons.report_problem_outlined,
                          color: const Color(0xFFE65100),
                          onTap:
                              () => _navigate(const EmergencyListScreen()),
                        ),
                        PoliceStatCard(
                          label: 'Traffic Alerts',
                          count: _repo.activeTrafficAlertCount,
                          icon: Icons.traffic,
                          color: const Color(0xFFF57F17),
                          onTap: () => _navigate(const TrafficListScreen()),
                        ),
                        PoliceStatCard(
                          label: 'Lost Persons',
                          count: _repo.activeLostPersonCount,
                          icon: Icons.person_search,
                          color: _policeNavy,
                          onTap:
                              () => _navigate(const LostPersonListScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Quick Actions ─────────────────────────────────
                    _sectionTitle('Quick Actions'),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _quickActionButton(
                          icon: Icons.emergency,
                          label: 'Emergency',
                          color: const Color(0xFFD32F2F),
                          onTap:
                              () => _navigate(const EmergencyListScreen()),
                        ),
                        const SizedBox(width: 10),
                        _quickActionButton(
                          icon: Icons.traffic,
                          label: 'Traffic',
                          color: const Color(0xFFF57F17),
                          onTap: () => _navigate(const TrafficListScreen()),
                        ),
                        const SizedBox(width: 10),
                        _quickActionButton(
                          icon: Icons.person_search,
                          label: 'Lost Person',
                          color: _policeNavy,
                          onTap:
                              () => _navigate(const LostPersonListScreen()),
                        ),
                        const SizedBox(width: 10),
                        _quickActionButton(
                          icon: Icons.report_outlined,
                          label: 'Reports',
                          color: const Color(0xFF388E3C),
                          onTap:
                              () =>
                                  _navigate(const ServiceReportListScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Recent Emergencies Preview ─────────────────────
                    Row(
                      children: [
                        Expanded(child: _sectionTitle('Recent Emergencies')),
                        TextButton(
                          onPressed:
                              () => _navigate(const EmergencyListScreen()),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: _policeNavy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._repo.emergencies
                        .take(2)
                        .map(
                          (e) => _emergencyPreviewTile(e.id, e.typeLabel, e.locationDescription, e.statusLabel),
                        ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A2E),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(60), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emergencyPreviewTile(
    String id,
    String type,
    String location,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$id — $type',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }
}
