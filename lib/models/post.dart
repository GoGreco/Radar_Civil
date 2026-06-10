class Post {
  final int id;
  final String author;
  final String title;
  final String description;
  final String date;
  final String tipo;
  final String ano;
  final String? link;

  Post({
    required this.id,
    required this.author,
    required this.title,
    required this.description,
    required this.date,
    required this.tipo,
    required this.ano,
    this.link,
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
    );
  }
}