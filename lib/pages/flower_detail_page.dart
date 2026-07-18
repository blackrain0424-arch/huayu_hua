import 'package:flutter/material.dart';
import '../models/flower_spot.dart';
import '../models/browse_record.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flower_image_widget.dart';
import '../utils/flower_image_mapper.dart';

class FlowerDetailPage extends StatefulWidget {
  final FlowerSpot spot;

  const FlowerDetailPage({super.key, required this.spot});

  @override
  State<FlowerDetailPage> createState() => _FlowerDetailPageState();
}

class _FlowerDetailPageState extends State<FlowerDetailPage> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    StorageService().addBrowseRecord(BrowseRecord(
      spotName: widget.spot.name,
      flowers: widget.spot.flowers,
      timestamp: DateTime.now(),
    ));
    _isFav = StorageService().isFavorite(widget.spot.name);
  }

  void _toggleFav() {
    setState(() {
      StorageService().toggleFavorite(widget.spot.name);
      _isFav = !_isFav;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFav ? '已收藏「${widget.spot.name}」🌸' : '已取消收藏「${widget.spot.name}」')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: Text('${spot.name} · 花卉详情'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFav,
            tooltip: _isFav ? '取消收藏' : '收藏',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildImagePlaceholder(),
          const SizedBox(height: 16),
          buildSectionCard(
            icon: Icons.local_florist,
            title: '这里有什么花？',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: spot.flowers.map((flower) {
                return Chip(
                  label: Text(flower),
                  backgroundColor: appLightPink,
                  labelStyle: const TextStyle(color: appPink, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          buildSectionCard(
            icon: Icons.calendar_month,
            title: '最佳花期',
            child: Text(spot.bestSeason, style: const TextStyle(fontSize: 16, height: 1.6)),
          ),
          const SizedBox(height: 14),
          buildSectionCard(
            icon: Icons.menu_book,
            title: '花卉介绍',
            child: Text(
              spot.description,
              style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(height: 14),
          buildSectionCard(
            icon: Icons.favorite,
            title: '花语',
            child: Text(
              spot.flowerLanguage,
              style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(height: 14),
          buildSectionCard(
            icon: Icons.tips_and_updates,
            title: '出行小提示',
            child: Text(
              spot.travelTip,
              style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: appGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.map),
              label: const Text('返回地图', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final spot = widget.spot;
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC1D6), Color(0xFFFFF1B8), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 24,
            top: 20,
            child: FlowerImageWidget(
              flowerNames: spot.flowers,
              size: 80,
              borderRadius: 16,
            ),
          ),
          Positioned(
            left: 22,
            bottom: 24,
            right: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 2))],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  spot.flowers.join('、'),
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0, 1))],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final spot = widget.spot;
    final imagePath = FlowerImageMapper.getFirstImagePath(spot.flowers);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imagePath != null
            ? Image.asset(
                imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImageFallback(spot);
                },
              )
            : _buildImageFallback(spot),
      ),
    );
  }

  Widget _buildImageFallback(FlowerSpot spot) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFC8E6C9), Color(0xFFFFF1B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlowerImageWidget(
              flowerNames: spot.flowers,
              size: 72,
              borderRadius: 16,
            ),
            const SizedBox(height: 8),
            Text(
              spot.flowers.join(' · '),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
