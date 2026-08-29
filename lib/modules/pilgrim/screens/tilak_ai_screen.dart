import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';

class TilakAiScreen extends StatefulWidget {
  final PilgrimRepository repository;
  final Function(String route)? onNavigateAction;

  const TilakAiScreen({
    super.key,
    required this.repository,
    this.onNavigateAction,
  });

  @override
  State<TilakAiScreen> createState() => _TilakAiScreenState();
}

class _TilakAiScreenState extends State<TilakAiScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<TilakChatMessage> _messages = [];
  bool _isThinking = false;

  static const List<String> _suggestedPrompts = [
    '📍 Where is the Palkhi right now?',
    '🏥 Find medical help',
    '💧 Where can I get water?',
    '🛣️ What is the next Wari stop?',
    '🙏 Tell me about Pandurang',
    '🚨 I need emergency help',
  ];

  @override
  void initState() {
    super.initState();
    // Non-persistent initial welcome message
    _messages.add(
      TilakChatMessage(
        id: 'MSG-INIT',
        text:
            'Ram Krishna Hari! 🚩 I am Tilak, your dedicated Wari AI guide. Ask me anything about Palkhi schedules, medical camps, water points, or route updates.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = TilakChatMessage(
      id: 'MSG-USR-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isThinking = true;
    });

    _textController.clear();

    final aiMsg = await widget.repository.queryTilakAI(text);

    if (mounted) {
      setState(() {
        _messages.add(aiMsg);
        _isThinking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Tilak AI Assistant',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suggested Query Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.background,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _suggestedPrompts
                    .map(
                      (prompt) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.help_outline,
                              size: 16, color: AppColors.primary),
                          label: Text(prompt,
                              style: const TextStyle(fontSize: 13)),
                          backgroundColor: AppColors.surface,
                          onPressed: () => _sendMessage(prompt),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // Chat Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(
                  message: msg,
                  onActionTap: widget.onNavigateAction,
                );
              },
            ),
          ),

          if (_isThinking)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Tilak is searching Wari information...',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic_none, color: AppColors.primary),
                  tooltip: 'Voice Search Placeholder',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Speech-to-Text (STT) provider will activate in Phase 2.',
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask Tilak about Wari, Palkhi, medical...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final TilakChatMessage message;
  final Function(String route)? onActionTap;

  const _ChatBubble({
    required this.message,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser
              ? null
              : Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            if (!message.isUser && message.actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.actions.map((act) {
                  final isEmergency = act.type == 'emergency';
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEmergency ? Colors.red : AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: () {
                      final target = act.targetRoute ?? message.targetRoute ?? '/map';
                      if (onActionTap != null) {
                        onActionTap!(target);
                      }
                    },
                    icon: Icon(isEmergency ? Icons.warning_amber : Icons.explore, size: 16),
                    label: Text(act.label),
                  );
                }).toList(),
              ),
            ] else if (!message.isUser &&
                message.suggestedActionText != null &&
                message.targetRoute != null) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  minimumSize: const Size(0, 36),
                ),
                onPressed: () {
                  if (onActionTap != null) {
                    onActionTap!(message.targetRoute!);
                  }
                },
                icon: const Icon(Icons.explore, size: 16),
                label: Text(message.suggestedActionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
