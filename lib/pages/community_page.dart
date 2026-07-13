import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _service = CommunityService();
  List<CommunityPost> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    final posts = await _service.fetchPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _loading = false;
      });
    }
  }

  Future<void> _onToggleLike(CommunityPost post) async {
    final updated = await _service.toggleLike(post);
    if (updated != null && mounted) {
      setState(() {
        final idx = _posts.indexWhere((p) => p.id == updated.id);
        if (idx >= 0) _posts[idx] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('花友社区'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: '发布动态',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostPage()),
              );
              if (result == true) _loadPosts();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: appGreen))
          : _posts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  color: appGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) => _buildPostCard(_posts[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌸', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('还没有人分享花事', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('成为第一个分享的人吧～', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostPage()),
              );
              if (result == true) _loadPosts();
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('发布第一条动态'),
            style: ElevatedButton.styleFrom(
              backgroundColor: appGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        );
        _loadPosts();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrls.isNotEmpty) _buildImagePreview(post.imageUrls),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: appLightPink,
                        child: Text('🌸', style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _formatTime(post.createdAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      if (post.flowerTag != null && post.flowerTag!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: appLightPink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🌸 ${post.flowerTag}',
                            style: const TextStyle(fontSize: 11, color: appPink),
                          ),
                        ),
                    ],
                  ),
                  if (post.content.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(post.content, style: const TextStyle(fontSize: 15, height: 1.5)),
                  ],
                  if (post.location != null && post.location!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: appPink),
                        const SizedBox(width: 3),
                        Text(post.location!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _onToggleLike(post),
                        child: Row(
                          children: [
                            Icon(
                              post.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: post.isLiked ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text('${post.likeCount}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                      const Spacer(),
                      if (post.userId == AuthService().currentUser?.id)
                        GestureDetector(
                          onTap: () => _confirmDelete(post),
                          child: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(List<String> urls) {
    final count = urls.length;
    return GestureDetector(
      onTap: () => _showImageViewer(urls, 0),
      child: count == 1
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildNetworkImage(urls[0]),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count <= 4 ? 2 : 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: count > 9 ? 9 : count,
              itemBuilder: (ctx, i) {
                final showMore = i == 8 && count > 9;
                return GestureDetector(
                  onTap: () => _showImageViewer(urls, i),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildNetworkImage(urls[i]),
                      if (showMore)
                        Container(
                          color: Colors.black45,
                          alignment: Alignment.center,
                          child: Text('+${count - 9}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }

  void _showImageViewer(List<String> urls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewerPage(urls: urls, initialIndex: initialIndex),
      ),
    );
  }

  void _confirmDelete(CommunityPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除动态'),
        content: const Text('确定要删除这条动态吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await _service.deletePost(post.id);
              if (ok && mounted) _loadPosts();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}/${dt.day}';
  }
}

class _ImageViewerPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const _ImageViewerPage({required this.urls, this.initialIndex = 0});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.urls.length}'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -100 && _currentIndex < widget.urls.length - 1) {
            setState(() => _currentIndex++);
          } else if (details.primaryVelocity! > 100 && _currentIndex > 0) {
            setState(() => _currentIndex--);
          }
        },
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: Image.network(
              widget.urls[_currentIndex],
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('图片加载失败', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
