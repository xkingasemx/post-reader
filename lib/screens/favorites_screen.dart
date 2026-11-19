import 'package:flutter/material.dart';

import '../services/favorites_service.dart';
import '../widgets/list_layout.dart';
import '../widgets/post_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.favorites});
  final FavoritesService favorites;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favorites')),
    body: ReadingColumn(
      child: ValueListenableBuilder(
        valueListenable: favorites.changes,
        builder: (context, box, child) {
          final posts = favorites.getFavorites();
          if (posts.isEmpty) {
            return ListMessage(
              icon: Icons.star_border,
              title: 'No favorites yet',
              body: 'Tap the star beside a post to save it here.',
              action: 'Browse posts',
              onPressed: () => Navigator.of(context).pop(),
            );
          }
          return Column(
            children: [
              ListHeading(
                count: posts.length,
                status: 'On this device',
                icon: Icons.offline_pin_outlined,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: posts.length,
                  itemBuilder: (_, i) => PostCard(
                    key: ValueKey(posts[i].id),
                    post: posts[i],
                    favorites: favorites,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
