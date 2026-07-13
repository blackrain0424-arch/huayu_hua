import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/flower_data.dart';
import 'supabase_service.dart';

class ChatMessage {
  final String role;
  final String content;
  final String? imageBase64;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.imageBase64,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'imageBase64': imageBase64,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        imageBase64: json['imageBase64'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class ChatService {
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;
  ChatService._();

  // ---- Chat history ----
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void addAssistantMessage(String content) {
    _messages.add(ChatMessage(role: 'assistant', content: content));
  }

  void clearHistory() {
    _messages.clear();
  }

  // ---- Offline local flower matching ----

  String _matchLocalFlower(String query) {
    final q = query.toLowerCase();
    final matched = <String>{};

    for (final spot in flowerSpots) {
      for (final flower in spot.flowers) {
        if (q.contains(flower.toLowerCase())) {
          matched.add(
            '🌸 **$flower** — ${spot.name}\n'
            '   分布：${spot.name}\n   观赏季节：${spot.bestSeason}\n   花语：${spot.flowerLanguage}',
          );
        }
      }
      if (q.contains(spot.name.toLowerCase())) {
        for (final flower in spot.flowers) {
          matched.add(
            '🌸 **$flower** — ${spot.name}\n'
            '   分布：${spot.name}\n   观赏季节：${spot.bestSeason}\n   花语：${spot.flowerLanguage}',
          );
        }
      }
    }
    if (matched.isNotEmpty) return matched.join('\n\n');

    const keywords = {
      '樱花': '🌸 **樱花**\n分布：武汉大学、北京玉渊潭、青岛中山公园、西安青龙寺、无锡鼋头渚\n观赏季节：3月-4月\n花语：生命、纯洁、高尚。',
      '牡丹': '🌸 **牡丹**\n分布：洛阳、菏泽\n观赏季节：4月\n花语：富贵、圆满、雍容华贵。',
      '荷花': '🌸 **荷花**\n分布：杭州西湖、苏州拙政园\n观赏季节：6月-8月\n花语：清白、坚贞、纯洁。',
      '梅花': '🌸 **梅花**\n分布：南京梅花山\n观赏季节：2月-3月\n花语：坚强、高洁、谦虚。',
      '桃花': '🌸 **桃花**\n分布：林芝、成都龙泉山\n观赏季节：3月-4月\n花语：爱情、美好生活。',
      '薰衣草': '🌸 **薰衣草**\n分布：伊犁\n观赏季节：6月-7月\n花语：等待爱情、宁静、浪漫。',
      '油菜': '🌸 **油菜花**\n分布：婺源\n观赏季节：3月-4月\n花语：希望、丰收和春天的生命力。',
      '桂花': '🌸 **桂花**\n分布：桂林漓江\n观赏季节：9月-10月\n花语：富贵、吉祥、芳誉。',
      '杜鹃': '🌸 **杜鹃**\n分布：昆明\n观赏季节：2月-5月\n花语：热烈、爱的喜悦。',
      '山茶': '🌸 **山茶花**\n分布：大理、昆明\n观赏季节：1月-4月\n花语：理想的爱、谦逊。',
      '向日葵': '🌸 **向日葵**\n分布：广州百万葵园\n观赏季节：全年\n花语：沉默的爱、忠诚、阳光。',
      '琼花': '🌸 **琼花**\n分布：扬州瘦西湖\n观赏季节：4月\n花语：纯洁、高贵、独一无二。',
      '格桑花': '🌸 **格桑花**\n分布：拉萨\n观赏季节：6月-9月\n花语：幸福、美好时光、吉祥如意。',
    };
    for (final entry in keywords.entries) {
      if (q.contains(entry.key)) return entry.value;
    }
    return '';
  }

  // ---- Call Supabase Edge Function ----

  Future<String> _callEdgeFunction({
    required String userText,
    String? imageBase64,
  }) async {
    try {
      // Build messages array for the edge function
      final apiMsgs = <Map<String, dynamic>>[];

      // Add recent context
      final recent = _messages.length > 10
          ? _messages.sublist(_messages.length - 10)
          : _messages;
      for (final m in recent) {
        apiMsgs.add({'role': m.role, 'content': m.content});
      }

      // Add current user message
      if (imageBase64 != null && imageBase64.isNotEmpty) {
        apiMsgs.add({
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'},
            },
            {
              'type': 'text',
              'text': userText.isEmpty ? '请问这是什么花？请给出花名、分布范围、观赏季节和花语。' : userText,
            },
          ],
        });
      } else {
        apiMsgs.add({'role': 'user', 'content': userText});
      }

      final sb = SupabaseService().client;
      final res = await sb.functions.invoke(
        'chat',
        body: {
          'messages': apiMsgs,
          'hasImage': imageBase64 != null && imageBase64.isNotEmpty,
          'userText': userText,
        },
      );

      final data = res.data;
      if (data is Map) {
        if (data['error'] != null) {
          return '❌ AI 服务返回错误：${data['error']}\n${data['detail'] ?? ''}';
        }
        return data['content'] as String? ?? 'AI 返回了空回复';
      }

      return '❌ Edge Function 返回格式异常';
    } on FunctionException catch (e) {
      return '❌ Edge Function 调用失败 (${e.status})\n${e.details ?? e.reasonPhrase}';
    } catch (e) {
      return '❌ 连接 AI 服务失败：$e\n\n请检查网络连接，或确认 Edge Function 已部署。';
    }
  }

  // ---- Public send method ----

  Future<ChatMessage> sendMessage(String text, {String? imageBase64}) async {
    final userMsg = ChatMessage(
      role: 'user',
      content: text.isEmpty ? '请识别图片中的花卉' : text,
      imageBase64: imageBase64,
    );
    _messages.add(userMsg);

    String replyText;

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      // Image flow — try edge function, fall back to local
      final aiReply = await _callEdgeFunction(
        userText: text,
        imageBase64: imageBase64,
      );

      if (aiReply.startsWith('❌')) {
        // Edge function failed — use local matching
        final local = _matchLocalFlower(text);
        replyText = '📷 收到你的花卉照片！\n\n⚠️ AI 识图服务暂不可用。\n\n$aiReply\n\n'
            '${local.isNotEmpty ? '🔍 本地花库匹配：\n\n$local' : ''}';
      } else {
        replyText = aiReply;
      }
    } else {
      // Text-only flow — try edge function, fall back to local
      final aiReply = await _callEdgeFunction(userText: text);

      if (aiReply.startsWith('❌')) {
        final local = _matchLocalFlower(text);
        replyText = local.isNotEmpty ? local : _offlineFallback();
      } else {
        replyText = aiReply;
      }
    }

    final assistantMsg = ChatMessage(role: 'assistant', content: replyText);
    _messages.add(assistantMsg);
    return assistantMsg;
  }

  String _offlineFallback() {
    return '你好！我是花语Bot 🌸\n\n'
        '我目前正在连接 AI 服务，请稍后再试。\n\n'
        '你可以试试问我：\n'
        '- "牡丹的花语是什么？"\n'
        '- "4月去哪里赏花？"\n'
        '- "樱花分布在哪里？"';
  }
}
