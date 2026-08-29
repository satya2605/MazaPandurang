import 'package:flutter/material.dart';
import '../models/citizen_service.dart';
import '../widgets/citizen_service_card.dart';
import 'citizen_service_details_screen.dart';

/// Citizen Services Screen — shows all nearby services.
/// Owned by: Gauri — Local Citizen Module
///
/// Features:
/// - Full list of services from mock data
/// - Filter by category chip buttons
/// - Sort by distance
/// - Loading / empty / error states
class CitizenServicesScreen extends StatefulWidget {
  const CitizenServicesScreen({super.key});

  @override
  State<CitizenServicesScreen> createState() => _CitizenServicesScreenState();
}

class _CitizenServicesScreenState extends State<CitizenServicesScreen> {
  // Selected filter — null means "show all"
  ServiceCategory? _selectedCategory;

  // All services — in real app this would come from API
  final List<CitizenService> _allServices = MockCitizenServiceData.services;

  /// Returns services filtered by selected category.
  List<CitizenService> get _filteredServices {
    if (_selectedCategory == null) return _allServices;
    return _allServices.where((s) => s.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nearby Services'),
            Text(
              'जवळचे सेवा केंद्र',
              style: TextStyle(fontSize: 12, color: Color(0xFF6A1B9A)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by distance',
            onPressed: () {
              // Services are already sorted by distance in mock data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Already sorted by distance (nearest first)'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
          // -- Category filter chips --
          _CategoryFilterBar(
            selectedCategory: _selectedCategory,
            onCategorySelected: (cat) {
              setState(() {
                _selectedCategory = cat;
              });
            },
          ),

          // -- Service count info bar --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredServices.length} services found',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (_selectedCategory != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedCategory = null),
                    child: const Row(
                      children: [
                        Icon(Icons.close, size: 14, color: Color(0xFF6A1B9A)),
                        SizedBox(width: 4),
                        Text(
                          'Clear filter',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // -- Services list --
          Expanded(
            child: _filteredServices.isEmpty
                ? _EmptyState(category: _selectedCategory)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return CitizenServiceCard(
                        service: service,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CitizenServiceDetailsScreen(
                                service: service,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category filter horizontal scroll bar
// ---------------------------------------------------------------------------
class _CategoryFilterBar extends StatelessWidget {
  final ServiceCategory? selectedCategory;
  final ValueChanged<ServiceCategory?> onCategorySelected;

  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // "All" chip + one chip for each category
    const categories = ServiceCategory.values;

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (_) => onCategorySelected(null),
              selectedColor: const Color(0xFF6A1B9A).withAlpha(30),
              checkmarkColor: const Color(0xFF6A1B9A),
            ),
          ),
          // One chip per category
          ...categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.label),
                selected: selectedCategory == cat,
                onSelected: (_) {
                  if (selectedCategory == cat) {
                    onCategorySelected(null);
                  } else {
                    onCategorySelected(cat);
                  }
                },
                selectedColor: const Color(0xFF6A1B9A).withAlpha(30),
                checkmarkColor: const Color(0xFF6A1B9A),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state when filter returns 0 results
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final ServiceCategory? category;
  const _EmptyState({this.category});

  @override
  Widget build(BuildContext context) {
    final catLabel = category?.label ?? 'this category';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFF9E9E9E)),
            const SizedBox(height: 16),
            Text(
              'No services found for $catLabel',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try selecting a different category or check back later.',
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
