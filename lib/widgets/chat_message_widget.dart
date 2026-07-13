import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'common_widgets.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onImageTap;
  final VoidCallback? onSpeak;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onImageTap,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: appGreen,
                child: Text('🌸', style: TextStyle(fontSize: 16)),
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? appGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser ? null : Border.all(color: appBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show image if present in user message
                  if (message.imageBase64 != null) ...[
                    GestureDetector(
                      onTap: onImageTap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(message.imageBase64!),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Text content
                  SelectableText(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  // Speak button for assistant messages
                  if (!isUser && onSpeak != null) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onSpeak,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volume_up,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '朗读',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: appLightPink,
                child: Icon(Icons.person, size: 18, color: appPink),
              ),
            ),
        ],
      ),
    );
  }
}
