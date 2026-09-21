import 'dart:convert';
import 'package:http/http.dart' as http;

class Autor {
  final String nome;
  final String siglaPartido;
  final String? fotoUrl;

  Autor({
    required this.nome,
    required this.siglaPartido,
    this.fotoUrl,
  });
}

class AutoresInfo {
  final List<Autor> principais;
  final int total;

  AutoresInfo({required this.principais, required this.total});
}

class Post {
  static final Map<int, Future<AutoresInfo>> _autoresCache = {};
  static final Map<int, Future<String?>> _inteiroTeorCache = {};

  final int id;
  final String author;
  final String title;
  final String description;
  final String date;
  final String tipo;
  final String ano;
  final String? link;
  final String? authorImageUrl;
  final String? urlInteiroTeor;

  Post({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.date,
    required this.tipo,
    required this.ano,
    this.link,
    this.authorImageUrl,
    this.urlInteiroTeor,
  });

  factory Post.fromApi(Map<String, dynamic> json) {
    final tipo =
        (json['siglaTipo'] ?? json['descricaoTipo'] ?? '').toString();

    final numero = (json['numero'] ?? '').toString();

    final ano = (json['ano'] ?? '').toString();

    return Post(
      id: json['id'] ?? 0,
      author: 'Câmara dos Deputados',
      title: '$tipo $numero/$ano',
      description: json['ementa'] ?? 'Sem descrição',
      date: json['dataApresentacao'] ?? '',
      tipo: tipo,
      ano: ano,
      link: json['uri'],
      authorImageUrl: json['urlFotoAutor'],
      urlInteiroTeor: json['urlInteiroTeor'],
    );
  }

  static Future<String?> buscarUrlInteiroTeor(int proposicaoId) async {
    final cached = _inteiroTeorCache[proposicaoId];
    if (cached != null) {
      return cached;
    }

    final request = _buscarUrlInteiroTeor(proposicaoId);
    _inteiroTeorCache[proposicaoId] = request;
    return request;
  }

  static Future<String?> _buscarUrlInteiroTeor(int proposicaoId) async {
    try {
      final resp = await http.get(Uri.parse(
        'https://dadosabertos.camara.leg.br/api/v2/proposicoes/$proposicaoId',
      )).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body)['dados']['urlInteiroTeor'] as String?;
      }
    } catch (_) {}
    return null;
  }

  static Future<AutoresInfo> buscarAutoresPrincipais(int proposicaoId) async {
    final cached = _autoresCache[proposicaoId];
    if (cached != null) {
      return cached;
    }

    final request = _buscarAutoresPrincipais(proposicaoId);
    _autoresCache[proposicaoId] = request;
    return request;
  }

  static Future<AutoresInfo> _buscarAutoresPrincipais(int proposicaoId) async {
    final autoresResp = await http.get(Uri.parse(
      'https://dadosabertos.camara.leg.br/api/v2/proposicoes/$proposicaoId/autores',
    )).timeout(const Duration(seconds: 15));

    if (autoresResp.statusCode != 200) {
      return AutoresInfo(principais: [], total: 0);
    }

    final List autoresJson =
        (jsonDecode(autoresResp.body)['dados'] as List?) ?? [];

    final ordenados = List.of(autoresJson)
      ..sort((a, b) => ((a['ordemAssinatura'] ?? 999) as int)
          .compareTo((b['ordemAssinatura'] ?? 999) as int));

    final principais = <Autor>[];

    for (final autor in ordenados.take(3)) {
      final uri = (autor['uri'] ?? '').toString();
      final deputadoId = uri.split('/').last;

      try {
        final depResp = await http.get(Uri.parse(
          'https://dadosabertos.camara.leg.br/api/v2/deputados/$deputadoId',
        )).timeout(const Duration(seconds: 15));

        if (depResp.statusCode == 200) {
          final status = jsonDecode(depResp.body)['dados']['ultimoStatus'];
          principais.add(Autor(
            nome: status['nome'] ?? autor['nome'] ?? 'Autor desconhecido',
            siglaPartido: status['siglaPartido'] ?? '',
            fotoUrl: status['urlFoto'],
          ));
        } else {
          principais.add(Autor(
            nome: autor['nome'] ?? 'Autor desconhecido',
            siglaPartido: '',
          ));
        }
      } catch (_) {
        principais.add(Autor(
          nome: autor['nome'] ?? 'Autor desconhecido',
          siglaPartido: '',
        ));
      }
    }

    return AutoresInfo(principais: principais, total: autoresJson.length);
  }
}