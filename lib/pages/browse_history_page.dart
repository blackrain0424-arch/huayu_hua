import 'package:flutter/material.dart';
import '../models/browse_record.dart';
import '../models/flower_spot.dart';
import '../data/flower_data.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';
import 'flower_detail_page.dart';

class BrowseHistoryPage extends StatefulWidget {
  const BrowseHistoryPage({super.key});

  @override
  State<BrowseHistoryPage> createState() => _BrowseHistoryPageState();
}

class _BrowseHistoryPageState extends State<BrowseHistoryPage> {
  List<BrowseRecord> records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      records = StorageService().getBrowseRecords();
    });
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空浏览记录'),
        content: const Text('确定要清空所有浏览记录吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              StorageService().clearBrowseRecords();
              Navigator.pop(ctx);
              _loadRecords();
            },
            child: const Text('确定清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BrowseRecord record) {
    FlowerSpot? spot;
    try {
      spot = flowerSpots.firstWhere((s) => s.name == record.spotName);
    } catch (_) {}
    if (spot != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FlowerDetailPage(spot: spot!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('浏览记录'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        actions: records.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _clearAll,
                  tooltip: '清空记录',
                ),
              ]
            : null,
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '暂无浏览记录',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '去看看花卉详情，记录你的赏花足迹',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _buildRecordCard(record);
              },
            ),
    );
  }

  Widget _buildRecordCard(BrowseRecord record) {
    final timeStr =
        '${record.timestamp.month}月${record.timestamp.day}日 ${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () => _navigateToDetail(record),
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
                color: appLightPink,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('🌸', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.spotName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.flowers.join('、'),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
