import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('数据管理', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          _buildMenuGroup(
            children: [
              _buildMenuItem(
                icon: Icons.history,
                title: '清空浏览记录',
                subtitle: '删除所有浏览过的花卉记录',
                onTap: () => _confirmClear(context, '浏览记录', StorageService().clearBrowseRecords),
              ),
              _buildMenuItem(
                icon: Icons.camera_alt_outlined,
                title: '清空上传记录',
                subtitle: '删除所有上传过的花卉照片信息',
                onTap: () => _confirmClear(context, '上传记录', StorageService().clearUploadRecords),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Text('隐私与权限', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          _buildMenuGroup(
            children: [
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: '定位权限',
                subtitle: '管理应用的定位权限',
                onTap: () => Geolocator.openAppSettings(),
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                subtitle: '了解我们如何保护你的数据',
                onTap: () => _showPrivacyPolicy(context),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Text('关于与反馈', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          _buildMenuGroup(
            children: [
              _buildMenuItem(
                icon: Icons.info_outline,
                title: '关于华语花',
                subtitle: '内测版 0.1.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: '华语花',
                    applicationVersion: '0.1.0 内测版',
                    applicationIcon: const Text('🌸', style: TextStyle(fontSize: 32)),
                    children: const [
                      Text('华语花是一款基于地图的花卉发现 App。'),
                      SizedBox(height: 8),
                      Text('循着花期，去看中国的春夏秋冬。'),
                    ],
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.feedback_outlined,
                title: '内测反馈',
                subtitle: '告诉我们使用中遇到的问题或建议',
                onTap: () => _showFeedback(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, String label, VoidCallback onClear) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('清空$label'),
        content: Text('确定要清空所有$label吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              onClear();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label已清空')),
              );
            },
            child: const Text('确定清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '华语花 隐私政策\n\n'
            '1. 数据存储：你的浏览记录和上传照片均存储在手机本地，我们不会上传到任何服务器。\n\n'
            '2. 定位权限：定位权限仅用于在地图上显示你的当前位置，位置信息不会上传或分享给第三方。\n\n'
            '3. 相机与相册权限：仅在你主动上传照片时使用，照片文件仅保存在你的设备上。\n\n'
            '4. 数据清除：你可以随时在设置中清空浏览记录和上传记录。卸载 App 将同时清除所有本地数据。\n\n'
            '5. 联系方式：如有隐私相关问题，请通过内测反馈渠道联系我们。',
            style: TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('我知道了')),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('内测反馈'),
        content: const SingleChildScrollView(
          child: Text(
            '感谢参与华语花内测！\n\n'
            '你可以在以下渠道提交反馈：\n\n'
            '📧 邮箱反馈：huayuhua@example.com\n\n'
            '💬 微信群：华语花内测交流群\n\n'
            '反馈内容包括：\n'
            '• 遇到的使用问题或闪退情况\n'
            '• 希望增加的功能\n'
            '• 界面与交互体验建议\n'
            '• 花卉数据纠错与补充\n\n'
            '你的每一条反馈都对我们很重要 🌸',
            style: TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  Widget _buildMenuGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: appLightPink, child: Icon(icon, color: appPink)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
