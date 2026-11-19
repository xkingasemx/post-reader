import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post_model.dart';

class FavoritesService {
  FavoritesService(this._box);

  final Box<Post> _box;
  late final ValueListenable<Box<Post>> changes = _box.listenable();

  bool isFavorite(int id) => _box.containsKey(id);

  List<Post> getFavorites() =>
      _box.values.toList()..sort((a, b) => a.id.compareTo(b.id));

  Future<void> toggleFavorite(Post post) {
    if (isFavorite(post.id)) {
      return _box.delete(post.id);
    }
    return _box.put(post.id, post.copy());
  }
}
