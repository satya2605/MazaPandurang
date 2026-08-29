import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/constants/app_colors.dart';
import '../models/dindi_announcement.dart';
import '../services/dindi_state_service.dart';

class DindiAnnouncementsScreen extends StatefulWidget {
  const DindiAnnouncementsScreen({super.key});

  @override
  State<DindiAnnouncementsScreen> createState() =>
      _DindiAnnouncementsScreenState();
}

class _DindiAnnouncementsScreenState extends State<DindiAnnouncementsScreen> {
  final DindiStateService _service = DindiStateService();

  void _copyJoinCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join Code "$code" copied to clipboard!'),
        backgroundColor: AppColors.dindiAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _openCreateAnnouncementDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CreateAnnouncementSheet(
        onPublish: (title, message, isUrgent) {
          _service.addAnnouncement(
            title: title,
            message: message,
            isUrgent: isUrgent,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Announcement published successfully!'),
              backgroundColor: AppColors.dindiAccent,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final announcements = _service.announcements;
        final dindi = _service.dindiGroup;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dindi Announcements'),
            backgroundColor: AppColors.dindiAccent,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_alert),
                tooltip: 'New Announcement',
                onPressed: _openCreateAnnouncementDialog,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreateAnnouncementDialog,
            backgroundColor: AppColors.dindiAccent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Announcement'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Quick Join Code Share Bar
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  color: const Color(0xFFFFF3E0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.qr_code,
                          color: AppColors.dindiAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Join Code: ${dindi.joinCode}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => _copyJoinCode(dindi.joinCode),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.dindiAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.copy, size: 14),
                          label: const Text('Copy'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Recent Broadcasts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                if (announcements.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.campaign_outlined,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No announcements yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Broadcast instructions to all Dindi members here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...announcements.map((ann) => _buildAnnouncementCard(ann)),
                const SizedBox(height: 80), // Padding for FloatingActionButton
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(DindiAnnouncement ann) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: ann.isUrgent ? Colors.red.shade300 : AppColors.border,
          width: ann.isUrgent ? 1.5 : 1.0,
        ),
      ),
      color: ann.isUrgent ? const Color(0xFFFFF8F8) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ann.isUrgent)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: Colors.red.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Text(
                    ann.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ann.isUrgent
                          ? Colors.red.shade900
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  _formatTimestamp(ann.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ann.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAnnouncementSheet extends StatefulWidget {
  final void Function(String title, String message, bool isUrgent) onPublish;

  const _CreateAnnouncementSheet({required this.onPublish});

  @override
  State<_CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onPublish(
        _titleController.text.trim(),
        _messageController.text.trim(),
        _isUrgent,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Announcement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Announcement Title *',
                  hintText: 'e.g. Morning Aarti & Departure',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter announcement title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message / Instructions *',
                  hintText: 'e.g. All members must gather at 05:30 AM.',
                  prefixIcon: const Icon(Icons.message_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter announcement message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text(
                  'Mark as Urgent',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Highlights announcement with urgent priority badge',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isUrgent,
                activeThumbColor: Colors.red.shade700,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _isUrgent = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dindiAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.campaign),
                label: const Text(
                  'Publish Announcement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
