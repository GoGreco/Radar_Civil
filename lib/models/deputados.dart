class Deputado {
  final int id;
  final String nome;
  final String siglaPartido;
  final String siglaUf;

  Deputado({
    required this.id,
    required this.nome,
    required this.siglaPartido,
    required this.siglaUf,
  });

  factory Deputado.fromJson(Map<String, dynamic> json) {
    return Deputado(
      id: json['id'],
      nome: json['nome'],
      siglaPartido: json['siglaPartido'],
      siglaUf: json['siglaUf'],
    );
  }
}