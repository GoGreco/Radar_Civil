class Proposicao {
  final int id;
  final String titulo;
  final String ementa;

  Proposicao({
    required this.id,
    required this.titulo,
    required this.ementa,
  });

  factory Proposicao.fromJson(Map<String, dynamic> json) {
    return Proposicao(
      id: json['id'],
      titulo: json['descricaoTipo'],
      ementa: json['ementa'] ?? '',
    );
  }
}