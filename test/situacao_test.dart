import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:radar_civil/models/situacao.dart';

void main() {
  test('mapeia os códigos de situação para as cores oficiais', () {
    expect(corDaSituacao('903'), const Color(0xFFFFA725));
    expect(corDaSituacao('923'), const Color(0xFFA4A4A4));
    expect(corDaSituacao('926'), const Color(0xFF15328A));
    expect(corDaSituacao('937'), const Color(0xFF722327));
    expect(corDaSituacao('1140'), const Color(0xFF237227));
  });

  test('usa cinza para código ausente ou desconhecido', () {
    expect(corDaSituacao(null), const Color(0xFFA4A4A4));
    expect(corDaSituacao('9999'), const Color(0xFFA4A4A4));
  });
}