import 'package:flutter/material.dart';
import '../utils/flower_image_mapper.dart';

/// 花卉图片组件。
///
/// 优先显示 [imagePath]（若提供），否则通过 [flowerName] 查找实景图。
/// 加载失败或找不到图片时回退到 emoji。
class FlowerImageWidget extends StatelessWidget {
  /// 花名，用于查找对应的实景图片。
  final String? flowerName;

  /// 多花名列表，取第一个有图片的显示。
  final List<String>? flowerNames;

  /// 直接指定图片路径（优先级最高）。
  final String? imagePath;

  /// 图片/emoji 尺寸（正方形）。
  final double size;

  /// 圆角半径。
  final double borderRadius;

  /// 是否为圆形（常用于头像位置）。
  final bool circle;

  const FlowerImageWidget({
    super.key,
    this.flowerName,
    this.flowerNames,
    this.imagePath,
    this.size = 48,
    this.borderRadius = 10,
    this.circle = false,
  }) : assert(flowerName != null || flowerNames != null || imagePath != null,
            '至少提供 flowerName、flowerNames 或 imagePath 之一');

  @override
  Widget build(BuildContext context) {
    // 解析最终图片路径
    final String? resolvedPath = imagePath ??
        (flowerName != null
            ? FlowerImageMapper.getImagePath(flowerName!)
            : null) ??
        (flowerNames != null
            ? FlowerImageMapper.getFirstImagePath(flowerNames!)
            : null);

    // 确定回退 emoji
    final emoji = _getEmoji();

    if (resolvedPath != null) {
      Widget imageWidget = ClipRRect(
        borderRadius:
            circle ? BorderRadius.circular(size / 2) : BorderRadius.circular(borderRadius),
        child: Image.asset(
          resolvedPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildEmojiFallback(emoji);
          },
        ),
      );
      return SizedBox(width: size, height: size, child: imageWidget);
    }

    return SizedBox(width: size, height: size, child: _buildEmojiFallback(emoji));
  }

  Widget _buildEmojiFallback(String emoji) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF4),
        borderRadius:
            circle ? BorderRadius.circular(size / 2) : BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.55)),
    );
  }

  String _getEmoji() {
    final name = flowerName ?? flowerNames?.firstOrNull ?? '';
    if (name.contains('樱花')) return '🌸';
    if (name.contains('荷花')) return '🪷';
    if (name.contains('薰衣草')) return '💜';
    if (name.contains('油菜花')) return '🌼';
    if (name.contains('梅花')) return '🌸';
    if (name.contains('腊梅')) return '🟡';
    if (name.contains('向日葵')) return '🌻';
    if (name.contains('桃花')) return '🌸';
    if (name.contains('牡丹')) return '🌺';
    if (name.contains('山茶')) return '🌺';
    if (name.contains('琼花')) return '🤍';
    if (name.contains('桂花')) return '🌼';
    if (name.contains('格桑花')) return '🌸';
    if (name.contains('水仙')) return '🌼';
    if (name.contains('玉兰')) return '🤍';
    if (name.contains('杏花')) return '🌸';
    if (name.contains('梨花')) return '🤍';
    if (name.contains('杜鹃')) return '🌺';
    if (name.contains('芍药')) return '🌸';
    if (name.contains('蔷薇')) return '🌹';
    if (name.contains('石榴花')) return '🟥';
    if (name.contains('栀子花')) return '🤍';
    if (name.contains('百合')) return '🤍';
    if (name.contains('紫薇')) return '💜';
    if (name.contains('海棠花')) return '🌸';
    if (name.contains('菊花')) return '🌼';
    if (name.contains('木芙蓉')) return '🌸';
    if (name.contains('栾树花')) return '🟡';
    if (name.contains('银杏')) return '🍂';
    if (name.contains('红枫')) return '🍁';
    if (name.contains('君子兰')) return '🟠';
    if (name.contains('蟹爪兰')) return '🟥';
    if (name.contains('一品红')) return '🟥';
    if (name.contains('迎春花')) return '🌿';
    if (name.contains('热带')) return '🌴';
    return '🌸';
  }
}
