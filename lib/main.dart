import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/post_model.dart';
import 'screens/posts_screen.dart';
import 'services/favorites_service.dart';
import 'services/post_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PostAdapter());
  final postsBox = await Hive.openBox<Post>('postsBox');
  final favoritesBox = await Hive.openBox<Post>('favoritesBox');

  runApp(
    PostsApp(
      posts: PostService(postsBox),
      favorites: FavoritesService(favoritesBox),
    ),
  );
}

class PostsApp extends StatelessWidget {
  const PostsApp({super.key, required this.posts, required this.favorites});

  final PostService posts;
  final FavoritesService favorites;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Offline Posts',
    debugShowCheckedModeBanner: false,
    theme: readerTheme(),
    home: PostsScreen(posts: posts, favorites: favorites),
  );
}
