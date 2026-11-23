import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/camara_service.dart';
import '../widgets/post_card.dart';
import '../widgets/app_drawer.dart';
import 'filter_screen.dart';
import 'saved_screen.dart';

const _kGreen = Color(0xFF4F8F63);
const _kGreenEscuro = Color(0xFF237227);

/// Em telas largas (tablet, web, desktop) o feed fica centralizado com esta
/// largura máxima, mantendo a aparência de app de celular.
const _kLarguraMaxima = 640.0;

enum _Casa { camara, senado }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.filtrosIniciais});

  final Map<dynamic, dynamic>? filtrosIniciais;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _itensPorPagina = 20;

  final CamaraService _camaraService = CamaraService();
  final ScrollController _scroll = ScrollController();

  _Casa _casaAtual = _Casa.camara;

  List<Post> _posts = [];
  int _paginaAtual = 1;
  bool _carregandoInicial = true;
  bool _carregandoMais = false;
  bool _temMais = true;
  bool _erro = false;
  bool _erroAoCarregarMais = false;

  /// Incrementa a cada mudança de filtro para descartar respostas atrasadas.
  int _geracao = 0;

  /// Incrementa ao voltar da tela de salvos, para os cards da lista relerem
  /// se estão salvos ou não.
  int _versaoSalvos = 0;

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

    _scroll.addListener(_aoRolar);
    _carregarInicial();
  }

  @override
  void dispose() {
    _scroll.removeListener(_aoRolar);
    _scroll.dispose();
    super.dispose();
  }

  void _aoRolar() {
    if (_casaAtual != _Casa.camara || !_scroll.hasClients) return;
    if (_scroll.position.extentAfter < 400) {
      _carregarMais();
    }
  }

  // ── Dados (Câmara) ───────────────────────────────────────────────────────

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
    final geracao = ++_geracao;

    setState(() {
      _carregandoInicial = true;
      _erro = false;
      _erroAoCarregarMais = false;
    });

    try {
      final posts = await _buscarPagina(1);

      if (!mounted || geracao != _geracao) return;
      setState(() {
        _posts = posts;
        _paginaAtual = 1;
        _temMais = posts.length >= _itensPorPagina;
        _carregandoInicial = false;
      });
    } catch (_) {
      if (!mounted || geracao != _geracao) return;
      setState(() {
        _erro = true;
        _carregandoInicial = false;
      });
    }
  }

  Future<void> _carregarMais() async {
    if (_carregandoInicial ||
        _carregandoMais ||
        !_temMais ||
        _erro ||
        _erroAoCarregarMais ||
        _posts.isEmpty) {
      return;
    }

    final geracao = _geracao;
    final proximaPagina = _paginaAtual + 1;

    setState(() => _carregandoMais = true);

    try {
      final novosPosts = await _buscarPagina(proximaPagina);

      if (!mounted || geracao != _geracao) return;
      setState(() {
        _posts = [..._posts, ...novosPosts];
        _paginaAtual = proximaPagina;
        _temMais = novosPosts.length >= _itensPorPagina;
        _carregandoMais = false;
      });
    } catch (_) {
      if (!mounted || geracao != _geracao) return;
      setState(() {
        _carregandoMais = false;
        _erroAoCarregarMais = true;
      });
    }
  }

  void _tentarCarregarMaisDeNovo() {
    setState(() => _erroAoCarregarMais = false);
    _carregarMais();
  }

  void _selecionarCasa(_Casa casa) {
    if (casa == _casaAtual) return;
    setState(() => _casaAtual = casa);
  }

  // ── Filtros ──────────────────────────────────────────────────────────────

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

  void _removerFiltro(VoidCallback limpar) {
    setState(limpar);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _carregarInicial();
  }

  List<_FiltroAtivoHome> get _filtrosAtivos {
    final lista = <_FiltroAtivoHome>[];

    if (filtroTipo != null) {
      lista.add(_FiltroAtivoHome(
        filtroTipo!,
        () => _removerFiltro(() => filtroTipo = null),
      ));
    }

    if (filtroAno != null) {
      lista.add(_FiltroAtivoHome(
        filtroAno!,
        () => _removerFiltro(() => filtroAno = null),
      ));
    }

    if (filtroNumero != null) {
      lista.add(_FiltroAtivoHome(
        filtroNumero!,
        () => _removerFiltro(() => filtroNumero = null),
      ));
    }

    if (filtroDeputado != null) {
      lista.add(_FiltroAtivoHome(
        filtroDeputado!,
        () => _removerFiltro(() => filtroDeputado = null),
      ));
    }

    if (filtroPartido != null) {
      lista.add(_FiltroAtivoHome(
        filtroPartido!,
        () => _removerFiltro(() => filtroPartido = null),
      ));
    }

    if (filtroTema != null) {
      lista.add(_FiltroAtivoHome(
        filtroTemaNome ?? filtroTema!,
        () => _removerFiltro(() {
          filtroTema = null;
          filtroTemaNome = null;
        }),
      ));
    }

    if (filtroSituacao != null) {
      lista.add(_FiltroAtivoHome(
        filtroSituacaoNome ?? filtroSituacao!,
        () => _removerFiltro(() {
          filtroSituacao = null;
          filtroSituacaoNome = null;
        }),
      ));
    }

    return lista;
  }

  Future<void> abrirFiltros() async {
    final resultado = await FilterScreen.show(context, initial: _filtrosAtuais);

    if (resultado != null && mounted) {
      _aplicarFiltros(resultado);
      if (_scroll.hasClients) _scroll.jumpTo(0);
      await _carregarInicial();
    }
  }

  Future<void> _abrirSalvos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedScreen()),
    );
    if (!mounted) return;
    setState(() => _versaoSalvos++);
  }

  // ── Interface ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final noSenado = _casaAtual == _Casa.senado;
    final filtros = noSenado ? const <_FiltroAtivoHome>[] : _filtrosAtivos;

    return Scaffold(
      endDrawer: AppDrawer(
        current: AppDrawerSection.home,
        onAbrirFiltros: abrirFiltros,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'Salvos',
            onPressed: _abrirSalvos,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: _AbasCasa(
            atual: _casaAtual,
            onSelecionar: _selecionarCasa,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kLarguraMaxima),
          child: Column(
            children: [
              if (filtros.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    itemCount: filtros.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) => _FiltroChip(
                      label: filtros[index].label,
                      onRemove: filtros[index].onRemove,
                    ),
                  ),
                ),
              Expanded(
                child: noSenado
                    ? const _MensagemCentral(
                        icone: Icons.account_balance_outlined,
                        texto: 'As proposições do Senado Federal\n'
                            'estarão disponíveis em breve.',
                      )
                    : _buildCorpo(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: noSenado
          ? null
          : FloatingActionButton(
              backgroundColor: _kGreen,
              onPressed: abrirFiltros,
              tooltip: 'Filtros',
              child: const Icon(Icons.filter_alt, color: Colors.white),
            ),
    );
  }

  Widget _buildCorpo() {
    if (_carregandoInicial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro && _posts.isEmpty) {
      return _MensagemCentral(
        icone: Icons.cloud_off,
        texto: 'Erro ao carregar proposições.',
        acao: 'Tentar novamente',
        onAcao: _carregarInicial,
      );
    }

    if (_posts.isEmpty) {
      return const _MensagemCentral(
        icone: Icons.search_off,
        texto: 'Nenhuma proposição encontrada.',
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarInicial,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 6, bottom: 88),
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index < _posts.length) {
            final post = _posts[index];
            return PostCard(
              post,
              key: ValueKey('${post.id}-$_versaoSalvos'),
            );
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

    if (_erroAoCarregarMais) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: _tentarCarregarMaisDeNovo,
            icon: const Icon(Icons.refresh),
            label: const Text('Erro ao carregar mais. Tentar novamente'),
            style: TextButton.styleFrom(foregroundColor: _kGreen),
          ),
        ),
      );
    }

    if (!_temMais) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Não há mais proposições',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}

