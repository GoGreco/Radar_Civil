import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import 'local_cache.dart';

class SavedPostsService {
  SavedPostsService({LocalCache? cache}) : _cache = cache;

  static const _key = 'posts_salvos';

  LocalCache? _cache;

  Future<LocalCache> get _localCache async {
    if (_cache != null) {
      return _cache!;
    }

    final preferences = await SharedPreferences.getInstance();
    return _cache = SharedPreferencesCache(preferences);
  }

  Future<List<Post>> listar() async {
    final cache = await _localCache;
    final raw = await cache.read(_key);

    if (raw == null) {
      return [];
    }

    try {
      final lista = jsonDecode(raw) as List;
      return lista
          .whereType<Map>()
          .map((item) => Post.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> estaSalvo(int id) async {
    final posts = await listar();
    return posts.any((post) => post.id == id);
  }

  /// Salva ou remove [post] da lista de salvos. Retorna o novo estado
  /// (true = ficou salvo, false = foi removido).
  Future<bool> alternar(Post post) async {
    final posts = await listar();
    final jaSalvo = posts.any((p) => p.id == post.id);

    if (jaSalvo) {
      posts.removeWhere((p) => p.id == post.id);
    } else {
      posts.insert(0, post);
    }

    await _salvarLista(posts);
    return !jaSalvo;
  }

  Future<void> remover(int id) async {
    final posts = await listar();
    posts.removeWhere((post) => post.id == id);
    await _salvarLista(posts);
  }

  Future<void> _salvarLista(List<Post> posts) async {
    final cache = await _localCache;
    await cache.write(
      _key,
      jsonEncode(posts.map((post) => post.toJson()).toList()),
    );
  }
}
