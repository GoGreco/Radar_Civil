import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post.dart';
import '../widgets/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

const _kGreen = Color(0xFF4F8F63);
const _kYellow = Color(0xFFE3C34B);

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
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _kGreen,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner do autor principal ─────────────────────────────────
            FutureBuilder<AutoresInfo>(
              future: Post.buscarAutoresPrincipais(post.id),
              builder: (context, snapshot) {
                final autor =
                    snapshot.data?.principais.isNotEmpty == true
                        ? snapshot.data!.principais.first
                        : null;
                return _AutorBanner(autor: autor);
              },
            ),

            // ── Corpo ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: -24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  FutureBuilder<String>(
                    future: _buscarTextoPdf(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
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
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // Data + Voltar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          post.date.isEmpty
                              ? "Data não informada"
                              : post.date,
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

                  const SizedBox(height: 18),

                  // Barra de progresso (mesmo padrão dos cards da Home)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 6,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 25,
                            child: Container(color: _kYellow),
                          ),
                          Expanded(
                            flex: 75,
                            child: Container(color: Colors.grey.shade300),
                          ),
                        ],
                      ),
                    ),
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

// ── Widgets auxiliares ────────────────────────────────────────────────────

class _AutorBanner extends StatelessWidget {
  final Autor? autor;

  const _AutorBanner({required this.autor});

  @override
  Widget build(BuildContext context) {
    final temFoto = autor?.fotoUrl != null;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (temFoto)
            Image.network(
              autor!.fotoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _BannerFallbackBackground(),
            )
          else
            const _BannerFallbackBackground(),

          // Gradiente escuro na base para o texto ficar legível
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.4, 1],
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  autor?.nome ?? 'Câmara dos Deputados',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (autor?.siglaPartido.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.groups, size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        autor!.siglaPartido,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerFallbackBackground extends StatelessWidget {
  const _BannerFallbackBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGreen, Color(0xFF2E5E3F)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 64, color: Colors.white70),
    );
  }
}
