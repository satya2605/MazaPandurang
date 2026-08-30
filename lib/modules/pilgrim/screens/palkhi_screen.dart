import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';

class PalkhiScreen extends StatefulWidget {
  final PilgrimRepository repository;

  const PalkhiScreen({
    super.key,
    required this.repository,
  });

  @override
  State<PalkhiScreen> createState() => _PalkhiScreenState();
}

class _PalkhiScreenState extends State<PalkhiScreen> {
  List<PalkhiInfo> _palkhiList = [];
  int _selectedPalkhiIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await widget.repository.getPalkhiList();
    if (mounted) {
      setState(() {
        _palkhiList = list;
        if (_selectedPalkhiIndex >= _palkhiList.length) {
          _selectedPalkhiIndex = 0;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final selectedPalkhi = _palkhiList.isNotEmpty ? _palkhiList[_selectedPalkhiIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Palkhi Live Track (पालखी)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadData();
            },
            tooltip: 'Refresh Palkhi Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Palkhi Selector Dropdown if multiple Palkhis exist
              if (_palkhiList.length > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedPalkhiIndex,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      items: List.generate(_palkhiList.length, (index) {
                        final p = _palkhiList[index];
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Row(
                            children: [
                              const Icon(Icons.flag, size: 20, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPalkhiIndex = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Palkhi Banner Card
              Card(
                elevation: 3,
                color: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedPalkhi?.name ?? 'Sant Dnyaneshwar Maharaj Palkhi',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (selectedPalkhi != null && selectedPalkhi.saint.isNotEmpty)
                                  Text(
                                    selectedPalkhi.saint,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Route / मार्ग:', style: TextStyle(color: Colors.white70)),
                                Text(
                                  '${selectedPalkhi?.startPoint ?? 'Alandi'} ➔ ${selectedPalkhi?.destination ?? 'Pandharpur'}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Live Current Location:', style: TextStyle(color: Colors.white70)),
                                Flexible(
                                  child: Text(
                                    selectedPalkhi?.currentStage ?? 'Alandi',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Next Destination:', style: TextStyle(color: Colors.white70)),
                                Flexible(
                                  child: Text(
                                    selectedPalkhi?.nextStop ?? 'Pune',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Multi-Day Halt Schedule Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Multi-Day Halt Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'PLANNED HALTS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Official daily stops and expected arrival/departure schedule for pilgrims.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              if (selectedPalkhi == null || selectedPalkhi.halts.isEmpty) ...[
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 36, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'No planned halts published yet for this Palkhi.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Chronological Timeline of Halts
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedPalkhi.halts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final halt = selectedPalkhi.halts[index];
                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'DAY ${halt.dayNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    halt.haltDate,
                                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    halt.locationName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (halt.expectedArrival != null && halt.expectedArrival!.isNotEmpty) ...[
                                        Icon(Icons.login, size: 14, color: Colors.green[700]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Arr: ${halt.expectedArrival}',
                                          style: TextStyle(fontSize: 12, color: Colors.green[800]),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      if (halt.expectedDeparture != null && halt.expectedDeparture!.isNotEmpty) ...[
                                        Icon(Icons.logout, size: 14, color: Colors.orange[800]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Dep: ${halt.expectedDeparture}',
                                          style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (halt.nextDestination != null && halt.nextDestination!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Next ➔ ${halt.nextDestination}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
