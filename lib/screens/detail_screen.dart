import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';
import '../services/saved_posts_service.dart';
import '../widgets/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

const _kGreen = Color(0xFF4F8F63);
const _kYellow = Color(0xFFE3C34B);

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen(this.post, {super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Post get post => widget.post;

  late final Future<List<PdfParagrafo>> _futureTexto = _buscarTextoPdf();

  /// Busca o urlInteiroTeor via API e abre no navegador padrão do sistema.
  Future<void> _abrirOriginal() async {
    final pdfUrl = await Post.buscarUrlInteiroTeor(post.id);

    if (pdfUrl == null || pdfUrl.isEmpty) {
      debugPrint('urlInteiroTeor não disponível para proposição ${post.id}');
      return;
    }

    if (Platform.isLinux) {
      await Process.run('xdg-open', [pdfUrl]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [pdfUrl]);
    } else if (Platform.isWindows) {
      await Process.run('explorer', [pdfUrl]);
    } else {
      if (await canLaunchUrl(Uri.parse(pdfUrl))) {
        await launchUrl(Uri.parse(pdfUrl));
      } else {
        debugPrint('Não foi possível abrir a URL: $pdfUrl');
      }
    }
  }

  /// Busca a URL do PDF e extrai o texto com formatação.
  Future<List<PdfParagrafo>> _buscarTextoPdf() async {
    final pdfUrl = await Post.buscarUrlInteiroTeor(post.id);

    if (pdfUrl == null || pdfUrl.isEmpty) return [];

    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF: ${response.statusCode}');
    }

    final document = PdfDocument(inputBytes: response.bodyBytes);
    try {
      return extrairParagrafos(document);
    } finally {
      document.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kGreen,
        centerTitle: true,
        leadingWidth: 96,
        leading: Builder(
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Voltar',
                onPressed: () => Navigator.pop(context),
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ],
          ),
        ),
        title: const Text(
          'RADAR CIVIL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Autores (scroll horizontal) ───────────────────────────────
            Container(
              width: double.infinity,
              color: _kGreen,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: FutureBuilder<AutoresInfo>(
                future: Post.buscarAutoresPrincipais(post.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 130,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  final info = snapshot.data!;

                  if (info.principais.isEmpty) {
                    return const _AutorFallback();
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: info.principais.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, index) =>
                              _AutorCard(autor: info.principais[index]),
                        ),
                      ),
                      if (info.total > info.principais.length) ...[
                        const SizedBox(height: 10),
                        Text(
                          '+${info.total - info.principais.length} autores',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            // ── Corpo ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Situação + salvar
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<DetalhesProposicao>(
                          future: Post.buscarDetalhes(post.id),
                          builder: (context, snapshot) {
                            final situacao = snapshot.data?.descricaoSituacao;
                            if (situacao == null || situacao.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return _SituacaoBadge(situacao: situacao);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SalvarButton(post: post),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Texto extraído do PDF
                  FutureBuilder<List<PdfParagrafo>>(
                    future: _futureTexto,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          'Não foi possível carregar o texto original.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        );
                      }

                      final paragrafos = snapshot.data ?? [];
                      if (paragrafos.isEmpty) {
                        return const Text('Texto original não disponível.');
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final p in paragrafos)
                            Padding(
                              padding: EdgeInsets.only(
                                left: p.indent,
                                top: p.spaceBefore,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Text.rich(
                                  TextSpan(children: p.spans),
                                  textAlign: p.align,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Hashtags
                  Wrap(
                    spacing: 8,
                    children: [
                      if (post.tipo.isNotEmpty) _HashtagText(post.tipo),
                      if (post.ano.isNotEmpty) _HashtagText(post.ano),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Data + Voltar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          post.date.isEmpty ? "Data não informada" : post.date,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Voltar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kYellow,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _abrirOriginal,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ver Original",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.north_east, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Extração de PDF com formatação ────────────────────────────────────────

class PdfParagrafo {
  final List<TextSpan> spans;
  final TextAlign align;
  final double indent;
  final double spaceBefore;

  PdfParagrafo(this.spans, this.align, this.indent, this.spaceBefore);
}

List<PdfParagrafo> extrairParagrafos(PdfDocument document) {
  final extractor = PdfTextExtractor(document);
  final porPagina = <List<TextLine>>[];
  final larguras = <double>[];
  final freq = <double, int>{};
  double minLeft = double.infinity;

  for (var i = 0; i < document.pages.count; i++) {
    final linhas =
        extractor.extractTextLines(startPageIndex: i, endPageIndex: i);
    porPagina.add(linhas);
    larguras.add(document.pages[i].size.width);

    for (final l in linhas) {
      if (l.text.trim().isEmpty) continue;
      final s = double.parse(l.fontSize.toStringAsFixed(1));
      freq[s] = (freq[s] ?? 0) + l.text.length;
      if (l.bounds.left < minLeft) minLeft = l.bounds.left;
    }
  }

  // Tamanho de fonte mais comum = corpo do texto
  final base = freq.isEmpty
      ? 12.0
      : freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  const corpo = 15.0; // tamanho exibido para o texto base
  final resultado = <PdfParagrafo>[];

  var spans = <TextSpan>[];
  var align = TextAlign.left;
  var indent = 0.0;
  var antes = 0.0;
  double? ultimoBottom;
  double ultimoSize = base;
  double ultimoLeft = minLeft;

  void fechar() {
    if (spans.isNotEmpty) {
      resultado.add(PdfParagrafo(spans, align, indent, antes));
    }
    spans = <TextSpan>[];
  }

  for (var p = 0; p < porPagina.length; p++) {
    final larguraPagina = larguras[p];
    ultimoBottom = null; // nova página não força novo parágrafo

    for (final linha in porPagina[p]) {
      if (linha.text.trim().isEmpty) continue;

      final size = linha.fontSize;
      final gap = ultimoBottom == null ? 0.0 : linha.bounds.top - ultimoBottom;

      final mudouTamanho = (size - ultimoSize).abs() > 1;
      final espacoGrande = gap > size * 0.5;
      final recuoNovo = linha.bounds.left - ultimoLeft > 10;

      if (spans.isNotEmpty && (mudouTamanho || espacoGrande || recuoNovo)) {
        fechar();
      }

      if (spans.isEmpty) {
        // Propriedades do parágrafo definidas pela primeira linha
        final centroLinha = linha.bounds.left + linha.bounds.width / 2;
        final centralizado =
            (centroLinha - larguraPagina / 2).abs() < 10 &&
                linha.bounds.left - minLeft > 20;
        align = centralizado ? TextAlign.center : TextAlign.left;
        indent = centralizado
            ? 0
            : ((linha.bounds.left - minLeft) * 0.5).clamp(0.0, 60.0);
        antes = resultado.isEmpty ? 0 : (gap > 0 ? 12 : 8);
      }

      for (final palavra in linha.wordCollection) {
        spans.add(TextSpan(
          text: '${palavra.text} ',
          style: _estilo(palavra, base, corpo),
        ));
      }

      ultimoBottom = linha.bounds.bottom;
      ultimoSize = size;
      ultimoLeft = linha.bounds.left;
    }
  }
  fechar();
  return resultado;
}

TextStyle _estilo(TextWord w, double base, double corpo) {
  final nome = w.fontName.toLowerCase();
  final negrito =
      w.fontStyle.contains(PdfFontStyle.bold) || nome.contains('bold');
  final italico =
      w.fontStyle.contains(PdfFontStyle.italic) || nome.contains('italic');
  final sublinhado = w.fontStyle.contains(PdfFontStyle.underline);

  return TextStyle(
    fontSize: (w.fontSize / base * corpo).clamp(11.0, 26.0),
    fontWeight: negrito ? FontWeight.bold : FontWeight.normal,
    fontStyle: italico ? FontStyle.italic : FontStyle.normal,
    decoration: sublinhado ? TextDecoration.underline : TextDecoration.none,
    height: 1.5,
    color: Colors.grey.shade800,
  );
}

// ── Widgets auxiliares ────────────────────────────────────────────────────

class _AutorCard extends StatelessWidget {
  final Autor autor;

  const _AutorCard({required this.autor});

  @override
  Widget build(BuildContext context) {
    final temFoto = autor.fotoUrl != null && autor.fotoUrl!.isNotEmpty;

    return SizedBox(
      width: 90,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: temFoto
                ? Image.network(
                    autor.fotoUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _AutorFotoFallback(),
                  )
                : const _AutorFotoFallback(),
          ),
          const SizedBox(height: 6),
          Text(
            autor.nome.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (autor.siglaPartido.isNotEmpty)
            Text(
              autor.siglaPartido,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
        ],
      ),
    );
  }
}

class _AutorFotoFallback extends StatelessWidget {
  const _AutorFotoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      color: Colors.white24,
      child: const Icon(Icons.person, color: Colors.white70, size: 36),
    );
  }
}

class _AutorFallback extends StatelessWidget {
  const _AutorFallback();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, size: 40, color: Colors.white70),
        ),
        SizedBox(height: 10),
        Text(
          'Câmara dos Deputados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SituacaoBadge extends StatelessWidget {
  final String situacao;

  const _SituacaoBadge({required this.situacao});

  @override
  Widget build(BuildContext context) {
    final situacaoLower = situacao.toLowerCase();
    final encerrada = situacaoLower.contains('arquiv') ||
        situacaoLower.contains('retirad') ||
        situacaoLower.contains('vetad');

    final cor = encerrada ? Colors.grey.shade600 : const Color(0xFFE3902E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              situacao.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HashtagText extends StatelessWidget {
  final String label;

  const _HashtagText(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      '#$label',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: _kGreen,
      ),
    );
  }
}

class _SalvarButton extends StatefulWidget {
  final Post post;

  const _SalvarButton({required this.post});

  @override
  State<_SalvarButton> createState() => _SalvarButtonState();
}

class _SalvarButtonState extends State<_SalvarButton> {
  final SavedPostsService _service = SavedPostsService();

  bool _salvo = false;
  bool _carregado = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final salvo = await _service.estaSalvo(widget.post.id);
    if (!mounted) return;
    setState(() {
      _salvo = salvo;
      _carregado = true;
    });
  }

  Future<void> _alternar() async {
    setState(() => _salvo = !_salvo);
    final estado = await _service.alternar(widget.post);
    if (!mounted) return;
    setState(() => _salvo = estado);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _carregado ? _alternar : null,
        tooltip: _salvo ? 'Remover dos salvos' : 'Salvar',
        icon: Icon(
          _salvo ? Icons.bookmark : Icons.bookmark_border,
          color: _kGreen,
        ),
      ),
    );
  }
}