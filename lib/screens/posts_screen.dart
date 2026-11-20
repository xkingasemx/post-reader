import 'package:flutter/material.dart';

import '../services/favorites_service.dart';
import '../services/post_service.dart';
import '../widgets/list_layout.dart';
import '../widgets/post_card.dart';
import 'favorites_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key, required this.posts, required this.favorites});
  final PostService posts;
  final FavoritesService favorites;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<PostFeed> _feed;
  late final PostFeed? _initialCache;

  @override
  void initState() {
    super.initState();
    _initialCache = widget.posts.cachedFeed;
    _feed = widget.posts.getPosts();
  }

  Future<void> _refresh() async {
    final next = widget.posts.getPosts();
    setState(() {
      _feed = next;
    });
    // FutureBuilder shows the error and the retry button.
    try {
      await next;
    } on Exception {
      return;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('All posts'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF7D9A8C)),
            ),
            icon: const Icon(Icons.star_outline, size: 19),
            label: const Text('Favorites'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FavoritesScreen(favorites: widget.favorites),
              ),
            ),
          ),
        ),
      ],
    ),
    body: ReadingColumn(
      child: FutureBuilder<PostFeed>(
        future: _feed,
        initialData: _initialCache,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final feed = snapshot.data;
          if (loading && feed == null) {
            return const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading posts'),
            );
          }
          if (snapshot.hasError) {
            final noCache = snapshot.error is NoCachedPosts;
            return ListMessage(
              icon: noCache ? Icons.cloud_off_outlined : Icons.error_outline,
              title: noCache ? 'Go online to load posts' : "Posts didn't load",
              body: noCache
                  ? 'Connect once to save posts for offline reading.'
                  : 'Check your connection and try again.',
              action: 'Try again',
              onPressed: _refresh,
            );
          }
          if (feed == null || feed.posts.isEmpty) {
            return ListMessage(
              icon: Icons.article_outlined,
              title: 'No posts yet',
              body: 'Refresh to check for new posts.',
              action: 'Refresh',
              onPressed: _refresh,
            );
          }
          return Column(
            children: [
              ListHeading(
                count: feed.posts.length,
                status: feed.fromCache ? 'Saved copy' : 'Up to date',
                icon: feed.fromCache
                    ? Icons.offline_pin_outlined
                    : Icons.cloud_done_outlined,
                onRefresh: _refresh,
              ),
              SizedBox(
                height: 2,
                child: loading ? const LinearProgressIndicator() : null,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ValueListenableBuilder(
                    valueListenable: widget.favorites.changes,
                    builder: (context, box, child) => ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                      itemCount: feed.posts.length,
                      itemBuilder: (_, i) => PostCard(
                        key: ValueKey(feed.posts[i].id),
                        post: feed.posts[i],
                        favorites: widget.favorites,
                      ),
                    ),
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
