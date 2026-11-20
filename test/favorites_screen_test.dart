import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:post_reader/main.dart';
import 'package:post_reader/models/post_model.dart';
import 'package:post_reader/services/favorites_service.dart';
import 'package:post_reader/services/post_service.dart';

void main() {
  late Box<Post> posts;
  late FavoritesService favorites;
  final response = http.Response(
    '[{"userId":1,"id":1,"title":"First post","body":"A short preview."}]',
    200,
  );

  setUp(() async {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(PostAdapter());
    posts = await Hive.openBox<Post>('postsBox', bytes: Uint8List(0));
    favorites = FavoritesService(
      await Hive.openBox<Post>('favoritesBox', bytes: Uint8List(0)),
    );
  });
  tearDown(Hive.close);

  testWidgets('a star updates both screens and survives pull-to-refresh', (
    tester,
  ) async {
    var calls = 0;
    final service = PostService(
      posts,
      fetch: (_) async {
        calls++;
        return response;
      },
    );
    await tester.pumpWidget(
      PostReaderApp(posts: service, favorites: favorites),
    );
    await tester.pumpAndSettle();
    expect(find.text('All posts'), findsOneWidget);
    await tester.tap(find.byTooltip('Add post 1 to favorites'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove post 1 from favorites'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(favorites.isFavorite(1), isTrue);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('My favorites'), findsOneWidget);
    expect(find.text('First post'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove post 1 from favorites'));
    await tester.pumpAndSettle();
    expect(find.text('No favorites yet'), findsOneWidget);
    await tester.tap(find.text('Back to posts'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add post 1 to favorites'), findsOneWidget);
  });

  testWidgets('posts load after retrying the first download', (tester) async {
    var connected = false;
    final service = PostService(
      posts,
      fetch: (url) async {
        if (!connected) throw http.ClientException('Offline', url);
        return response;
      },
    );
    await tester.pumpWidget(
      PostReaderApp(posts: service, favorites: favorites),
    );
    await tester.pumpAndSettle();
    expect(find.text('Go online to load posts'), findsOneWidget);
    connected = true;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('First post'), findsOneWidget);
    expect(find.text('Up to date'), findsOneWidget);
  });
}
