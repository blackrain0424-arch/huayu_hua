import 'dart:io';
import 'package:flutter/material.dart';

class PhotoViewerPage extends StatelessWidget {
  final String imagePath;
  final String title;

  const PhotoViewerPage({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    final fileExists = file.existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: fileExists
          ? InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Image.file(file),
              ),
            )
          : const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('图片文件不存在', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
    );
  }
}
