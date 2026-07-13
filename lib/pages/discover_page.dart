import 'package:flutter/material.dart';
import '../data/flower_data.dart';
import '../widgets/common_widgets.dart';
import '../widgets/daily_flower_card.dart';
import 'flower_detail_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('发现花事'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTopBanner(),
          const SizedBox(height: 18),
          const DailyFlowerCard(),
          const SizedBox(height: 4),
          const Text('本季推荐', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRecommendCard(
            context,
            emoji: '🌸',
            title: '春日牡丹',
            subtitle: '洛阳、菏泽 · 4月前后',
            description: '牡丹雍容华贵，是春季最具代表性的观赏花卉之一。',
            color: const Color(0xFFFFEEF4),
            spotName: '洛阳',
          ),
          _buildRecommendCard(
            context,
            emoji: '🌼',
            title: '油菜花海',
            subtitle: '婺源 · 3月 - 4月',
            description: '层层梯田与金黄色花海交织，是春日旅行的经典目的地。',
            color: const Color(0xFFFFF7D6),
            spotName: '婺源',
          ),
          _buildRecommendCard(
            context,
            emoji: '💜',
            title: '薰衣草花田',
            subtitle: '伊犁 · 6月 - 7月',
            description: '夏季的伊犁有大片紫色薰衣草花田，浪漫又治愈。',
            color: const Color(0xFFF1E8FF),
            spotName: '伊犁',
          ),
          const SizedBox(height: 18),
          const Text('按月份看花', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildMonthGrid(context),
          const SizedBox(height: 18),
          const Text('赏花灵感', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildArticleTile(
            icon: Icons.camera_alt,
            title: '如何拍出好看的花卉照片？',
            subtitle: '试试逆光、低角度和虚化背景。',
            onTap: () => _showArticleDialog(context, '花卉拍照技巧', [
              '📷 逆光拍摄：让阳光从花朵背后照射，花瓣会呈现通透的质感。',
              '📐 低角度取景：蹲下来从花朵的高度拍摄，让画面更亲近自然。',
              '🌫️ 背景虚化：使用大光圈或人像模式，让花朵从背景中脱颖而出。',
              '⏰ 最佳时间：清晨和傍晚的柔和光线最适合花卉摄影。',
              '🐝 捕捉生机：等待蜜蜂或蝴蝶靠近花朵时按下快门。',
              '📱 手机技巧：使用2-3倍变焦拍摄特写，避免使用数码放大。',
            ]),
          ),
          _buildArticleTile(
            icon: Icons.calendar_month,
            title: '不同月份适合看什么花？',
            subtitle: '春看樱花牡丹，夏看荷花薰衣草。',
            onTap: () => _showArticleDialog(context, '每月赏花指南', [
              '🌸 1月-2月：梅花（南京梅花山）、山茶花（大理）',
              '🌸 3月：樱花（武汉大学、无锡鼋头渚）、桃花（林芝、成都龙泉山）',
              '🌺 4月：牡丹（洛阳、菏泽）、琼花（扬州瘦西湖）',
              '🌼 5月：杜鹃（昆明）、油菜花（婺源）',
              '🪷 6月-7月：荷花（杭州西湖、苏州拙政园）、薰衣草（伊犁）',
              '🌻 8月-9月：向日葵（广州百万葵园）',
              '🌼 10月：桂花（桂林漓江）',
              '🌸 11月-12月：温室花卉、热带花卉（西双版纳）',
            ]),
          ),
          _buildArticleTile(
            icon: Icons.eco,
            title: '文明赏花小提示',
            subtitle: '不踩踏花田，不攀折花枝，带走自己的垃圾。',
            onTap: () => _showArticleDialog(context, '文明赏花公约', [
              '🚶 沿步道观赏，不踏入花田踩踏花卉。',
              '✋ 不攀折花枝、不采摘花朵，让更多人欣赏美景。',
              '🗑️ 自带垃圾袋，随手带走所有废弃物。',
              '📸 拍照时注意脚下，不要为了取景破坏花草。',
              '🔇 保持安静，不大声喧哗，尊重其他游客。',
              '🐕 如需携带宠物，请牵好绳并避开密集花区。',
              '🚗 遵守园区停车规定，不占用花田周边道路。',
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC1D6), Color(0xFFFFF1B8), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: const [
          Positioned(
            right: 24,
            top: 18,
            child: Text('🌷', style: TextStyle(fontSize: 64)),
          ),
          Positioned(
            left: 22,
            bottom: 24,
            right: 22,
            child: Text(
              '循着花期，去看中国的春夏秋冬',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
                height: 1.3,
                shadows: [
                  Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required String spotName,
  }) {
    return GestureDetector(
      onTap: () {
        final spot = flowerSpots.firstWhere(
          (s) => s.name == spotName,
          orElse: () => flowerSpots.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FlowerDetailPage(spot: spot)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context) {
    final months = [
      {'m': '1月', 'f': '梅花', 'e': '🌸', 'spot': '南京梅花山'},
      {'m': '2月', 'f': '山茶花', 'e': '🌺', 'spot': '大理'},
      {'m': '3月', 'f': '樱花', 'e': '🌸', 'spot': '武汉大学'},
      {'m': '4月', 'f': '牡丹', 'e': '🌺', 'spot': '洛阳'},
      {'m': '5月', 'f': '杜鹃', 'e': '🌸', 'spot': '昆明'},
      {'m': '6月', 'f': '荷花', 'e': '🪷', 'spot': '杭州西湖'},
      {'m': '7月', 'f': '薰衣草', 'e': '💜', 'spot': '伊犁'},
      {'m': '8月', 'f': '荷花', 'e': '🪷', 'spot': '苏州拙政园'},
      {'m': '9月', 'f': '桂花', 'e': '🌼', 'spot': '桂林漓江'},
      {'m': '10月', 'f': '向日葵', 'e': '🌻', 'spot': '广州百万葵园'},
      {'m': '11月', 'f': '热带花卉', 'e': '🌴', 'spot': '西双版纳'},
      {'m': '12月', 'f': '格桑花', 'e': '🌸', 'spot': '拉萨'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: months.map((m) {
        return GestureDetector(
          onTap: () {
            final spot = flowerSpots.firstWhere(
              (s) => s.name == m['spot'],
              orElse: () => flowerSpots.first,
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FlowerDetailPage(spot: spot)),
            );
          },
          child: Container(
            width: (MediaQuery.of(context).size.width - 48) / 3,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: appBorder),
            ),
            child: Column(
              children: [
                Text(m['e']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Text(
                  m['m']!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  m['f']!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArticleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorder),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: appLightPink,
          child: Icon(icon, color: appPink),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showArticleDialog(BuildContext context, String title, List<String> tips) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips.map((tip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(tip, style: const TextStyle(fontSize: 15, height: 1.6)),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }
}
