/// 花名 → 实景图片路径映射。
/// 所有图片存放于 assets/flowers/ 目录下。
class FlowerImageMapper {
  FlowerImageMapper._();

  static const _basePath = 'assets/flowers';

  /// 花名 → 文件名（不含路径前缀）
  static const Map<String, String> _nameToFile = {
    // ===== 直接匹配（花名与文件名一致） =====
    '梅花': '梅花.jpg',
    '腊梅': '腊梅.jpg',
    '水仙': '水仙.jpg',
    '迎春花': '迎春花.jpg',
    '玉兰': '玉兰.jpg',
    '桃花': '桃花.jpg',
    '樱花': '樱花.jpg',
    '杏花': '杏花.jpg',
    '梨花': '梨花.jpg',
    '牡丹': '牡丹.jpg',
    '琼花': '琼花.jpg',
    '油菜花': '油菜花.jpg',
    '芍药': '芍药.jpg',
    '蔷薇': '蔷薇.jpg',
    '荷花': '荷花.jpg',
    '石榴花': '石榴花.jpg',
    '栀子花': '栀子花.jpg',
    '薰衣草': '薰衣草.jpg',
    '百合': '百合.jpg',
    '紫薇': '紫薇.jpg',
    '桂花': '桂花.jpg',
    '向日葵': '向日葵.jpg',
    '海棠花': '海棠花.jpg',
    '菊花': '菊花.jpg',
    '木芙蓉': '木芙蓉.jpg',
    '栾树花': '栾树花.jpg',
    '格桑花': '格桑花.jpg',
    '银杏': '银杏.jpg',
    '红枫': '红枫.jpg',
    '君子兰': '君子兰.jpg',
    '蟹爪兰': '蟹爪兰.jpg',
    '一品红': '一品红.jpg',

    // ===== 别名/变体映射 =====
    '山茶': '山茶花.jpg',
    '山茶花': '山茶花.jpg',
    '杜鹃': '杜鹃花.jpg',
    '杜鹃花': '杜鹃花.jpg',
    '芙蓉': '木芙蓉.jpg',
    '耐冬（山茶）': '山茶花.jpg',
    '茶花': '山茶花.jpg',
    '月季': '月季.jpg',
    '丁香': '丁香.jpg',
    '玫瑰': '玫瑰.jpg',
    '白玉兰': '玉兰.jpg',
    '格桑': '格桑花.jpg',

    // ===== 以下花种暂无实景图片 =====
    // 热带花卉、木棉花、簕杜鹃/三角梅、兰花、茉莉花、朱槿
  };

  /// 根据花名获取图片路径，没有对应图片返回 null。
  static String? getImagePath(String flowerName) {
    // 先精确匹配
    if (_nameToFile.containsKey(flowerName)) {
      return '$_basePath/${_nameToFile[flowerName]}';
    }
    // 模糊匹配：花名.contains(图片花名) 或 图片花名.contains(花名)
    for (final entry in _nameToFile.entries) {
      if (flowerName.contains(entry.key) || entry.key.contains(flowerName)) {
        return '$_basePath/${entry.value}';
      }
    }
    return null;
  }

  /// 从一组花名中获取第一个有图片的路径。
  static String? getFirstImagePath(List<String> flowerNames) {
    for (final name in flowerNames) {
      final path = getImagePath(name);
      if (path != null) return path;
    }
    return null;
  }
}
