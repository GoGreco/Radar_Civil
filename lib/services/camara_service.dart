import 'dart:convert';
import 'package:http/http.dart' as http;

class CamaraService {
  static const String baseUrl =
      "https://dadosabertos.camara.leg.br/api/v2";

  Future<List<dynamic>> getProposicoes({
    String? tipo,
    String? ano,
  }) async {
    String url = "$baseUrl/proposicoes?ordem=DESC&ordenarPor=id";

    if (tipo != null && tipo.isNotEmpty) {
      url += "&siglaTipo=$tipo";
    }

    if (ano != null && ano.isNotEmpty) {
      url += "&ano=$ano";
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
}