// ── Componentes ────────────────────────────────────────────────────────────

/// Abas "Câmara dos Deputados" / "Senado Federal" na base da AppBar.
class _AbasCasa extends StatelessWidget {
  final _Casa atual;
  final ValueChanged<_Casa> onSelecionar;

  const _AbasCasa({required this.atual, required this.onSelecionar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: _Aba(
                label: 'Câmara dos Deputados',
                selecionada: atual == _Casa.camara,
                onTap: () => onSelecionar(_Casa.camara),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: _Aba(
                label: 'Senado Federal',
                selecionada: atual == _Casa.senado,
                onTap: () => onSelecionar(_Casa.senado),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  final String label;
  final bool selecionada;
  final VoidCallback onTap;

  const _Aba({
    required this.label,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const raio = BorderRadius.vertical(top: Radius.circular(8));

    return Semantics(
      button: true,
      selected: selecionada,
      label: label,
      child: Material(
        // A aba ativa usa a cor de fundo da tela para "se fundir" ao conteúdo.
        color: selecionada
            ? Theme.of(context).scaffoldBackgroundColor
            : _kGreenEscuro,
        borderRadius: raio,
        child: InkWell(
          onTap: onTap,
          borderRadius: raio,
          child: Container(
            height: 38,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selecionada ? FontWeight.w700 : FontWeight.w600,
                color: selecionada ? const Color(0xFF4A4A4A) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MensagemCentral extends StatelessWidget {
  final IconData icone;
  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  const _MensagemCentral({
    required this.icone,
    required this.texto,
    this.acao,
    this.onAcao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            if (acao != null && onAcao != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onAcao,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kGreen,
                  side: const BorderSide(color: _kGreen),
                ),
                child: Text(acao!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FiltroAtivoHome {
  final String label;
  final VoidCallback onRemove;

  _FiltroAtivoHome(this.label, this.onRemove);
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FiltroChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$label',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _kGreen,
            ),
          ),
          const SizedBox(width: 2),
          InkResponse(
            onTap: onRemove,
            radius: 16,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.close, size: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}