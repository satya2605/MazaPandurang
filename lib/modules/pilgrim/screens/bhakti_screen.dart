import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';

class BhaktiScreen extends StatefulWidget {
  final PilgrimRepository repository;

  const BhaktiScreen({
    super.key,
    required this.repository,
  });

  @override
  State<BhaktiScreen> createState() => _BhaktiScreenState();
}

class _BhaktiScreenState extends State<BhaktiScreen> {
  String _selectedCategory = 'Featured';
  List<BhaktiMediaItem> _mediaItems = [];
  BhaktiMediaItem? _currentlyPlaying;
  bool _isLoading = true;

  static const List<String> _categories = [
    'Featured',
    'Bhajans',
    'Abhang',
    'Kirtan',
    'Videos',
  ];

  @override
  void initState() {
    super.initState();
    _loadBhaktiContent();
  }

  Future<void> _loadBhaktiContent() async {
    final items =
        await widget.repository.getBhaktiContent(category: _selectedCategory);
    if (mounted) {
      setState(() {
        _mediaItems = items;
        _isLoading = false;
      });
    }
  }

  void _onCategoryChange(String cat) {
    setState(() {
      _selectedCategory = cat;
      _isLoading = true;
    });
    _loadBhaktiContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bhakti Streaming (भक्ती संगीत)'),
      ),
      body: Column(
        children: [
          // Category Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _categories
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: _selectedCategory == cat,
                        label: Text(cat),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedCategory == cat
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => _onCategoryChange(cat),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Media Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _mediaItems.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _mediaItems[index];
                      final isPlayingThis = _currentlyPlaying?.id == item.id;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withAlpha(30),
                            child: Icon(
                              item.category == 'Videos'
                                  ? Icons.play_circle_fill
                                  : Icons.music_note,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            item.marathiTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text('${item.title} • ${item.artist}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.duration,
                                  style: const TextStyle(fontSize: 12)),
                              IconButton(
                                icon: Icon(
                                  isPlayingThis
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _currentlyPlaying =
                                        isPlayingThis ? null : item;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Audio Streaming Player Bar
          if (_currentlyPlaying != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.primaryDark,
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentlyPlaying!.marathiTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Streaming: ${_currentlyPlaying!.artist}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _currentlyPlaying = null;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
