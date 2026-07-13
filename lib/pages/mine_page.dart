import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/common_widgets.dart';
import 'my_uploads_page.dart';
import 'browse_history_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'login_page.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  int uploadCount = 0;
  int favCount = 0;
  String profileName = '赏花人';
  String? birthday;
  String? bio;

  @override
  void initState() {
    super.initState();
    _loadAndRefresh();
  }

  Future<void> _loadAndRefresh() async {
    await ProfileService().loadProfile();
    _refreshCounts();
  }

  void _refreshCounts() {
    final storage = StorageService();
    setState(() {
      uploadCount = storage.getUploadRecords().length;
      favCount = storage.getFavoriteCount();
      profileName = storage.getProfileName();
      birthday = storage.getBirthday();
      bio = storage.getBio();
    });
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: profileName);
    final bioCtrl = TextEditingController(text: bio ?? '');
    String? selectedBirthday = birthday;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text('🌸', style: TextStyle(fontSize: 48))),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text('编辑个人资料', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    const Text('昵称', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      maxLength: 12,
                      decoration: InputDecoration(
                        hintText: '你的昵称',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('生日', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: _parseBirthday(selectedBirthday) ?? DateTime(2000, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: now,
                          helpText: '选择生日',
                        );
                        if (picked != null) {
                          setSheetState(() {
                            selectedBirthday = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedBirthday ?? '选择生日（选填）',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: selectedBirthday != null ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    if (selectedBirthday != null)
                      TextButton(
                        onPressed: () => setSheetState(() => selectedBirthday = null),
                        child: const Text('清除生日', style: TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 18),
                    const Text('个性签名', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bioCtrl,
                      maxLength: 50,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: '写一句话介绍自己...（选填）',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final saveName = name.isNotEmpty ? name : profileName;
                          ProfileService().saveProfile(
                            name: saveName,
                            birthday: selectedBirthday,
                            bio: bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim(),
                          );
                          Navigator.pop(ctx);
                          _refreshCounts();
                        },
                        child: const Text('保存', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  DateTime? _parseBirthday(String? bd) {
    if (bd == null) return null;
    final parts = bd.split('-');
    if (parts.length == 3) {
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _editProfile,
            child: _buildUserCard(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateTo(context, const MyUploadsPage()),
                  child: _buildStatCard(number: '$uploadCount', label: '上传照片', icon: Icons.camera_alt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _navigateTo(context, const FavoritesPage()),
                  child: _buildStatCard(number: '$favCount', label: '收藏地点', icon: Icons.favorite),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildMenuGroup(
            children: [
              _buildMenuItem(
                icon: Icons.camera_alt_outlined,
                title: '我的上传',
                subtitle: '查看你上传过的花卉照片',
                onTap: () => _navigateTo(context, const MyUploadsPage()),
              ),
              _buildMenuItem(
                icon: Icons.favorite_border,
                title: '我的收藏',
                subtitle: '收藏你喜欢的赏花地点',
                onTap: () => _navigateTo(context, const FavoritesPage()),
              ),
              _buildMenuItem(
                icon: Icons.history,
                title: '浏览记录',
                subtitle: '看看最近关注过哪些花',
                onTap: () => _navigateTo(context, const BrowseHistoryPage()),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMenuGroup(
            children: [
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: '设置',
                subtitle: '数据管理、隐私与反馈',
                onTap: () => _navigateTo(context, const SettingsPage()),
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: '关于华语花',
                subtitle: '认识这个花卉地图 App',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: '华语花',
                    applicationVersion: '0.1.0',
                    applicationIcon: const Text('🌸', style: TextStyle(fontSize: 32)),
                    children: const [
                      Text('华语花是一款基于地图的花卉发现 App。'),
                      SizedBox(height: 8),
                      Text('你可以在地图上寻找各地代表性花卉，了解花期、花语和赏花地点。'),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMenuGroup(
            children: [
              _buildMenuItem(
                icon: Icons.logout,
                title: '退出登录',
                subtitle: '返回登录页面',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('退出登录'),
                      content: const Text('确定要退出当前账号吗？'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                        TextButton(
                          onPressed: () {
                            AuthService().logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                              (_) => false,
                            );
                          },
                          child: const Text('确定退出'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _refreshCounts();
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFC8E6C9), Color(0xFFFFF1B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: const Text('🌸', style: TextStyle(fontSize: 36)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profileName,
                            style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0, 2))],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit, size: 16, color: Colors.white70),
                      ],
                    ),
                    if (birthday != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.cake, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(birthday!, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                        ],
                      ),
                    ],
                    if (bio != null && bio!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '「$bio」',
                        style: TextStyle(fontSize: 13, height: 1.3, color: Colors.white.withValues(alpha: 0.85), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String number,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: appGreen, size: 26),
          const SizedBox(height: 8),
          Text(number, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
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
