import 'package:flutter/material.dart';
import '../data/daily_flower_data.dart';
import '../widgets/common_widgets.dart';

class DailyFlowerCard extends StatelessWidget {
  const DailyFlowerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final flower = getTodayFlower();

    return GestureDetector(
      onTap: () => _showFlowerDetail(context, flower),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFFFF8E1), Color(0xFFFCE4EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8D5C4), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: appGreen),
                      const SizedBox(width: 4),
                      Text(
                        _formatToday(),
                        style: const TextStyle(fontSize: 12, color: appGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '点击查看详情 →',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 优先显示图片，没有则显示emoji
                _buildFlowerIcon(flower),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flower.name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '别称：${flower.alias}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                flower.poem,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.brown.shade700,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTag(Icons.favorite, '花语：${flower.flowerLanguage}'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildTag(Icons.description_outlined, flower.description),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: appPink),
                const SizedBox(width: 4),
                Text(
                  '推荐观赏地：${flower.bestPlace}',
                  style: const TextStyle(fontSize: 13, color: appPink, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowerIcon(dynamic flower) {
    // 尝试加载图片，失败则显示emoji
    if (flower.imagePath != null && flower.imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          flower.imagePath!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 图片加载失败，回退到emoji
            return Text(
              flower.emoji,
              style: const TextStyle(fontSize: 56),
            );
          },
        ),
      );
    }
    // 没有图片路径，显示emoji
    return Text(
      flower.emoji,
      style: const TextStyle(fontSize: 56),
    );
  }

  Widget _buildFlowerDetailIcon(dynamic flower) {
    // 详情页的大图标
    if (flower.imagePath != null && flower.imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          flower.imagePath!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              flower.emoji,
              style: const TextStyle(fontSize: 72),
            );
          },
        ),
      );
    }
    return Text(
      flower.emoji,
      style: const TextStyle(fontSize: 72),
    );
  }

  void _showFlowerDetail(BuildContext context, dynamic flower) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildFlowerDetailIcon(flower),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      flower.name,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      '别称：${flower.alias}',
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8D5C4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories, size: 18, color: appPink),
                            const SizedBox(width: 8),
                            const Text('诗词典故', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: appPink)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          flower.poem,
                          style: TextStyle(fontSize: 15, height: 1.7, color: Colors.brown.shade800, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: appBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(Icons.favorite, '花语', flower.flowerLanguage),
                        const Divider(height: 20),
                        _detailRow(Icons.description, '简介', flower.description),
                        const Divider(height: 20),
                        _detailRow(Icons.location_on, '推荐观赏地', flower.bestPlace),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '每天打开，遇见不同的花 🌸',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: appGreen),
        const SizedBox(width: 10),
        Text('$label：', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14, height: 1.6)),
        ),
      ],
    );
  }

  String _formatToday() {
    final now = DateTime.now();
    const weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDay = weekDays[now.weekday - 1];
    return '${now.month}月${now.day}日 $weekDay';
  }

  Widget _buildTag(IconData icon, String text) {
    return Flexible(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
