import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';

class ServicesScreen extends StatefulWidget {
  final PilgrimRepository repository;
  final Function(WariService)? onServiceTap;

  const ServicesScreen({
    super.key,
    required this.repository,
    this.onServiceTap,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  ServiceCategory? _selectedCategory;
  List<WariService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final list =
        await widget.repository.getServices(category: _selectedCategory);
    if (mounted) {
      setState(() {
        _services = list;
        _isLoading = false;
      });
    }
  }

  void _onCategoryFilter(ServiceCategory? category) {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    _fetchServices();
  }

  void _reportIncorrectService(WariService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Service Info (${service.serviceId})'),
        content: Text(
            'Report incorrect details for "${service.name}"? Our volunteers will verify and update service status.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Report submitted for ${service.serviceId}. Thank you!'),
                ),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wari Seva Services (सेवा सुविधा)'),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                FilterChip(
                  selected: _selectedCategory == null,
                  label: const Text('All Services'),
                  onSelected: (_) => _onCategoryFilter(null),
                ),
                const SizedBox(width: 8),
                ...ServiceCategory.values.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedCategory == cat,
                      avatar: Icon(cat.icon, size: 16, color: cat.color),
                      label: Text(cat.label),
                      onSelected: (_) => _onCategoryFilter(cat),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Service List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                    ? const Center(
                        child: Text('No services found in this category.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _services.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: service.category.color
                                            .withAlpha(30),
                                        child: Icon(service.category.icon,
                                            color: service.category.color),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    service.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withAlpha(20),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    service.serviceId,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              service.address,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    service.description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Chip(
                                        backgroundColor: service.category.color
                                            .withAlpha(20),
                                        padding: EdgeInsets.zero,
                                        label: Text(
                                          service.availabilityStatus,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: service.category.color,
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _reportIncorrectService(service),
                                        icon: const Icon(Icons.flag_outlined,
                                            size: 16, color: Colors.orange),
                                        label: const Text(
                                          'Report Info',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
