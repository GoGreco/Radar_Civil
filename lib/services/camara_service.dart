import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'local_cache.dart';
class CamaraService {

  static const String baseUrl =
      "https://dadosabertos.camara.leg.br/api/v2";

  CamaraService({http.Client? client, LocalCache? cache})
      : _client = client ?? http.Client(),
        _cache = cache;

  final http.Client _client;
  LocalCache? _cache;

  static const _proposicoesTtl = Duration(minutes: 5);
  static const _catalogoTtl = Duration(hours: 24);

  Future<LocalCache> get _localCache async {
    if (_cache != null) {
      return _cache!;
    }

    final preferences = await SharedPreferences.getInstance();
    return _cache = SharedPreferencesCache(preferences);
  }

  Future<List<dynamic>> getProposicoes({
    String? tipo,
    String? ano,
    String? numero,
    String? deputado,
    String? partido,
    String? codTema,
    int pagina = 1,
    int itens = 20,
  }) async {
    final normalizedPage = pagina < 1 ? 1 : pagina;
    final normalizedItems = itens.clamp(1, 100);
    final query = <String, String>{
      'ordem': 'DESC',
      'ordenarPor': 'id',
      'pagina': '$normalizedPage',
      'itens': '$normalizedItems',
      if (tipo?.isNotEmpty == true) 'siglaTipo': tipo!,
      if (ano?.isNotEmpty == true) 'ano': ano!,
      if (numero?.isNotEmpty == true) 'numero': numero!,
      if (deputado?.isNotEmpty == true) 'autor': deputado!,
      if (partido?.isNotEmpty == true) 'siglaPartidoAutor': partido!,
      if (codTema?.isNotEmpty == true) 'codTema': codTema!,
    };
    final cacheKey = 'proposicoes:${_canonicalQuery(query)}';
    final cache = await _localCache;
    final cached = await _readFreshList(cache, cacheKey, _proposicoesTtl);
    if (cached != null) {
      return cached;
    }

    final uri = Uri.parse('$baseUrl/proposicoes').replace(queryParameters: query);

    try {
      final response = await _client
          .get(uri, headers: {'accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Erro ao carregar proposições (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body);
      final dados = decoded['dados'];
      if (dados is! List) {
        throw const FormatException('Resposta de proposições inválida');
      }

      final result = List<dynamic>.from(dados);
      await _writeJson(cache, cacheKey, result);
      return result;
    } catch (error) {
      final stale = await _readCachedList(cache, cacheKey);
      if (stale != null) {
        return stale;
      }
      throw Exception('Não foi possível carregar proposições: $error');
    }
  }

  Future<List<String>> getTiposProposicao() async {
    const fallback = [
      'PEC',
      'PL',
      'PLP',
      'MPV',
    ];
    return _getCachedCatalog('tipos', fallback);
  }

  Future<List<String>> getAnos() async {
    final anoAtual = DateTime.now().year;
    final fallback = List.generate(
      10,
      (index) => (anoAtual - index).toString(),
    );
    return _getCachedCatalog('anos', fallback);
  }

  Future<List<Map<String, String>>> getTemas() async {
    const fallback = [
      {'cod': '34', 'nome': 'Administração Pública'},
      {'cod': '35', 'nome': 'Arte, Cultura e Religião'},
      {'cod': '37', 'nome': 'Comunicações'},
      {'cod': '39', 'nome': 'Esporte e Lazer'},
      {'cod': '40', 'nome': 'Economia'},
      {'cod': '41', 'nome': 'Cidades e Desenvolvimento Urbano'},
      {'cod': '42', 'nome': 'Direito Civil e Processual Civil'},
      {'cod': '43', 'nome': 'Direito Penal e Processual Penal'},
      {'cod': '44', 'nome': 'Direitos Humanos e Minorias'},
      {'cod': '46', 'nome': 'Educação'},
      {'cod': '48', 'nome': 'Meio Ambiente e Desenvolvimento Sustentável'},
      {'cod': '51', 'nome': 'Estrutura Fundiária'},
      {'cod': '52', 'nome': 'Previdência e Assistência Social'},
      {'cod': '53', 'nome': 'Processo Legislativo e Atuação Parlamentar'},
      {'cod': '54', 'nome': 'Energia, Recursos Hídricos e Minerais'},
      {'cod': '55', 'nome': 'Relações Internacionais e Comércio Exterior'},
      {'cod': '56', 'nome': 'Saúde'},
      {'cod': '57', 'nome': 'Defesa e Segurança'},
      {'cod': '58', 'nome': 'Trabalho e Emprego'},
      {'cod': '60', 'nome': 'Turismo'},
      {'cod': '61', 'nome': 'Viação, Transporte e Mobilidade'},
      {'cod': '62', 'nome': 'Ciência, Tecnologia e Inovação'},
      {'cod': '64', 'nome': 'Agricultura, Pecuária, Pesca e Extrativismo'},
      {'cod': '66', 'nome': 'Indústria, Comércio e Serviços'},
      {'cod': '67', 'nome': 'Direito e Defesa do Consumidor'},
      {'cod': '68', 'nome': 'Direito Constitucional'},
      {'cod': '70', 'nome': 'Finanças Públicas e Orçamento'},
      {'cod': '72', 'nome': 'Homenagens e Datas Comemorativas'},
      {'cod': '74', 'nome': 'Política, Partidos e Eleições'},
      {'cod': '76', 'nome': 'Direito e Justiça'},
      {'cod': '85', 'nome': 'Ciências Exatas e da Terra'},
      {'cod': '86', 'nome': 'Ciências Sociais e Humanas'},
    ];
    final cache = await _localCache;
    final cached = await _readFreshMapList(cache, 'catalogo:temas', _catalogoTtl);
    if (cached != null) {
      return cached;
    }

    await _writeJson(cache, 'catalogo:temas', fallback);
    return fallback;
  }

  Future<List<String>> _getCachedCatalog(
    String name,
    List<String> fallback,
  ) async {
    final cache = await _localCache;
    final key = 'catalogo:$name';
    final cached = await _readFreshStringList(cache, key, _catalogoTtl);
    if (cached != null) {
      return cached;
    }

    await _writeJson(cache, key, fallback);
    return fallback;
  }

  String _canonicalQuery(Map<String, String> query) {
    final entries = query.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => '${entry.key}=${entry.value}').join('&');
  }

  Future<void> _writeJson(
    LocalCache cache,
    String key,
    Object value,
  ) async {
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

  Future<List<dynamic>?> _readFreshList(
    LocalCache cache,
    String key,
    Duration ttl,
  ) async {
    final envelope = await _readCached(cache, key);
    if (!_isFresh(envelope, ttl)) {
      return null;
    }
    final data = envelope['data'];
    return data is List ? List<dynamic>.from(data) : null;
  }

  Future<List<String>?> _readFreshStringList(
    LocalCache cache,
    String key,
    Duration ttl,
  ) async {
    final data = await _readFreshList(cache, key, ttl);
    return data?.map((value) => value.toString()).toList();
  }

  Future<List<Map<String, String>>?> _readFreshMapList(
    LocalCache cache,
    String key,
    Duration ttl,
  ) async {
    final data = await _readFreshList(cache, key, ttl);
    if (data == null) {
      return null;
    }
    return data
        .whereType<Map>()
        .map((item) => item.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ))
        .toList();
  }

  bool _isFresh(dynamic envelope, Duration ttl) {
    if (envelope is! Map || envelope['savedAt'] is! String) {
      return false;
    }
    final savedAt = DateTime.tryParse(envelope['savedAt'] as String);
    return savedAt != null && DateTime.now().difference(savedAt) <= ttl;
  }
}