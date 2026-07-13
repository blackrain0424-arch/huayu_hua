import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';
import '../widgets/common_widgets.dart';

class PostDetailPage extends StatefulWidget {
  final CommunityPost post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _service = CommunityService();
  final _commentController = TextEditingController();
  late CommunityPost _post;
  List<PostComment> _comments = [];
  bool _loadingComments = true;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadComments();
  }

  Future<void> _loadComments() async {
    final comments = await _service.fetchComments(_post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final updated = await _service.toggleLike(_post);
    if (updated != null && mounted) {
      setState(() => _post = updated);
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final comment = await _service.addComment(_post.id, content);
    if (comment != null && mounted) {
      _commentController.clear();
      setState(() {
        _comments.add(comment);
        _post = _post.copyWith(commentCount: _post.commentCount + 1);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWarmBg,
      appBar: AppBar(
        title: const Text('动态详情'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPostContent(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('评论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('${_post.commentCount}', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 10),
                if (_loadingComments)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: appGreen),
                  ))
                else if (_comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text('还没有评论，来说点什么吧～', style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  )
                else
                  ..._comments.map((c) => _buildCommentItem(c)),
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_post.imageUrls.isNotEmpty) _buildImagePreview(_post.imageUrls),
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
                      child: const Text('🌸', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_post.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(
                            _formatTime(_post.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    if (_post.flowerTag != null && _post.flowerTag!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: appLightPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('🌸 ${_post.flowerTag}', style: const TextStyle(fontSize: 11, color: appPink)),
                      ),
                  ],
                ),
                if (_post.content.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(_post.content, style: const TextStyle(fontSize: 16, height: 1.6)),
                ],
                if (_post.location != null && _post.location!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: appPink),
                      const SizedBox(width: 3),
                      Text(_post.location!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _post.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: _post.isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('${_post.likeCount}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${_post.commentCount}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(PostComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: appLightPink,
            child: const Text('🌸', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(_formatTime(comment.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: '写下你的评论...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: appBorder)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submitComment,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: appGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
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
        builder: (_) => _DetailImageViewer(urls: urls, initialIndex: initialIndex),
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

class _DetailImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const _DetailImageViewer({required this.urls, this.initialIndex = 0});

  @override
  State<_DetailImageViewer> createState() => _DetailImageViewerState();
}

class _DetailImageViewerState extends State<_DetailImageViewer> {
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
