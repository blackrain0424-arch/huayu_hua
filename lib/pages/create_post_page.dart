import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import '../widgets/common_widgets.dart';
import '../data/flower_data.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _imagePaths = [];
  bool _uploading = false;
  bool _locating = false;
  String? _selectedFlowerTag;
  static const _maxImages = 9;

  Future<void> _pickImages() async {
    final remaining = _maxImages - _imagePaths.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多选择 9 张图片')),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(maxWidth: 1200, limit: remaining);
    if (picked.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(picked.map((f) => f.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请先开启手机定位服务')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('位置权限被拒绝')),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请在系统设置中开启位置权限')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _locationController.text = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取位置失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入文字或选择图片')),
      );
      return;
    }

    setState(() => _uploading = true);

    final imageUrls = <String>[];
    if (_imagePaths.isNotEmpty) {
      final sb = SupabaseService().client;
      final uid = AuthService().currentUser?.id ?? 'unknown';
      for (int i = 0; i < _imagePaths.length; i++) {
        try {
          final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          await sb.storage.from('post-images').upload(fileName, File(_imagePaths[i]));
          imageUrls.add(sb.storage.from('post-images').getPublicUrl(fileName));
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('第${i + 1}张图片上传失败：$e'), duration: const Duration(seconds: 4)),
            );
          }
        }
      }
    }

    try {
      await CommunityService().createPost(
        content: content,
        imageUrls: imageUrls,
        flowerTag: _selectedFlowerTag,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      );

      if (mounted) {
        setState(() => _uploading = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败：$e'), duration: const Duration(seconds: 4)),
        );
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('发布动态'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _uploading ? null : _submit,
            child: _uploading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('发布', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appBorder),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: '分享你的赏花故事...',
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),
                  if (_imagePaths.isNotEmpty) _buildImageGrid(),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.image_outlined, color: appGreen),
                    title: Text('添加图片 (${_imagePaths.length}/$_maxImages)', style: const TextStyle(fontSize: 15)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _pickImages,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.local_florist, color: appGreen),
                    title: Text(
                      _selectedFlowerTag ?? '标记花卉（可选）',
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedFlowerTag != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showFlowerPicker,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: appGreen),
                    title: SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: '添加位置（可选）',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 15),
                        readOnly: true,
                      ),
                    ),
                    trailing: TextButton.icon(
                      onPressed: _locating ? null : _getCurrentLocation,
                      icon: _locating
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(_locating ? '定位中...' : '获取当前位置', style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final count = _imagePaths.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count <= 1 ? 1 : (count <= 4 ? 2 : 3),
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(_imagePaths[index]), fit: BoxFit.cover),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFlowerPicker() {
    final flowers = <String>{};
    for (final spot in flowerSpots) {
      flowers.addAll(spot.flowers);
    }
    final flowerList = flowers.toList()..sort();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择花卉', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: flowerList.map((f) {
                final selected = _selectedFlowerTag == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  selectedColor: appLightPink,
                  onSelected: (val) {
                    setState(() => _selectedFlowerTag = val ? f : null);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
