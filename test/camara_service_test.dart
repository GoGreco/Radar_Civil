import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:radar_civil/services/camara_service.dart';
import 'package:radar_civil/services/local_cache.dart';

void main() {
  test('reutiliza proposições do cache para a mesma consulta', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(
        jsonEncode({
          'dados': [
            {'id': 10, 'siglaTipo': 'PL', 'numero': 1, 'ano': 2026},
          ],
        }),
        200,
      );
    });
    final service = CamaraService(client: client, cache: MemoryCache());

    final first = await service.getProposicoes(tipo: 'PL');
    final second = await service.getProposicoes(tipo: 'PL');

    expect(first, hasLength(1));
    expect(second.single['id'], 10);
    expect(requests, 1);
  });

  test('separa o cache quando os filtros mudam', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(jsonEncode({'dados': []}), 200);
    });
    final service = CamaraService(client: client, cache: MemoryCache());

    await service.getProposicoes(tipo: 'PL');
    await service.getProposicoes(tipo: 'PEC');

    expect(requests, 2);
  });

  test('retorna cache expirado quando a rede falha', () async {
    final cache = MemoryCache();
    final client = MockClient((_) async {
      return http.Response('indisponível', 503);
    });
    final service = CamaraService(client: client, cache: cache);

    await cache.write(
      'proposicoes:itens=20&ordem=DESC&ordenarPor=id&pagina=1',
      jsonEncode({
        'savedAt': DateTime(2020).toIso8601String(),
        'data': [
          {'id': 42},
        ],
      }),
    );

    final result = await service.getProposicoes();

    expect(result.single['id'], 42);
  });
}