import 'package:flutter/material.dart';
import '../models/flower_spot.dart';
import '../data/flower_data.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/flower_image_widget.dart';
import 'flower_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<FlowerSpot> favSpots = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final favNames = StorageService().getFavorites();
    setState(() {
      favSpots = flowerSpots.where((s) => favNames.contains(s.name)).toList();
    });
  }

  void _navigateToDetail(FlowerSpot spot) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FlowerDetailPage(spot: spot)),
    );
    _loadFavorites();
  }

  void _unfavorite(FlowerSpot spot) {
    StorageService().toggleFavorite(spot.name);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已取消收藏「${spot.name}」')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('我的收藏'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: favSpots.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '还没有收藏地点',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '在花卉详情页点击❤️收藏喜欢的地点',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favSpots.length,
              itemBuilder: (context, index) {
                final spot = favSpots[index];
                return _buildFavCard(spot);
              },
            ),
    );
  }

  Widget _buildFavCard(FlowerSpot spot) {
    return GestureDetector(
      onTap: () => _navigateToDetail(spot),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: FlowerImageWidget(
                flowerNames: spot.flowers,
                size: 46,
                circle: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spot.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${spot.flowers.join('、')} · ${spot.bestSeason}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _unfavorite(spot),
              tooltip: '取消收藏',
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
