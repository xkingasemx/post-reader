import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/post_model.dart';

class PostFeed {
  const PostFeed(this.posts, {required this.fromCache});

  final List<Post> posts;
  final bool fromCache;
}

class NoCachedPosts implements Exception {
  const NoCachedPosts();

  @override
  String toString() => 'No Internet and No Cached Data';
}

class PostService {
  PostService(this._box, {this.fetch = http.get});

  static final apiUrl = Uri.https('jsonplaceholder.typicode.com', '/posts');
  final Box<Post> _box;
  final Future<http.Response> Function(Uri) fetch;
  Future<PostFeed>? _pending;

  PostFeed? get cachedFeed {
    if (_box.isEmpty) return null;
    final saved = _box.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return PostFeed(saved, fromCache: true);
  }

  // A refresh gesture and a button tap can arrive during the same request.
  Future<PostFeed> getPosts() => _pending ??= _load().whenComplete(() {
    _pending = null;
  });

  Future<PostFeed> _load() async {
    late final List<Post> posts;
    try {
      final response = await fetch(apiUrl).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', apiUrl);
      }
      final rows = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      posts = rows
          .map((row) => Post.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (error) {
      debugPrint('API unavailable: $error');
      final cached = cachedFeed;
      if (cached == null) throw const NoCachedPosts();
      debugPrint('Loaded from Hive offline: ${cached.posts.length}');
      return cached;
    }

    // Write the complete response before removing old IDs. A failed fetch
    // never clears the last good cache. Favorites live in a separate box.
    final byId = {for (final post in posts) post.id: post};
    await _box.putAll(byId);
    final removed = _box.keys.where((key) => !byId.containsKey(key)).toList();
    if (removed.isNotEmpty) await _box.deleteAll(removed);
    debugPrint('Loaded from API and cached to Hive: ${posts.length}');
    return PostFeed(posts, fromCache: false);
  }
}
