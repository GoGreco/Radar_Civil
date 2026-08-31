import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DetailScreen extends StatelessWidget {
  final Post post;

  const DetailScreen(this.post, {super.key});

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

  /// Busca a URL do PDF e extrai o texto de dentro dele.
  Future<String> _buscarTextoPdf() async {
    final pdfUrl = await Post.buscarUrlInteiroTeor(post.id);

    if (pdfUrl == null || pdfUrl.isEmpty) {
      return 'Texto original não disponível.';
    }

    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF: ${response.statusCode}');
    }

    final bytes = response.bodyBytes;
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    try {
      final text = PdfTextExtractor(document).extractText();
      return text;
    } finally {
      document.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes"),
        backgroundColor: const Color(0xFF4F8F63),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header verde com autores ──────────────────────────────────
            Container(
              width: double.infinity,
              color: const Color(0xFF4F8F63),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: FutureBuilder<AutoresInfo>(
                future: Post.buscarAutoresPrincipais(post.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  final info = snapshot.data!;
                  final autores = info.principais;

                  if (autores.isEmpty) {
                    return const _AutorFallback();
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: autores
                            .map((autor) => _AutorColuna(autor: autor))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${info.total} autores totais',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Corpo ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Chip(label: Text(post.tipo)),
                      const SizedBox(width: 8),
                      Chip(label: Text(post.ano)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Texto extraído do PDF
                  FutureBuilder<String>(
                    future: _buscarTextoPdf(),
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

                      return Text(
                        snapshot.data ?? '',
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.date.isEmpty ? "Data não informada" : post.date,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE3C34B),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _abrirOriginal,
                      icon: const Icon(Icons.language),
                      label: const Text("Ver Original"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Voltar"),
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

// ── Widgets auxiliares ────────────────────────────────────────────────────

class _AutorColuna extends StatelessWidget {
  final Autor autor;

  const _AutorColuna({required this.autor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white.withOpacity(0.25),
            backgroundImage:
                autor.fotoUrl != null ? NetworkImage(autor.fotoUrl!) : null,
            child: autor.fotoUrl == null
                ? const Icon(Icons.person, size: 38, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            autor.nome,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          if (autor.siglaPartido.isNotEmpty)
            Text(
              autor.siglaPartido,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
        ],
      ),
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
          radius: 45,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 50, color: Color(0xFF4F8F63)),
        ),
        SizedBox(height: 10),
        Text(
          'Câmara dos Deputados',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}