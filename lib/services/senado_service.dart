import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/materia_senado.dart';
import 'local_cache.dart';

/// Consome a API de Dados Abertos do Senado Federal
/// (https://legis.senado.leg.br/dadosabertos).
class SenadoService {
  static const String baseUrl = 'https://legis.senado.leg.br/dadosabertos';

  SenadoService({http.Client? client, LocalCache? cache})
      : _client = client ?? http.Client(),
        _cache = cache;

  final http.Client _client;
  LocalCache? _cache;

  static const _materiasTtl = Duration(minutes: 5);

  Future<LocalCache> get _localCache async {
    if (_cache != null) {
      return _cache!;
    }

    final preferences = await SharedPreferences.getInstance();
    return _cache = SharedPreferencesCache(preferences);
  }

  /// Busca as matérias apresentadas entre [inicio] e [fim] (ambos inclusos),
  /// ordenadas da mais recente para a mais antiga.
  ///
  /// O endpoint `/processo` não tem paginação própria, então quem chama
  /// controla o volume de dados alargando ou estreitando essa janela.
  Future<List<MateriaSenado>> getMaterias({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final query = {
      'dataInicioApresentacao': _formatarData(inicio),
      'dataFimApresentacao': _formatarData(fim),
    };
    final cacheKey =
        'materias:${query['dataInicioApresentacao']}:${query['dataFimApresentacao']}';
    final cache = await _localCache;

    final cached = await _readFreshList(cache, cacheKey);
    if (cached != null) {
      return _ordenar(cached.map(_paraMateria).toList());
    }

    final uri = Uri.parse('$baseUrl/processo').replace(queryParameters: query);

    try {
      final response = await _client
          .get(uri, headers: {'accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Erro ao carregar matérias do Senado (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('Resposta de matérias do Senado inválida');
      }

      final result = List<dynamic>.from(decoded);
      await _writeJson(cache, cacheKey, result);
      return _ordenar(result.map(_paraMateria).toList());
    } catch (error) {
      final stale = await _readCachedList(cache, cacheKey);
      if (stale != null) {
        return _ordenar(stale.map(_paraMateria).toList());
      }
      throw Exception('Não foi possível carregar matérias do Senado: $error');
    }
  }

  MateriaSenado _paraMateria(dynamic item) =>
      MateriaSenado.fromApi(item as Map<String, dynamic>);

  List<MateriaSenado> _ordenar(List<MateriaSenado> materias) {
    materias.sort((a, b) {
      final porData = b.dataApresentacao.compareTo(a.dataApresentacao);
      if (porData != 0) return porData;
      return b.id.compareTo(a.id);
    });
    return materias;
  }

  String _formatarData(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  Future<void> _writeJson(LocalCache cache, String key, Object value) async {
    await cache.write(
      key,
      jsonEncode({'savedAt': DateTime.now().toIso8601String(), 'data': value}),
    );
  }

  Future<dynamic> _readCached(LocalCache cache, String key) async {
    final raw = await cache.read(key);
    if (raw == null) {
      return null;
    }

    try {
      return jsonDecode(raw);
    } catch (_) {
      await cache.remove(key);
      return null;
    }
  }

  Future<List<dynamic>?> _readCachedList(LocalCache cache, String key) async {
    final envelope = await _readCached(cache, key);
    final data = envelope is Map ? envelope['data'] : null;
    return data is List ? List<dynamic>.from(data) : null;
  }

  Future<List<dynamic>?> _readFreshList(LocalCache cache, String key) async {
    final envelope = await _readCached(cache, key);
    if (!_isFresh(envelope)) {
      return null;
    }
    final data = envelope['data'];
    return data is List ? List<dynamic>.from(data) : null;
  }

  bool _isFresh(dynamic envelope) {
    if (envelope is! Map || envelope['savedAt'] is! String) {
      return false;
    }
    final savedAt = DateTime.tryParse(envelope['savedAt'] as String);
    return savedAt != null &&
        DateTime.now().difference(savedAt) <= _materiasTtl;
  }
}
