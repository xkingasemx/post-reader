import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:offline_posts/models/post_model.dart';
import 'package:offline_posts/services/favorites_service.dart';
import 'package:offline_posts/services/post_service.dart';

void main() {
  late Directory folder;
  late Box<Post> postsBox;
  late Box<Post> favoritesBox;
  late FavoritesService favorites;

  http.Response feed(List<int> ids) => http.Response(
    jsonEncode([
      for (final id in ids)
        {'userId': 1, 'id': id, 'title': 'Post $id', 'body': 'Body $id'},
    ]),
    200,
  );

  Future<http.Response> offline(Uri url) async =>
      throw http.ClientException('Network unavailable', url);

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('offline_posts_');
    Hive.init(folder.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PostAdapter());
    postsBox = await Hive.openBox<Post>('postsBox');
    favoritesBox = await Hive.openBox<Post>('favoritesBox');
    favorites = FavoritesService(favoritesBox);
  });

  tearDown(() async {
    await Hive.close();
    await folder.delete(recursive: true);
  });

  test(
    'stores the feed and a detached copy of each favorite by post ID',
    () async {
      final service = PostService(postsBox, fetch: (_) async => feed([1, 2]));
      final result = await service.getPosts();
      expect(result.fromCache, isFalse);
      expect(postsBox.length, 2);
      final post = result.posts.first;
      await favorites.toggleFavorite(post);
      final copy = favoritesBox.get(1)!;
      expect(identical(copy, post), isFalse);
      expect(
        [copy.id, copy.title, copy.body, copy.userId],
        [1, 'Post 1', 'Body 1', 1],
      );
      expect(favorites.isFavorite(1), isTrue);
      await favorites.toggleFavorite(post);
      expect(favorites.getFavorites(), isEmpty);
      expect(postsBox.length, 2);
    },
  );

  test(
    'refresh replaces stale posts and keeps previously saved favorites',
    () async {
      var ids = [1, 2];
      final service = PostService(postsBox, fetch: (_) async => feed(ids));
      final initial = await service.getPosts();
      await favorites.toggleFavorite(initial.posts.first);
      ids = [2, 3];
      await service.getPosts();
      expect(postsBox.keys.toSet(), {2, 3});
      expect(favorites.getFavorites().single.id, 1);
    },
  );

  test('reopens both boxes from disk with the network unavailable', () async {
    final online = PostService(postsBox, fetch: (_) async => feed([1, 2, 3]));
    final initial = await online.getPosts();
    await favorites.toggleFavorite(initial.posts.first);
    await favorites.toggleFavorite(initial.posts.last);
    await Hive.close();
    Hive.init(folder.path);
    final reopenedPosts = await Hive.openBox<Post>('postsBox');
    final reopenedFavorites = FavoritesService(
      await Hive.openBox<Post>('favoritesBox'),
    );
    final saved = await PostService(reopenedPosts, fetch: offline).getPosts();
    expect(saved.fromCache, isTrue);
    expect(saved.posts.map((p) => p.id), [1, 2, 3]);
    expect(reopenedFavorites.getFavorites().map((p) => p.id), [1, 3]);
    await reopenedFavorites.toggleFavorite(saved.posts.first);
    expect(reopenedFavorites.getFavorites().single.id, 3);
  });

  test('first offline launch has a recoverable empty-cache error', () async {
    final service = PostService(postsBox, fetch: offline);
    await expectLater(service.getPosts(), throwsA(isA<NoCachedPosts>()));
    expect(favorites.getFavorites(), isEmpty);
  });

  test(
    'bad HTTP responses and incomplete JSON preserve the previous cache',
    () async {
      var response = feed([4]);
      final service = PostService(postsBox, fetch: (_) async => response);
      await service.getPosts();
      for (final failed in [
        http.Response('Unavailable', 503),
        http.Response('[{}]', 200),
      ]) {
        response = failed;
        final old = await service.getPosts();
        expect(old.fromCache, isTrue);
        expect(old.posts.single.id, 4);
      }
    },
  );

  test(
    'simultaneous refreshes share one request and one cache update',
    () async {
      final pending = Completer<http.Response>();
      var count = 0;
      final service = PostService(
        postsBox,
        fetch: (_) {
          count++;
          return pending.future;
        },
      );
      final first = service.getPosts();
      final second = service.getPosts();
      pending.complete(feed([8]));
      await Future.wait([first, second]);
      expect(count, 1);
      expect(postsBox.values.single.id, 8);
    },
  );
}
