import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/camara_service.dart';
import '../widgets/post_card.dart';
import '../widgets/app_drawer.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.filtrosIniciais});

  final Map<dynamic, dynamic>? filtrosIniciais;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _itensPorPagina = 20;

  final CamaraService _camaraService = CamaraService();

  List<Post> _posts = [];
  int _paginaAtual = 1;
  bool _carregandoInicial = true;
  bool _carregandoMais = false;
  bool _temMais = true;
  bool _erro = false;

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

    _carregarInicial();
  }

  Future<List<Post>> _buscarPagina(int pagina) async {
    final dados = await _camaraService.getProposicoes(
      tipo: filtroTipo,
      ano: filtroAno,
      numero: filtroNumero,
      deputado: filtroDeputado,
      partido: filtroPartido,
      codTema: filtroTema,
      codSituacao: filtroSituacao,
      pagina: pagina,
      itens: _itensPorPagina,
    );

    return dados.map<Post>((item) => Post.fromApi(item)).toList();
  }

  Future<void> _carregarInicial() async {
    setState(() {
      _carregandoInicial = true;
      _erro = false;
    });

    try {
      final posts = await _buscarPagina(1);

      if (!mounted) return;
      setState(() {
        _posts = posts;
        _paginaAtual = 1;
        _temMais = posts.length >= _itensPorPagina;
        _carregandoInicial = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = true;
        _carregandoInicial = false;
      });
    }
  }

  Future<void> _carregarMais() async {
    if (_carregandoMais || !_temMais) return;

    setState(() => _carregandoMais = true);

    final proximaPagina = _paginaAtual + 1;

    try {
      final novosPosts = await _buscarPagina(proximaPagina);

      if (!mounted) return;
      setState(() {
        _posts = [..._posts, ...novosPosts];
        _paginaAtual = proximaPagina;
        _temMais = novosPosts.length >= _itensPorPagina;
        _carregandoMais = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoMais = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar mais proposições')),
      );
    }
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

  Future<void> abrirFiltros() async {
    final resultado = await FilterScreen.show(context, initial: _filtrosAtuais);

    if (resultado != null && mounted) {
      _aplicarFiltros(resultado);
      await _carregarInicial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: AppDrawer(
        current: AppDrawerSection.home,
        onAbrirFiltros: abrirFiltros,
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

          Expanded(child: _buildCorpo()),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F8F63),
        onPressed: abrirFiltros,
        child: const Icon(Icons.filter_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildCorpo() {
    if (_carregandoInicial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro && _posts.isEmpty) {
      return const Center(
        child: Text('Erro ao carregar proposições'),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text('Nenhuma proposição encontrada'),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarInicial,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index < _posts.length) {
            return PostCard(_posts[index]);
          }
          return _buildRodape();
        },
      ),
    );
  }

  Widget _buildRodape() {
    if (_carregandoMais) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_temMais) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Não há mais proposições',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _carregarMais,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4F8F63),
            side: const BorderSide(color: Color(0xFF4F8F63)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'CARREGAR MAIS',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
