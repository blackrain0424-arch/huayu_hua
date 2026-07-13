import 'dart:io';
import 'package:flutter/material.dart';
import '../models/upload_record.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';
import 'photo_viewer_page.dart';

class MyUploadsPage extends StatefulWidget {
  const MyUploadsPage({super.key});

  @override
  State<MyUploadsPage> createState() => _MyUploadsPageState();
}

class _MyUploadsPageState extends State<MyUploadsPage> {
  List<UploadRecord> records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      records = StorageService().getUploadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('我的上传'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('还没有上传照片', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('在地图页点击相机按钮开始上传',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                return _buildUploadCard(records[index]);
              },
            ),
    );
  }

  Widget _buildUploadCard(UploadRecord record) {
    final time = record.timestamp;
    final timeStr =
        '${time.year}/${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    final fileExists = File(record.imagePath).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (fileExists) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotoViewerPage(
                      imagePath: record.imagePath,
                      title: record.title,
                    ),
                  ),
                );
              }
            },
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: fileExists
                  ? Image.file(File(record.imagePath), fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                if (record.location.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(record.location,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      ),
                    ],
                  ),
                ],
                if (record.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    record.description,
                    style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade700),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
