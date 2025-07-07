// ...imports
import 'package:flutter/material.dart';
import '../core/theme.dart';

import 'dart:io';

class BookClubChatPage extends StatefulWidget {
  final String clubName;
  final String? backgroundImage;
  final Color chatColor;

  const BookClubChatPage({
    super.key,
    required this.clubName,
    required this.chatColor,
    this.backgroundImage,
  });

  @override
  State<BookClubChatPage> createState() => _BookClubChatPageState();
}

class _BookClubChatPageState extends State<BookClubChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Color _lighten(Color color, [double amount = .4]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  final List<ChatMessage> messages = [
    ChatMessage(
      text:
          "Ciao a tutti! Ho appena finito il primo capitolo del Il Gattopardo... che stile!",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      avatar: '👩‍🎨',
    ),
    ChatMessage(
      text:
          "Tomasi di Lampedusa scrive con una malinconia elegante. Bellissimo!",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 43)),
      avatar: '🧑‍🏫',
    ),
    ChatMessage(
      text:
          "Concordo! E quella frase sul cambiamento? 'Se vogliamo che tutto rimanga com'è, bisogna che tutto cambi'... da brividi.",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 41)),
      avatar: '📚',
    ),
    ChatMessage(
      text:
          "Secondo voi Don Fabrizio è un eroe tragico o un osservatore rassegnato?",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
      avatar: '🧑‍🎓',
    ),
    ChatMessage(
      text:
          "Domandona! Per me è entrambe le cose. Un uomo consapevole della fine di un'epoca.",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      avatar: '🧑‍🏫',
    ),
    ChatMessage(
      text: "Questa settimana arriviamo fino al capitolo 4, giusto?",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
      avatar: '👩‍🎨',
    ),
    ChatMessage(
      text: "Sì esatto! E giovedì sera ci troviamo su Zoom per discuterne 😊",
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      avatar: '🧑‍🏫',
    ),
    ChatMessage(
      text: "Perfetto! Mi preparo domande, ho mille pensieri da condividere 😄",
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
      avatar: '📚',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightBackground
          : AppTheme.darkBackground,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.clubName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          if (widget.backgroundImage != null)
            Positioned.fill(
              child: Image.file(
                File(widget.backgroundImage!),
                fit: BoxFit.cover,
              ),
            ),
          if (widget.backgroundImage != null)
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
            ],
          ),
        ],
      ),

      // 🔽 barra dei messaggi SEMPRE in fondo (anche con tastiera aperta)
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.chatColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Scrivi un messaggio...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    maxLines: null,
                    minLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.chatColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final bool isMe = message.isMe;
    final Color bubbleColor = isMe
        ? widget.chatColor
        : _lighten(widget.chatColor, 0.4);
    final Color textColor = isMe ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: Text(
                message.avatar,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.chatColor.withValues(alpha: 0.5),
              child: Text(
                message.avatar,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}g fa';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h fa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m fa';
    } else {
      return 'ora';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String avatar;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.avatar,
  });
}
