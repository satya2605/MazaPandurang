import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';
import 'youtube_player_screen.dart';

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
  String _selectedCategory = 'Vitthal Bhajans';
  List<BhaktiMediaItem> _mediaItems = [];
  bool _isLoading = true;

  static const List<String> _categories = [
    'Vitthal Bhajans',
    'Abhang',
    'Wari Songs',
    'Aarti',
    'Pandurang',
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
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading Bhakti content...'),
                      ],
                    ),
                  )
                : _mediaItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No approved Bhakti content available.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _mediaItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _mediaItems[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => YoutubePlayerScreen(
                                    videoId: item.youtubeVideoId,
                                    title: item.title,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  // Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.thumbnailUrl,
                                      width: 100,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 70,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.music_note, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.channelTitle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.play_circle_fill,
                                    color: AppColors.primary,
                                    size: 32,
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
