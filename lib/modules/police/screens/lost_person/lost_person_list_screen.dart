import 'package:flutter/material.dart';
import '../../data/models/lost_person_case.dart';
import '../../data/repositories/police_demo_repository.dart';
import '../../widgets/lost_person_card.dart';
import 'lost_person_detail_screen.dart';

class LostPersonListScreen extends StatefulWidget {
  const LostPersonListScreen({super.key});

  @override
  State<LostPersonListScreen> createState() => _LostPersonListScreenState();
}

class _LostPersonListScreenState extends State<LostPersonListScreen> {
  final _repo = PoliceDemoRepository.instance;
  static const _policeNavy = Color(0xFF1565C0);
  LostPersonStatus? _filter;

  List<LostPersonCase> get _filtered {
    final all = _repo.lostPersonCases;
    if (_filter == null) return all;
    return all.where((l) => l.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: _policeNavy,
        title: const Text(
          'Lost Persons',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        actions: [
          PopupMenuButton<LostPersonStatus?>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(
                value: LostPersonStatus.pendingApproval,
                child: Text('Pending Approval'),
              ),
              const PopupMenuItem(
                value: LostPersonStatus.approved,
                child: Text('Approved'),
              ),
              const PopupMenuItem(
                value: LostPersonStatus.resolved,
                child: Text('Resolved'),
              ),
            ],
          ),
        ],
      ),
      body: _filtered.isEmpty
          ? const Center(child: Text('No cases match filter.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final person = _filtered[i];
                return LostPersonCard(
                  person: person,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LostPersonDetailScreen(person: person),
                      ),
                    );
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}
