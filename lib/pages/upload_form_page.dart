import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/upload_record.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';
import 'location_picker_page.dart';

class UploadFormPage extends StatefulWidget {
  const UploadFormPage({super.key});

  @override
  State<UploadFormPage> createState() => _UploadFormPageState();
}

class _UploadFormPageState extends State<UploadFormPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  double? _pickedLat;
  double? _pickedLng;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(source: source, maxWidth: 1920, maxHeight: 1920);
    if (xfile != null && mounted) {
      setState(() => _image = File(xfile.path));
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选择图片来源', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: appLightPink,
                child: Icon(Icons.camera_alt, color: appPink),
              ),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: appLightPink,
                child: Icon(Icons.photo_library, color: appPink),
              ),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerPage()),
    );
    if (result != null && mounted) {
      setState(() {
        _locationController.text = result['address'] as String;
        _pickedLat = result['latitude'] as double?;
        _pickedLng = result['longitude'] as double?;
      });
    }
  }

  Future<void> _save() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一张照片')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写标题')),
      );
      return;
    }

    setState(() => _saving = true);

    final record = UploadRecord(
      imagePath: _image!.path,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      location: _locationController.text.trim(),
      latitude: _pickedLat,
      longitude: _pickedLng,
      timestamp: DateTime.now(),
    );

    StorageService().addUploadRecord(record);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('上传成功 🌸')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('上传花卉照片'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _showSourcePicker,
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: appBorder),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo, size: 52, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('点击选择照片', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Text('支持拍照或从相册选取', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
                        ],
                      ),
              ),
            ),
            if (_image != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _showSourcePicker,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('更换照片'),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '照片标题 *',
                hintText: '给这张照片起个名字...',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: '拍摄地点',
                      hintText: '这束花在哪里拍的？',
                      suffixIcon: _pickedLat != null
                          ? const Icon(Icons.check_circle, color: appGreen)
                          : null,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: appGreen,
                      side: const BorderSide(color: appGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.map, size: 20),
                    label: const Text('地图选点', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: '描述',
                hintText: '说说这张照片背后的故事...',
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('保存上传', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
