class DailyFlower {
  final String name;
  final String emoji;
  final String alias;
  final String poem;
  final String flowerLanguage;
  final String description;
  final String bestPlace;
  final String? imagePath; // 新增：图片路径

  const DailyFlower({
    required this.name,
    required this.emoji,
    required this.alias,
    required this.poem,
    required this.flowerLanguage,
    required this.description,
    required this.bestPlace,
    this.imagePath, // 可选参数
  });
}
