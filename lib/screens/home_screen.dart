import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/camara_service.dart';
import '../widgets/post_card.dart';
import '../widgets/app_drawer.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CamaraService _camaraService = CamaraService();

  late Future<List<Post>> _postsFuture;

  String? filtroTipo;
  String? filtroAno;

  @override
  void initState() {
    super.initState();
    _postsFuture = _loadPosts();
  }

  Future<List<Post>> _loadPosts() async {
    final dados = await _camaraService.getProposicoes(
      tipo: filtroTipo,
      ano: filtroAno,
    );

    return dados.map<Post>((item) {
      return Post.fromApi(item);
    }).toList();
  }

  Future<void> abrirFiltros() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FilterScreen(),
      ),
    );

    if (resultado != null) {
      setState(() {
        filtroTipo = resultado['tipo'];
        filtroAno = resultado['ano'];
        _postsFuture = _loadPosts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF4F8F63),
        centerTitle: true,
        title: const Text(
          'RADAR CIVIL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: abrirFiltros,
          ),
        ],
      ),

      body: Column(
        children: [
          if (filtroTipo != null || filtroAno != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade50,
              child: Wrap(
                spacing: 10,
                children: [
                  if (filtroTipo != null)
                    Chip(
                      label: Text("Tipo: $filtroTipo"),
                    ),

                  if (filtroAno != null)
                    Chip(
                      label: Text("Ano: $filtroAno"),
                    ),
                ],
              ),
            ),

          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Erro ao carregar proposições',
                    ),
                  );
                }

                final posts = snapshot.data ?? [];

                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma proposição encontrada',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _postsFuture = _loadPosts();
                    });
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(posts[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F8F63),
        onPressed: abrirFiltros,
        child: const Icon(Icons.filter_alt),
      ),
    );
  }
}