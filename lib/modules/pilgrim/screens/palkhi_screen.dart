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
  PalkhiInfo? _palkhi;
  List<DindiMarkerInfo> _dindis = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final palkhi = await widget.repository.getPalkhiInfo();
    final dindis = await widget.repository.getNearbyDindis();
    if (mounted) {
      setState(() {
        _palkhi = palkhi;
        _dindis = dindis;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Palkhi Live Track (पालखी)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Palkhi Banner Card
            Card(
              color: AppColors.primary,
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
                          child: Text(
                            _palkhi?.name ?? 'Sant Dnyaneshwar Maharaj Palkhi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Current Location:',
                                  style: TextStyle(color: Colors.white70)),
                              Text(
                                _palkhi?.currentStage ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Next Destination:',
                                  style: TextStyle(color: Colors.white70)),
                              Text(
                                _palkhi?.nextStop ?? '',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
            const SizedBox(height: 20),

            // Nearby Dindi Section
            const Text(
              'Nearby Dindis (जवळील दिंड्या)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dindis.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final dindi = _dindis[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.dindiAccent,
                      child: Icon(Icons.groups, color: Colors.white),
                    ),
                    title: Text(dindi.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Leader: ${dindi.leaderName} • ${dindi.memberCount} Varkaris\nStatus: ${dindi.currentStatus}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
