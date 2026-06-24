import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';

class DetailScreen extends StatelessWidget {
  final Post post;

  const DetailScreen(this.post, {super.key});

  /// Abre a página original da proposição no navegador padrão do sistema,
  /// sem depender de pacotes externos.
  Future<void> _abrirOriginal() async {
    final url =
        'https://www.camara.leg.br/proposicoesWeb/fichadetramitacao?idProposicao=${post.id}';

    if (Platform.isLinux) {
      await Process.run('xdg-open', [url]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [url]);
    } else if (Platform.isWindows) {
      await Process.run('explorer', [url]);
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Em mobile, dart:io não tem Process — fallback silencioso.
      // Adicione url_launcher se precisar suportar mobile.
      debugPrint('url_launcher necessário em mobile: $url');
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
                  // Enquanto carrega
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

                  // Sem autores encontrados
                  if (autores.isEmpty) {
                    return const _AutorFallback();
                  }

                  return Column(
                    children: [
                      // Avatares + nomes lado a lado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: autores
                            .map((autor) => _AutorColuna(autor: autor))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      // Total de autores
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
                  // Título
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Chips tipo / ano
                  Row(
                    children: [
                      Chip(label: Text(post.tipo)),
                      const SizedBox(width: 8),
                      Chip(label: Text(post.ano)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Ementa
                  Text(
                    post.description,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const SizedBox(height: 25),

                  // Data
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

                  // Botão Ver Original
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

                  // Botão Voltar
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

// ── Widgets auxiliares ────────────────────────────────────────────────────────

/// Coluna com foto + "Nome/Partido" para um único autor.
class _AutorColuna extends StatelessWidget {
  final Autor autor;

  const _AutorColuna({required this.autor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Foto
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
          // Nome
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
          // Partido (só exibe se não estiver vazio)
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

/// Fallback exibido quando não há autores retornados pela API.
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