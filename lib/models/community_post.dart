import 'dart:convert';

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final List<String> imageUrls;
  final String? flowerTag;
  final String? location;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    this.imageUrls = const [],
    this.flowerTag,
    this.location,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      content: json['content'] as String,
      imageUrls: _parseImageUrls(json['image_url']),
      flowerTag: json['flower_tag'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  static List<String> _parseImageUrls(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.cast<String>();
    if (raw is String) {
      if (raw.isEmpty) return [];
      if (raw.startsWith('[')) {
        try {
          return (jsonDecode(raw) as List).cast<String>();
        } catch (_) {}
      }
      return [raw];
    }
    return [];
  }

  CommunityPost copyWith({
    bool? isLiked,
    int? likeCount,
    int? commentCount,
  }) {
    return CommunityPost(
      id: id,
      userId: userId,
      userName: userName,
      content: content,
      imageUrls: imageUrls,
      flowerTag: flowerTag,
      location: location,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
