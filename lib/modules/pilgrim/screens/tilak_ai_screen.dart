import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/utils/audio_player_helper.dart';
import '../models/pilgrim_models.dart';
import '../repositories/pilgrim_repository.dart';

enum AiState { idle, listening, transcribing, thinking, speaking, error }

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
  AiState _currentState = AiState.idle;
  String? _statusText;

  static const List<String> _suggestedPrompts = [
    '📍 पालखी सध्या कुठे आहे?',
    '🏥 वैद्यकीय मदत हवी आहे',
    '💧 पिण्याचे पाणी कुठे मिळेल?',
    '🛣️ पुढचा मुक्काम कोणता?',
    '🚩 राम कृष्ण हरी!',
    '🚨 आपत्कालीन मदत',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      TilakChatMessage(
        id: 'MSG-INIT',
        text:
            'राम कृष्ण हरी! 🚩 मी तिलक, आपला वारी AI मार्गदर्शक आहे. पालखी मार्ग, मुक्काम, वैद्यकीय मदत किंवा अन्नछत्राबाबत काहीही विचारा.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = TilakChatMessage(
      id: 'MSG-USR-${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _currentState = AiState.thinking;
      _statusText = 'तिलक वारी माहिती शोधत आहे...';
    });

    _textController.clear();

    try {
      final aiMsg = await widget.repository.queryTilakAI(userMsg.text);

      if (mounted) {
        setState(() {
          _messages.add(aiMsg);
          _currentState = AiState.idle;
          _statusText = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentState = AiState.error;
          _statusText = 'माहिती मिळवताना अडचण आली. कृपया पुन्हा प्रयत्न करा.';
        });
      }
    }
  }

  void _handleVoiceRecording() async {
    setState(() {
      _currentState = AiState.listening;
      _statusText = 'ऐकत आहे... बोला (मराठीत बोला)';
    });

    // Simulate audio capture stream bytes (1 second sample)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _currentState = AiState.transcribing;
      _statusText = 'आवाज रूपांतरित करत आहे (Sarvam STT)...';
    });

    try {
      final sampleAudioBytes = List<int>.generate(512, (i) => i % 256);
      final recognizedText = await widget.repository.transcribeAudio(sampleAudioBytes);

      if (mounted && recognizedText != null && recognizedText.isNotEmpty) {
        _textController.text = recognizedText;
        setState(() {
          _currentState = AiState.idle;
          _statusText = 'आवाज ओळखला: "$recognizedText"';
        });
        _sendMessage(recognizedText);
      } else {
        if (mounted) {
          setState(() {
            _currentState = AiState.idle;
            _statusText = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentState = AiState.error;
          _statusText = 'आवाज ओळखता आला नाही.';
        });
      }
    }
  }

  void _playTTS(String text) async {
    if (!mounted) return;
    setState(() {
      _currentState = AiState.speaking;
      _statusText = 'वाचन सुरू आहे (Sarvam TTS)...';
    });

    try {
      final base64Audio = await widget.repository.synthesizeTTS(text);
      if (mounted && base64Audio != null && base64Audio.isNotEmpty) {
        playBase64Audio(base64Audio);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _currentState = AiState.idle;
        _statusText = null;
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
                'तिलक वारी AI (Marathi Assistant)',
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
                          avatar: const Icon(Icons.help_outline, size: 16, color: AppColors.primary),
                          label: Text(prompt, style: const TextStyle(fontSize: 13)),
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
                  onPlayTTS: () => _playTTS(msg.text),
                );
              },
            ),
          ),

          // Explicit Status Indicator
          if (_currentState != AiState.idle)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentState == AiState.listening)
                    const Icon(Icons.mic, color: Colors.red, size: 18)
                  else if (_currentState == AiState.speaking)
                    const Icon(Icons.volume_up, color: Colors.blue, size: 18)
                  else if (_currentState == AiState.error)
                    const Icon(Icons.error_outline, color: Colors.orange, size: 18)
                  else
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _statusText ?? 'प्रक्रिया सुरू आहे...',
                      style: TextStyle(
                        color: _currentState == AiState.listening
                            ? Colors.red.shade800
                            : AppColors.textSecondary,
                        fontWeight: _currentState == AiState.listening ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                  icon: Icon(
                    _currentState == AiState.listening ? Icons.mic : Icons.mic_none,
                    color: _currentState == AiState.listening ? Colors.red : AppColors.primary,
                  ),
                  onPressed: _handleVoiceRecording,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'तिलकना विचारा (उदा. पालखी कुठे आहे?)...',
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
  final VoidCallback? onPlayTTS;

  const _ChatBubble({
    required this.message,
    this.onActionTap,
    this.onPlayTTS,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!message.isUser && onPlayTTS != null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onPlayTTS,
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.volume_up, size: 18, color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
            if (!message.isUser && message.actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.actions.map((act) {
                  final isEmergency = act.type == 'emergency';
                  final isDirections = act.type == 'directions' || act.latitude != null;
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEmergency
                          ? Colors.red.shade900
                          : (isDirections ? Colors.teal.shade700 : AppColors.primary),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: () {
                      if (act.latitude != null && act.longitude != null) {
                        final title = Uri.encodeComponent(act.title ?? act.label);
                        onActionTap?.call('/map?lat=${act.latitude}&lng=${act.longitude}&title=$title');
                      } else {
                        final target = act.targetRoute ?? message.targetRoute ?? '/map';
                        onActionTap?.call(target);
                      }
                    },
                    icon: Icon(
                      isEmergency
                          ? Icons.warning_amber_rounded
                          : (isDirections ? Icons.near_me_rounded : Icons.explore_rounded),
                      size: 16,
                    ),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 36),
                ),
                onPressed: () {
                  if (onActionTap != null) {
                    onActionTap!(message.targetRoute!);
                  }
                },
                icon: const Icon(Icons.explore_rounded, size: 16),
                label: Text(message.suggestedActionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
