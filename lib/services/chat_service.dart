import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/flower_data.dart';
import '../data/city_flower_data.dart';
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

  // ---- Offline local flower matching (覆盖全部 30+ 城市市花、35 种花卉图鉴、22 个赏花地) ----

  String _matchLocalFlower(String query) {
    final q = query.toLowerCase();
    final matched = <String>{};

    // 1. 匹配赏花地点数据 (22 spots)
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

    // 2. 匹配城市市花数据 (42 cities)
    for (final city in cityFlowers) {
      if (q.contains(city.city.toLowerCase()) ||
          q.contains(city.flower.toLowerCase())) {
        matched.add(
          '🏙️ **${city.city}市花：${city.flower}**\n'
          '   ${city.description}',
        );
      }
    }

    if (matched.isNotEmpty) return matched.join('\n\n');

    // 3. 全量关键词匹配（覆盖不在 flowerSpots 中的花卉 + 城市市花别名）
    const keywords = <String, String>{
      // ===== 赏花地已有的 (flowerSpots 匹配不到时的兜底) =====
      '樱花': '🌸 **樱花**\n分布：武汉大学、北京玉渊潭、青岛中山公园、西安青龙寺、无锡鼋头渚\n观赏季节：3月-4月\n花语：生命、纯洁、高尚。',
      '牡丹': '🌸 **牡丹**\n分布：洛阳、菏泽\n观赏季节：4月\n花语：富贵、圆满、雍容华贵。',
      '荷花': '🌸 **荷花**\n分布：杭州西湖、苏州拙政园\n观赏季节：6月-8月\n花语：清白、坚贞、纯洁。',
      '梅花': '🌸 **梅花**\n分布：南京梅花山\n观赏季节：2月-3月\n花语：坚强、高洁、谦虚。',
      '桃花': '🌸 **桃花**\n分布：林芝、成都龙泉山\n观赏季节：3月-4月\n花语：爱情、美好生活。',
      '薰衣草': '🌸 **薰衣草**\n分布：伊犁\n观赏季节：6月-7月\n花语：等待爱情、宁静、浪漫。',
      '油菜': '🌸 **油菜花**\n分布：婺源\n观赏季节：3月-4月\n花语：希望、丰收和春天的生命力。',
      '桂花': '🌸 **桂花**\n分布：桂林漓江\n观赏季节：9月-10月\n花语：富贵、吉祥、芳誉。',
      '杜鹃': '🌸 **杜鹃花**\n分布：昆明\n观赏季节：2月-5月\n花语：热烈、爱的喜悦。',
      '山茶': '🌸 **山茶花**\n分布：大理、昆明\n观赏季节：1月-4月\n花语：理想的爱、谦逊。',
      '向日葵': '🌸 **向日葵**\n分布：广州百万葵园\n观赏季节：全年\n花语：沉默的爱、忠诚、阳光。',
      '琼花': '🌸 **琼花**\n分布：扬州瘦西湖\n观赏季节：4月\n花语：纯洁、高贵、独一无二。',
      '格桑花': '🌸 **格桑花**\n分布：拉萨\n观赏季节：6月-9月\n花语：幸福、美好时光、吉祥如意。',

      // ===== 每日花历专有花卉 (不在 flowerSpots 赏花地中) =====
      '腊梅': '🌸 **腊梅**\n别称：黄梅、雪里花\n分布：南京梅花山、苏州拙政园\n观赏季节：12月-2月\n花语：坚毅、高洁、慈爱。',
      '水仙': '🌸 **水仙**\n别称：凌波仙子、金盏银台\n分布：漳州水仙花基地\n观赏季节：1月-2月\n花语：纯洁、吉祥、思念。',
      '迎春花': '🌸 **迎春花**\n别称：金腰带、小黄花\n分布：北京颐和园\n观赏季节：2月-3月\n花语：希望、新生、永恒的爱。',
      '玉兰': '🌸 **玉兰**\n别称：望春花、木兰\n分布：北京大觉寺\n观赏季节：2月-3月\n花语：纯洁、高尚、报恩。',
      '杏花': '🌸 **杏花**\n别称：及第花、红杏\n分布：西安大雁塔\n观赏季节：3月\n花语：少女的羞涩、幸运、美好。',
      '梨花': '🌸 **梨花**\n别称：玉雨花、瀛洲玉雨\n分布：成都龙泉山\n观赏季节：3月-4月\n花语：纯真、唯美、永不分离。',
      '芍药': '🌸 **芍药**\n别称：花相、婪尾春、将离\n分布：扬州瘦西湖\n观赏季节：5月\n花语：依依惜别、情深意长、美丽动人。',
      '蔷薇': '🌸 **蔷薇**\n别称：买笑花、野蔷薇\n分布：南京颐和路\n观赏季节：5月\n花语：美好、思念、爱的誓约。',
      '石榴花': '🌸 **石榴花**\n别称：丹若、金罂\n分布：西安华清宫\n观赏季节：5月-6月\n花语：热情、成熟、多子多福。',
      '栀子花': '🌸 **栀子花**\n别称：玉荷花、越桃\n分布：苏州园林\n观赏季节：6月\n花语：永恒的爱、纯洁、喜悦。',
      '百合': '🌸 **百合**\n别称：山丹、夜合花\n分布：昆明\n观赏季节：7月\n花语：纯洁、高贵、百年好合。',
      '紫薇': '🌸 **紫薇**\n别称：百日红、痒痒树\n分布：杭州西湖\n观赏季节：7月-9月\n花语：好运、沉迷、长寿。',
      '海棠花': '🌸 **海棠花**\n别称：花中神仙、断肠花\n分布：北京颐和园\n观赏季节：8月\n花语：温和、美丽、离愁别绪。',
      '菊花': '🌸 **菊花**\n别称：寿客、金英、秋华\n分布：开封菊花文化节\n观赏季节：9月-10月\n花语：高洁、长寿、隐逸、君子之风。',
      '木芙蓉': '🌸 **木芙蓉**\n别称：拒霜花、木莲\n分布：成都\n观赏季节：9月-10月\n花语：纤细之美、贞洁、纯情。',
      '栾树花': '🌸 **栾树花**\n别称：灯笼树、国庆花\n分布：杭州西湖\n观赏季节：9月-10月\n花语：喜庆、丰收、祝福。',
      '银杏': '🌸 **银杏**\n别称：公孙树、活化石\n分布：北京钓鱼台银杏大道\n观赏季节：10月-11月\n花语：坚韧、沉着、永恒的爱。',
      '红枫': '🌸 **红枫**\n别称：丹枫、霜叶\n分布：北京香山\n观赏季节：10月-11月\n花语：热情、思念、岁月的沉淀。',
      '君子兰': '🌸 **君子兰**\n别称：剑叶石蒜、大花君子兰\n分布：长春君子兰基地\n观赏季节：11月-12月\n花语：高贵、端庄、君子之风。',
      '蟹爪兰': '🌸 **蟹爪兰**\n别称：圣诞仙人掌、锦上添花\n分布：广州花城广场\n观赏季节：12月\n花语：喜庆、热情、锦上添花。',
      '一品红': '🌸 **一品红**\n别称：圣诞红、猩猩木\n分布：广州花城广场\n观赏季节：12月\n花语：祝福、热情、普天同庆。',

      // ===== 城市市花补充 (部分花名在 flowerSpots 中无对应) =====
      '月季': '🌸 **月季** — 北京市花、天津市花、郑州市花、石家庄市花等\n别称：月月红、长春花\n花语：爱情与和平、美丽与热情。北京月季遍布街头巷尾，天津素有"月季之乡"美誉。',
      '木棉花': '🌸 **木棉花** — 广州市花\n别称：英雄花、攀枝花\n花语：珍惜眼前的幸福、英雄气概。花开时满树火红、不叶而花。',
      '茉莉花': '🌸 **茉莉花** — 福州市花\n别称：香魂\n花语：纯洁、亲切、喜爱。福州茉莉花茶闻名天下。',
      '丁香': '🌸 **丁香** — 哈尔滨市花、西宁市花、呼和浩特市花\n别称：百结、情客\n花语：纯洁、初恋、记忆。每年五月丁香节满城飘香。',
      '玫瑰': '🌸 **玫瑰** — 兰州市花、银川市花、沈阳市花、乌鲁木齐市花\n别称：徘徊花\n花语：爱情、美丽、热情。兰州苦水玫瑰全国闻名。',
      '兰花': '🌸 **兰花** — 贵阳市花\n别称：幽兰、国香\n花语：高洁、清雅、爱国。贵阳"贵兰"在兰花界享有盛誉。',
      '朱槿': '🌸 **朱槿** — 南宁市花\n别称：扶桑花、大红花\n花语：热情、纤细之美。花色鲜红、四季常开。',
      '三角梅': '🌸 **三角梅（簕杜鹃）** — 深圳市花、厦门市花、三亚市花\n别称：叶子花、九重葛\n花语：热情、坚韧、永不言弃。生命力顽强、花期极长。',
      '白玉兰': '🌸 **白玉兰** — 上海市花\n别称：望春花、玉堂春\n花语：纯洁、高尚、开路先锋。洁白如玉、清香四溢。',
      '芙蓉': '🌸 **芙蓉（木芙蓉）** — 成都市花\n别称：拒霜花\n花语：纤细之美、贞洁。成都自古称"蓉城"，芙蓉花开粉白相间。',
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
