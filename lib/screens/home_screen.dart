import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/camara_service.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CamaraService _camaraService = CamaraService();
  late final Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _loadPosts();
  }

  Future<List<Post>> _loadPosts() async {
    final dados = await _camaraService.getProposicoes();

    return dados.map<Post>((item) {
      final tipo = (item['descricaoTipo'] ?? item['siglaTipo'] ?? 'Proposição').toString();
      final numero = (item['numero'] ?? '').toString();
      final ano = (item['ano'] ?? '').toString();
      final numeroAno = numero.isNotEmpty && ano.isNotEmpty
          ? '$numero/$ano'
          : (numero.isNotEmpty ? numero : ano);
      final title = numeroAno.isNotEmpty ? '$tipo $numeroAno' : tipo;
      final data = item['dataApresentacao']?.toString() ??
          (ano.isNotEmpty ? ano : 'Data não informada');

      return Post(
        author: 'Câmara dos Deputados',
        title: title,
        description: (item['ementa'] ?? 'Sem descrição').toString(),
        date: data,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Projeto Consciência")),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados da API'));
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(child: Text('Nenhuma proposição encontrada'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(posts[index]),
          );
        },
      ),
    );
  }
}