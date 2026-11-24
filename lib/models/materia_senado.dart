class MateriaSenado {
  final int id;
  final String identificacao;
  final String ementa;
  final String autoria;
  final String dataApresentacao;
  final String tipoDocumento;
  final String situacaoAtual;
  final String? urlDocumento;

  MateriaSenado({
    required this.id,
    required this.identificacao,
    required this.ementa,
    required this.autoria,
    required this.dataApresentacao,
    required this.tipoDocumento,
    required this.situacaoAtual,
    this.urlDocumento,
  });

  /// Sigla extraída de [identificacao] (ex.: "PL" em "PL 1/2024").
  String get sigla => identificacao.isEmpty ? '' : identificacao.split(' ').first;

  factory MateriaSenado.fromApi(Map<String, dynamic> json) {
    final id = json['id'];
    return MateriaSenado(
      id: id is int ? id : int.tryParse('$id') ?? 0,
      identificacao: (json['identificacao'] ?? '').toString(),
      ementa: (json['ementa'] ?? 'Sem descrição').toString(),
      autoria: (json['autoria'] ?? 'Autor desconhecido').toString(),
      dataApresentacao: (json['dataApresentacao'] ?? '').toString(),
      tipoDocumento: (json['tipoDocumento'] ?? '').toString(),
      situacaoAtual: (json['situacaoAtual'] ?? '').toString(),
      urlDocumento: json['urlDocumento'] as String?,
    );
  }
}
