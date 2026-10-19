import 'package:flutter/material.dart';
import '../services/camara_service.dart';

const _kGreen = Color(0xFF4F8F63);
const _kYellow = Color(0xFFE3C34B);

const _tipoLabels = {
  'PEC': 'Proposta de Emenda à Constituição',
  'PL': 'Projeto de Lei',
  'PLP': 'Projeto de Lei Complementar',
  'MPV': 'Medida Provisória',
};

/// Modal de filtros, aberto por cima da tela atual (ver [show]).
class FilterScreen {
  const FilterScreen._();

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    Map<dynamic, dynamic>? initial,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(initial: initial),
    );
  }
}

class _FiltroAtivo {
  final String label;
  final VoidCallback onRemove;

  _FiltroAtivo(this.label, this.onRemove);
}

class _FilterSheet extends StatefulWidget {
  final Map<dynamic, dynamic>? initial;

  const _FilterSheet({this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final CamaraService _service = CamaraService();

  late final TextEditingController _deputadoController;
  late final TextEditingController _partidoController;
  late final TextEditingController _numeroController;

  String? selectedTipo;
  String? selectedAno;
  String? selectedTema;
  String? selectedSituacao;

  List<String> tipos = [];
  List<String> anos = [];
  List<Map<String, String>> temas = [];
  List<Map<String, String>> situacoes = [];

  bool _carregando = true;
  bool _ativosExpanded = true;
  bool _anoExpanded = false;
  bool _temaExpanded = false;
  bool _situacaoExpanded = false;
  bool _tipoExpanded = true;

  static const _labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
    color: Colors.black87,
  );

  @override
  void initState() {
    super.initState();

    final initial = widget.initial ?? const {};
    _deputadoController =
        TextEditingController(text: (initial['deputado'] as String?) ?? '');
    _partidoController =
        TextEditingController(text: (initial['partido'] as String?) ?? '');
    _numeroController =
        TextEditingController(text: (initial['numero'] as String?) ?? '');
    selectedTipo = initial['tipo'] as String?;
    selectedAno = initial['ano'] as String?;
    selectedTema = initial['tema'] as String?;
    selectedSituacao = initial['situacao'] as String?;

    _carregarDados();
  }

  @override
  void dispose() {
    _deputadoController.dispose();
    _partidoController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final resultados = await Future.wait([
      _service.getTiposProposicao(),
      _service.getAnos(),
      _service.getTemas(),
      _service.getSituacoes(),
    ]);

    if (!mounted) return;

    setState(() {
      tipos = resultados[0] as List<String>;
      anos = resultados[1] as List<String>;
      temas = resultados[2] as List<Map<String, String>>;
      situacoes = resultados[3] as List<Map<String, String>>;
      _carregando = false;
    });
  }

  List<_FiltroAtivo> get _filtrosAtivos {
    final lista = <_FiltroAtivo>[];

    if (selectedTipo != null) {
      lista.add(_FiltroAtivo(selectedTipo!, () {
        setState(() => selectedTipo = null);
      }));
    }

    if (selectedAno != null) {
      lista.add(_FiltroAtivo(selectedAno!, () {
        setState(() => selectedAno = null);
      }));
    }

    if (_numeroController.text.trim().isNotEmpty) {
      lista.add(_FiltroAtivo('Nº ${_numeroController.text.trim()}', () {
        setState(_numeroController.clear);
      }));
    }

    if (_deputadoController.text.trim().isNotEmpty) {
      lista.add(_FiltroAtivo(_deputadoController.text.trim(), () {
        setState(_deputadoController.clear);
      }));
    }

    if (_partidoController.text.trim().isNotEmpty) {
      lista.add(_FiltroAtivo(_partidoController.text.trim(), () {
        setState(_partidoController.clear);
      }));
    }

    if (selectedTema != null) {
      final nome = temas.firstWhere(
        (tema) => tema['cod'] == selectedTema,
        orElse: () => const {},
      )['nome'];
      lista.add(_FiltroAtivo(nome ?? 'Tema', () {
        setState(() => selectedTema = null);
      }));
    }

    if (selectedSituacao != null) {
      final nome = situacoes.firstWhere(
        (situacao) => situacao['cod'] == selectedSituacao,
        orElse: () => const {},
      )['nome'];
      lista.add(_FiltroAtivo(nome ?? 'Situação', () {
        setState(() => selectedSituacao = null);
      }));
    }

    return lista;
  }

  void _aplicar() {
    final temaSelecionado = temas.firstWhere(
      (tema) => tema['cod'] == selectedTema,
      orElse: () => const {},
    );

    final situacaoSelecionada = situacoes.firstWhere(
      (situacao) => situacao['cod'] == selectedSituacao,
      orElse: () => const {},
    );

    Navigator.pop(context, {
      'tipo': selectedTipo,
      'ano': selectedAno,
      'numero': _numeroController.text.trim(),
      'deputado': _deputadoController.text.trim(),
      'partido': _partidoController.text.trim(),
      'tema': selectedTema,
      'temaNome': temaSelecionado['nome'],
      'situacao': selectedSituacao,
      'situacaoNome': situacaoSelecionada['nome'],
    });
  }

  Widget _sectionHeader(String label, bool expanded, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _labelStyle.copyWith(fontSize: 15)),
            Icon(
              expanded ? Icons.remove : Icons.add,
              size: 20,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _carregando
            ? const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_list, color: _kGreen),
                        const SizedBox(width: 10),
                        const Text(
                          'FILTROS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    if (_filtrosAtivos.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _sectionHeader(
                        'FILTROS ATIVOS',
                        _ativosExpanded,
                        () => setState(() => _ativosExpanded = !_ativosExpanded),
                      ),
                      if (_ativosExpanded)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _filtrosAtivos
                              .map((filtro) => _FiltroChip(
                                    label: filtro.label,
                                    onRemove: filtro.onRemove,
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: Colors.grey.shade300),
                    ],

                    const SizedBox(height: 18),
                    const Text('DEPUTADO', style: _labelStyle),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _deputadoController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Digite o nome do deputado',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('PARTIDO', style: _labelStyle),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _partidoController,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Digite o partido',
                        prefixIcon: Icon(Icons.groups_outlined),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('NÚMERO DA PROPOSIÇÃO', style: _labelStyle),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _numeroController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Digite o número (ex: 1234)',
                        prefixIcon: Icon(Icons.tag),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Divider(height: 1, color: Colors.grey.shade300),
                    _sectionHeader(
                      'ANO',
                      _anoExpanded,
                      () => setState(() => _anoExpanded = !_anoExpanded),
                    ),
                    if (_anoExpanded)
                      ...anos.map((ano) => _OptionRow(
                            label: ano,
                            selected: selectedAno == ano,
                            onTap: () => setState(
                              () => selectedAno = selectedAno == ano ? null : ano,
                            ),
                          )),

                    Divider(height: 1, color: Colors.grey.shade300),
                    _sectionHeader(
                      'TEMA',
                      _temaExpanded,
                      () => setState(() => _temaExpanded = !_temaExpanded),
                    ),
                    if (_temaExpanded)
                      SizedBox(
                        height: 220,
                        child: ListView(
                          shrinkWrap: true,
                          children: temas
                              .map((tema) => _OptionRow(
                                    label: tema['nome'] ?? '',
                                    selected: selectedTema == tema['cod'],
                                    onTap: () => setState(() {
                                      selectedTema = selectedTema == tema['cod']
                                          ? null
                                          : tema['cod'];
                                    }),
                                  ))
                              .toList(),
                        ),
                      ),

                    Divider(height: 1, color: Colors.grey.shade300),
                    _sectionHeader(
                      'SITUAÇÃO',
                      _situacaoExpanded,
                      () => setState(
                          () => _situacaoExpanded = !_situacaoExpanded),
                    ),
                    if (_situacaoExpanded)
                      SizedBox(
                        height: 220,
                        child: ListView(
                          shrinkWrap: true,
                          children: situacoes
                              .map((situacao) => _OptionRow(
                                    label: situacao['nome'] ?? '',
                                    selected:
                                        selectedSituacao == situacao['cod'],
                                    onTap: () => setState(() {
                                      selectedSituacao =
                                          selectedSituacao == situacao['cod']
                                              ? null
                                              : situacao['cod'];
                                    }),
                                  ))
                              .toList(),
                        ),
                      ),

                    Divider(height: 1, color: Colors.grey.shade300),
                    _sectionHeader(
                      'TIPO DA PROPOSIÇÃO',
                      _tipoExpanded,
                      () => setState(() => _tipoExpanded = !_tipoExpanded),
                    ),
                    if (_tipoExpanded)
                      ...tipos.map((tipo) => _OptionRow(
                            label: '$tipo - ${_tipoLabels[tipo] ?? tipo}',
                            selected: selectedTipo == tipo,
                            onTap: () => setState(
                              () => selectedTipo =
                                  selectedTipo == tipo ? null : tipo,
                            ),
                          )),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kYellow,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _aplicar,
                        child: const Text(
                          'APLICAR FILTROS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FiltroChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? _kGreen : Colors.black87,
          ),
        ),
      ),
    );
  }
}
