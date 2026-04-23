import 'dart:convert';
import 'package:http/http.dart' as http;

class CamaraService {
  final String baseUrl = "https://dadosabertos.camara.leg.br/api/v2";

  Future<List> getDeputados() async {
    final response = await http.get(Uri.parse("$baseUrl/deputados"));

    if (response.statusCode == 200) {
      return json.decode(response.body)['dados'];
    } else {
      throw Exception('Erro ao carregar deputados');
    }
  }

  Future<List> getProposicoes() async {
    final response = await http.get(Uri.parse("$baseUrl/proposicoes"));

    if (response.statusCode == 200) {
      return json.decode(response.body)['dados'];
    } else {
      throw Exception('Erro ao carregar proposições');
    }
  }
}