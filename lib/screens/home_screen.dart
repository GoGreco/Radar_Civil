import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/camara_service.dart';
import '../widgets/post_card.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.filtrosIniciais});

  final Map<dynamic, dynamic>? filtrosIniciais;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CamaraService _camaraService = CamaraService();

  late Future<List<Post>> _postsFuture;

  String? filtroTipo;
  String? filtroAno;
  String? filtroNumero;
  String? filtroDeputado;
  String? filtroPartido;
  String? filtroTema;
  String? filtroTemaNome;
  String? filtroSituacao;
  String? filtroSituacaoNome;

  @override
  void initState() {
    super.initState();

    if (widget.filtrosIniciais != null) {
      _aplicarFiltros(widget.filtrosIniciais!);
    }

    _postsFuture = _loadPosts();
  }

  Future<List<Post>> _loadPosts() async {
    final dados = await _camaraService.getProposicoes(
      tipo: filtroTipo,
      ano: filtroAno,
      numero: filtroNumero,
      deputado: filtroDeputado,
      partido: filtroPartido,
      codTema: filtroTema,
      codSituacao: filtroSituacao,
    );

    return dados.map<Post>((item) {
      return Post.fromApi(item);
    }).toList();
  }

  void _aplicarFiltros(Map<dynamic, dynamic> resultado) {
    filtroTipo = resultado['tipo'];
    filtroAno = resultado['ano'];

    final numero = (resultado['numero'] as String?) ?? '';
    filtroNumero = numero.isEmpty ? null : numero;

    final deputado = (resultado['deputado'] as String?) ?? '';
    filtroDeputado = deputado.isEmpty ? null : deputado;

    final partido = (resultado['partido'] as String?) ?? '';
    filtroPartido = partido.isEmpty ? null : partido;

    filtroTema = resultado['tema'];
    filtroTemaNome = resultado['temaNome'];
    filtroSituacao = resultado['situacao'];
    filtroSituacaoNome = resultado['situacaoNome'];
  }

  Map<String, dynamic> get _filtrosAtuais => {
        'tipo': filtroTipo,
        'ano': filtroAno,
        'numero': filtroNumero,
        'deputado': filtroDeputado,
        'partido': filtroPartido,
        'tema': filtroTema,
        'temaNome': filtroTemaNome,
        'situacao': filtroSituacao,
        'situacaoNome': filtroSituacaoNome,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AppDrawer(
        current: AppDrawerSection.home,
        filtrosAtuais: _filtrosAtuais,
        onFiltrosAplicados: (resultado) {
          setState(() {
            _aplicarFiltros(resultado);
            _postsFuture = _loadPosts();
          });
        },
      ),

      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          if (filtroTipo != null ||
              filtroAno != null ||
              filtroNumero != null ||
              filtroDeputado != null ||
              filtroPartido != null ||
              filtroTema != null ||
              filtroSituacao != null)
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

                  if (filtroNumero != null)
                    Chip(
                      label: Text("Número: $filtroNumero"),
                    ),

                  if (filtroDeputado != null)
                    Chip(
                      label: Text("Deputado: $filtroDeputado"),
                    ),

                  if (filtroPartido != null)
                    Chip(
                      label: Text("Partido: $filtroPartido"),
                    ),

                  if (filtroTema != null)
                    Chip(
                      label: Text("Tema: ${filtroTemaNome ?? filtroTema}"),
                    ),

                  if (filtroSituacao != null)
                    Chip(
                      label: Text(
                        "Situação: ${filtroSituacaoNome ?? filtroSituacao}",
                      ),
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
    );
  }
}
