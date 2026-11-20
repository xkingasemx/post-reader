import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/favorites_service.dart';
import '../theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.favorites});

  final Post post;
  final FavoritesService favorites;

  @override
  Widget build(BuildContext context) {
    final saved = favorites.isFavorite(post.id);
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 6, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFE4EDE6),
              foregroundColor: forest,
              child: Text(
                '${post.id}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.22,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    post.body.replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: saved
                  ? 'Remove post ${post.id} from favorites'
                  : 'Add post ${post.id} to favorites',
              icon: Icon(saved ? Icons.star : Icons.star_border),
              color: saved ? gold : muted,
              onPressed: () async {
                try {
                  await favorites.toggleFavorite(post);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Couldn't update this favorite. Try again.",
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
