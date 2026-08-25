import 'dart:convert';
import 'package:http/http.dart' as http;

class CamaraService {
  static const String baseUrl =
      "https://dadosabertos.camara.leg.br/api/v2";

  Future<List<dynamic>> getProposicoes({
    String? tipo,
    String? ano,
    String? deputado,
    String? partido,
    String? codTema,
  }) async {
    String url = "$baseUrl/proposicoes?ordem=DESC&ordenarPor=id";

    if (tipo != null && tipo.isNotEmpty) {
      url += "&siglaTipo=$tipo";
    }

    if (ano != null && ano.isNotEmpty) {
      url += "&ano=$ano";
    }

    if (deputado != null && deputado.isNotEmpty) {
      url += "&autor=${Uri.encodeQueryComponent(deputado)}";
    }

    if (partido != null && partido.isNotEmpty) {
      url += "&siglaPartidoAutor=${Uri.encodeQueryComponent(partido)}";
    }

    if (codTema != null && codTema.isNotEmpty) {
      url += "&codTema=$codTema";
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['dados'];
    }

    throw Exception("Erro ao carregar proposições");
  }

  Future<List<String>> getTiposProposicao() async {
    return [
      'PEC',
      'PL',
      'PLP',
      'MPV',
    ];
  }

  Future<List<String>> getAnos() async {
    final anoAtual = DateTime.now().year;

    return List.generate(
      10,
      (index) => (anoAtual - index).toString(),
    );
  }

  Future<List<Map<String, String>>> getTemas() async {
    return const [
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
  }
}