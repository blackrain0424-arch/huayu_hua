import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/chat_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/chat_message_widget.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _chatService = ChatService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  final _tts = FlutterTts();

  bool _isLoading = false;
  bool _ttsAvailable = false;

  @override
  void initState() {
    super.initState();
    _initTts();

    if (_chatService.messages.isEmpty) {
      _chatService.addAssistantMessage(
        '你好！我是花语Bot 🌸\n\n'
        '我可以帮你：\n'
        '🌺 识别花卉照片，告诉你花名和花语\n'
        '📖 介绍各种花卉的分布、观赏季节\n'
        '💬 和你聊聊关于花的一切\n\n'
        '你可以直接打字、语音输入（点击🎤），或上传花卉照片让我识别～',
      );
    }
  }

  Future<void> _initTts() async {
    try {
      // Try zh-CN first, fallback to any available Chinese voice
      final languages = await _tts.getLanguages;
      String? selectedLang;

      for (final code in ['zh-CN', 'zh', 'cmn', 'cmn-Hans-CN', 'yue']) {
        if (languages.contains(code)) {
          selectedLang = code;
          break;
        }
      }

      // If no exact match, look for any zh- prefixed language
      if (selectedLang == null) {
        for (final lang in languages) {
          if (lang.startsWith('zh')) {
            selectedLang = lang;
            break;
          }
        }
      }

      if (selectedLang != null) {
        await _tts.setLanguage(selectedLang);
        await _tts.setSpeechRate(0.5);
        await _tts.setPitch(1.0);
        _ttsAvailable = true;
      } else {
        // No Chinese voice installed — suggest user install one
        _ttsAvailable = false;
        debugPrint('TTS: no Chinese voice found. Available: $languages');
      }
    } catch (e) {
      _ttsAvailable = false;
      debugPrint('TTS init error: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() => _isLoading = true);
    _scrollToBottom();

    await _chatService.sendMessage(text);

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: appGreen),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: appGreen),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (picked == null) return;

    final bytes = await File(picked.path).readAsBytes();
    final base64 = base64Encode(bytes);

    setState(() => _isLoading = true);
    _scrollToBottom();

    await _chatService.sendMessage('', imageBase64: base64);

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  /// Voice input: uses the keyboard's built-in voice input
  /// (works on all Chinese keyboards: 搜狗/百度/讯飞/小爱)
  void _openVoiceInput() {
    final voiceController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mic, color: appPink, size: 28),
            SizedBox(width: 10),
            Text('语音输入', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '点击下方输入框，再点击键盘上的 🎤 麦克风按钮开始语音输入',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: voiceController,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              onSubmitted: (text) {
                Navigator.pop(ctx);
                if (text.trim().isNotEmpty) {
                  _textController.text = text.trim();
                  _sendText();
                }
              },
              decoration: InputDecoration(
                hintText: '语音识别后文字会出现在这里...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: appBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: appGreen),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: appGreen),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final text = voiceController.text.trim();
                    if (text.isNotEmpty) {
                      _textController.text = text;
                      _sendText();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Future<void> _speakResponse(String text) async {
    if (!_ttsAvailable) {
      // No TTS engine — show help dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.volume_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('语音朗读不可用'),
            ],
          ),
          content: const Text(
            '你的手机没有安装中文语音引擎。\n\n'
            '解决方法：\n'
            '1. 打开手机 设置 → 更多设置 → 语言与输入法 → 文字转语音\n'
            '2. 确保"小爱同学"或其他中文语音引擎已启用\n'
            '3. 如果列表为空，需下载安装语音数据包',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
      return;
    }

    // Strip markdown for clean TTS
    final plainText = text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'#+ '), '')
        .replaceAll(RegExp(r'[•\-] '), '')
        .replaceAll('🌸', '')
        .replaceAll('🌺', '')
        .replaceAll('💐', '')
        .replaceAll('🌻', '')
        .replaceAll('🌷', '')
        .replaceAll('📷', '')
        .replaceAll('📍', '')
        .replaceAll('💡', '')
        .replaceAll('🔑', '')
        .replaceAll('🔍', '')
        .replaceAll('🗺️', '')
        .replaceAll('📅', '')
        .replaceAll('💬', '')
        .replaceAll('❌', '')
        .replaceAll('⚠️', '');
    await _tts.speak(plainText);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌸', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('花语Bot', style: TextStyle(fontSize: 18)),
          ],
        ),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              itemCount: _chatService.messages.length,
              itemBuilder: (context, index) {
                final msg = _chatService.messages[index];
                return ChatMessageWidget(
                  message: msg,
                  onSpeak: msg.role == 'assistant'
                      ? () => _speakResponse(msg.content)
                      : null,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 22),
                  CircleAvatar(radius: 14, backgroundColor: appGreen, child: Text('🌸', style: TextStyle(fontSize: 13))),
                  SizedBox(width: 10),
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice input — uses keyboard's built-in voice input
            GestureDetector(
              onTap: _openVoiceInput,
              child: Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(
                  color: appLightPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, color: appPink, size: 22),
              ),
            ),
            const SizedBox(width: 6),
            // Image upload
            GestureDetector(
              onTap: _isLoading ? null : _sendImage,
              child: Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(
                  color: appLightPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_a_photo, color: appPink, size: 20),
              ),
            ),
            const SizedBox(width: 6),
            // Text input
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _sendText(),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '输入消息，或上传花卉图片...',
                  filled: true,
                  fillColor: appWarmBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Send
            GestureDetector(
              onTap: _isLoading ? null : _sendText,
              child: Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(
                  color: appGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
