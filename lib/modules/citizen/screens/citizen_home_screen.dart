import 'package:flutter/material.dart';
import '../widgets/citizen_quick_action.dart';
import 'citizen_services_screen.dart';
import 'citizen_map_screen.dart';
import 'citizen_alerts_screen.dart';

/// The main Citizen Home Screen.
/// Owned by: Gauri — Local Citizen Module
///
/// This screen is a StatefulWidget because it holds state:
/// - Which bottom-nav tab is currently selected.
///
/// It acts as the "shell" that holds the bottom navigation bar
/// and switches between the Home content, Map, and Alerts tabs.
class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  // This tracks which bottom tab is selected (0=Home, 1=Map, 2=Alerts, 3=Profile)
  int _currentIndex = 0;

  /// Public method so child widgets can switch tabs without using protected setState.
  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // The list of pages shown by each tab.
  // IndexedStack keeps all pages in memory so they don't reload on tab switch.
  static const List<Widget> _pages = [
    _HomeContent(), // tab 0 — Home
    CitizenMapScreen(), // tab 1 — Map
    CitizenAlertsScreen(), // tab 2 — Alerts
    _ProfilePlaceholder(), // tab 3 — Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack shows only the selected tab's page, but keeps others alive.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // The bottom navigation bar with 4 tabs.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: const Color(0xFF6A1B9A).withAlpha(30),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HOME CONTENT — The actual home tab content
// ---------------------------------------------------------------------------

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning! 🌅'
        : hour < 17
            ? 'Good Afternoon! ☀️'
            : 'Good Evening! 🌙';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: CustomScrollView(
              slivers: [
            // -- App bar with title and greeting --
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: const Color(0xFFFAF9F6),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A1B9A).withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.temple_hindu,
                              color: Color(0xFF6A1B9A),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Maza Pandurang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // -- Scrollable body content --
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search bar
                  _SearchBar(),

                  const SizedBox(height: 24),

                  // Section: Quick Actions
                  const _SectionHeader(
                    title: 'Quick Actions',
                    marathiTitle: 'त्वरित क्रिया',
                  ),
                  const SizedBox(height: 14),
                  _QuickActionsGrid(context: context),

                  const SizedBox(height: 28),

                  // Section: Nearby Services (preview)
                  const _SectionHeader(
                    title: 'Nearby Services',
                    marathiTitle: 'जवळचे सेवा केंद्र',
                  ),
                  const SizedBox(height: 14),
                  _NearbyServicesPreview(context: context),

                  const SizedBox(height: 28),

                  // Section: Wari Notice
                  _WariNoticeCard(),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar widget
// ---------------------------------------------------------------------------
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search services, places... / सेवा शोधा',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B9A)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: (value) {
          // TODO: Navigate to filtered services screen
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header with English + Marathi
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final String marathiTitle;
  const _SectionHeader({required this.title, required this.marathiTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '• $marathiTitle',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions 2x2 grid
// ---------------------------------------------------------------------------
class _QuickActionsGrid extends StatelessWidget {
  final BuildContext context;
  const _QuickActionsGrid({required this.context});

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 180,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        CitizenQuickAction(
          icon: Icons.map_outlined,
          label: 'Map',
          marathiLabel: 'नकाशा',
          color: const Color(0xFF1565C0),
          onTap: () => _switchToTab(context, 1),
        ),
        CitizenQuickAction(
          icon: Icons.medical_services_outlined,
          label: 'Services',
          marathiLabel: 'सेवा',
          color: const Color(0xFF6A1B9A),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CitizenServicesScreen()),
          ),
        ),
        CitizenQuickAction(
          icon: Icons.notifications_active_outlined,
          label: 'Alerts',
          marathiLabel: 'सतर्कता',
          color: const Color(0xFFE65100),
          onTap: () => _switchToTab(context, 2),
        ),
        CitizenQuickAction(
          icon: Icons.person_search_outlined,
          label: 'Lost Persons',
          marathiLabel: 'हरवलेले',
          color: const Color(0xFFC62828),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lost Persons feature coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Switches the bottom nav to the given tab index.
  void _switchToTab(BuildContext context, int index) {
    // Use the public switchTab method to avoid calling protected setState.
    context.findAncestorStateOfType<_CitizenHomeScreenState>()?.switchTab(index);
  }
}

// ---------------------------------------------------------------------------
// Nearby services preview (top 3 from mock data)
// ---------------------------------------------------------------------------
class _NearbyServicesPreview extends StatelessWidget {
  final BuildContext context;
  const _NearbyServicesPreview({required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ServicePreviewTile(
          icon: Icons.medical_services_outlined,
          name: 'Pandharpur Medical Camp',
          detail: '320 m away • OPEN',
          color: Color(0xFFC62828),
        ),
        const SizedBox(height: 8),
        const _ServicePreviewTile(
          icon: Icons.restaurant_outlined,
          name: 'Annachhatra Seva Trust',
          detail: '480 m away • AVAILABLE',
          color: Color(0xFFE65100),
        ),
        const SizedBox(height: 8),
        const _ServicePreviewTile(
          icon: Icons.water_drop_outlined,
          name: 'Jal Seva Water Station',
          detail: '150 m away • AVAILABLE',
          color: Color(0xFF0277BD),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CitizenServicesScreen()),
          ),
          icon: const Icon(Icons.list_alt, size: 18),
          label: const Text('View All Services'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6A1B9A),
            side: const BorderSide(color: Color(0xFF6A1B9A)),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }
}

class _ServicePreviewTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String detail;
  final Color color;

  const _ServicePreviewTile({
    required this.icon,
    required this.name,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6A1B9A), size: 20),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wari Notice Card (informational banner)
// ---------------------------------------------------------------------------
class _WariNoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Wari Season Notice',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Wari is underway. Expect heavy crowds near Vitthal Mandir and Chandrabhaga Ghat. Plan your travel accordingly.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'वारी चालू आहे. गर्दीचे ठिकाण सावधगिरीने वापरावे.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile placeholder (Phase 2 feature)
// ---------------------------------------------------------------------------
class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Color(0xFF6A1B9A)),
            SizedBox(height: 16),
            Text(
              'Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Coming in the next phase!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
