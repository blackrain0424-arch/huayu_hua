import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_post.dart';
import 'supabase_service.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._();
  factory CommunityService() => _instance;
  CommunityService._();

  SupabaseClient get _sb => SupabaseService().client;

  List<CommunityPost> _cachedPosts = [];
  List<CommunityPost> get cachedPosts => List.unmodifiable(_cachedPosts);

  String get _displayName => StorageService().getProfileName();

  // ========== Posts ==========

  Future<List<CommunityPost>> fetchPosts({int limit = 20, int offset = 0}) async {
    try {
      final userId = AuthService().currentUser?.id;
      final res = await _sb
          .from('posts')
          .select('*, likes!left(post_id, user_id)')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final posts = (res as List<dynamic>).map((item) {
        final map = item as Map<String, dynamic>;
        final likes = (map['likes'] as List?) ?? [];
        final isLiked = likes.any((l) => l['user_id'] == userId);
        final post = CommunityPost.fromJson(map);
        // Use actual likes count from join, not stale column value
        return post.copyWith(isLiked: isLiked, likeCount: likes.length);
      }).toList();

      if (offset == 0) _cachedPosts = posts;
      return posts;
    } catch (e) {
      return List.from(_cachedPosts);
    }
  }

  Future<CommunityPost> createPost({
    required String content,
    List<String> imageUrls = const [],
    String? flowerTag,
    String? location,
  }) async {
    final user = AuthService().currentUser;
    if (user == null) throw Exception('请先登录');

    final res = await _sb.from('posts').insert({
      'user_id': user.id,
      'user_name': _displayName,
      'content': content,
      'image_url': imageUrls.isNotEmpty ? jsonEncode(imageUrls) : null,
      'flower_tag': flowerTag,
      'location': location,
      'like_count': 0,
      'comment_count': 0,
    }).select().single();

    final post = CommunityPost.fromJson(res);
    _cachedPosts.insert(0, post);
    return post;
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _sb.from('posts').delete().eq('id', postId);
      _cachedPosts.removeWhere((p) => p.id == postId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== Likes ==========

  Future<CommunityPost?> toggleLike(CommunityPost post) async {
    try {
      final userId = AuthService().currentUser?.id;
      if (userId == null) return null;

      if (post.isLiked) {
        await _sb.from('likes').delete().eq('post_id', post.id).eq('user_id', userId);
        await _sb.from('posts').update({
          'like_count': post.likeCount - 1,
        }).eq('id', post.id);
        final updated = post.copyWith(isLiked: false, likeCount: post.likeCount - 1);
        _updateCachedPost(updated);
        return updated;
      } else {
        await _sb.from('likes').insert({
          'post_id': post.id,
          'user_id': userId,
        });
        await _sb.from('posts').update({
          'like_count': post.likeCount + 1,
        }).eq('id', post.id);
        final updated = post.copyWith(isLiked: true, likeCount: post.likeCount + 1);
        _updateCachedPost(updated);
        return updated;
      }
    } catch (e) {
      return null;
    }
  }

  // ========== Comments ==========

  Future<List<PostComment>> fetchComments(String postId) async {
    try {
      final res = await _sb
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return (res as List)
          .map((item) => PostComment.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<PostComment?> addComment(String postId, String content) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return null;

      final res = await _sb.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'user_name': _displayName,
        'content': content,
      }).select().single();

      final idx = _cachedPosts.indexWhere((p) => p.id == postId);
      final newCount = idx >= 0 ? _cachedPosts[idx].commentCount + 1 : 1;

      await _sb.from('posts').update({
        'comment_count': newCount,
      }).eq('id', postId);

      if (idx >= 0) {
        _cachedPosts[idx] = _cachedPosts[idx].copyWith(commentCount: newCount);
      }

      return PostComment.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  void _updateCachedPost(CommunityPost updated) {
    final idx = _cachedPosts.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) _cachedPosts[idx] = updated;
  }
}
