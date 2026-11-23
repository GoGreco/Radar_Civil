import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/situacao.dart';
import '../screens/detail_screen.dart';
import '../services/saved_posts_service.dart';

const _kGreen = Color(0xFF4F8F63);
const _kLaranja = Color(0xFFFFA725);
const _kHashtag = Color(0xFF899994);

/// Largura (em dp) abaixo da qual o card usa medidas mais compactas.
const _kLarguraCompacta = 360.0;

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard(this.post, {super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final SavedPostsService _salvosService = SavedPostsService();

  late final Future<AutoresInfo> _autores =
      Post.buscarAutoresPrincipais(widget.post.id);
  late final Future<DetalhesProposicao> _detalhes =
      Post.buscarDetalhes(widget.post.id);

  bool _salvo = false;

  Post get post => widget.post;

  @override
  void initState() {
    super.initState();
    _carregarSalvo();
  }

  Future<void> _carregarSalvo() async {
    final salvo = await _salvosService.estaSalvo(post.id);
    if (!mounted) return;
    setState(() => _salvo = salvo);
  }

  Future<void> _alternarSalvo() async {
    final novoEstado = await _salvosService.alternar(post);
    if (!mounted) return;
    setState(() => _salvo = novoEstado);
  }

  @override
  Widget build(BuildContext context) {
    final compacto = MediaQuery.sizeOf(context).width < _kLarguraCompacta;
    final padding = compacto ? 14.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: compacto ? 12 : 16,
        vertical: 8,
      ),
      // clipBehavior garante que a faixa de status não passe da borda
      // arredondada do card.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + botão de salvar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: compacto ? 17 : 18,
                          height: 1.2,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkResponse(
                      onTap: _alternarSalvo,
                      radius: 22,
                      child: Tooltip(
                        message: _salvo ? 'Remover dos salvos' : 'Salvar',
                        child: Icon(
                          _salvo ? Icons.bookmark : Icons.bookmark_border,
                          size: 26,
                          color: _salvo ? _kGreen : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Descrição
                Text(
                  post.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 13.5,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 10),

                // Hashtags
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    if (post.tipo.isNotEmpty) _HashtagText(post.tipo),
                    if (post.ano.isNotEmpty) _HashtagText(post.ano),
                  ],
                ),

                const SizedBox(height: 12),

                // Autores
                FutureBuilder<AutoresInfo>(
                  future: _autores,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return const SizedBox.shrink();

                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Carregando autores...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    final info = snapshot.data!;
                    final autores = info.principais;
                    final extras = info.total - autores.length;

                    if (autores.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final nomes = autores
                        .map((autor) => autor.siglaPartido.isNotEmpty
                            ? '${autor.nome} (${autor.siglaPartido})'
                            : autor.nome)
                        .join(', ');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AvatarStack(autores: autores, extras: extras),
                        const SizedBox(height: 8),
                        Text(
                          extras > 0 ? '$nomes…' : nomes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.3,
                            color: _kGreen,
                          ),
                        ),
                        if (extras > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+$extras autores',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Data + botão
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.date.isEmpty ? 'Sem data' : post.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kLaranja,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(post),
                          ),
                        );
                        // O usuário pode ter salvo/removido na tela de detalhes.
                        _carregarSalvo();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ler mais',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.north_east, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Faixa de status: reta, cortada pelo arredondamento do card.
          FutureBuilder<DetalhesProposicao>(
            future: _detalhes,
            builder: (context, snapshot) {
              final cor = corDaSituacao(snapshot.data?.codSituacao);

              return SizedBox(
                height: 5,
                width: double.infinity,
                child: ColoredBox(color: cor),
              );
            },
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
        fontSize: 12,
        color: _kHashtag,
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<Autor> autores;
  final int extras;

  const _AvatarStack({required this.autores, required this.extras});

  static const _avatarSize = 32.0;
  static const _overlap = 20.0;

  @override
  Widget build(BuildContext context) {
    final itemCount = autores.length + (extras > 0 ? 1 : 0);
    final width =
        itemCount == 0 ? 0.0 : _overlap * (itemCount - 1) + _avatarSize;

    return SizedBox(
      height: _avatarSize,
      width: width,
      child: Stack(
        children: [
          for (var i = 0; i < autores.length; i++)
            Positioned(
              left: i * _overlap,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: CircleAvatar(
                  radius: _avatarSize / 2 - 2,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: autores[i].fotoUrl != null
                      ? NetworkImage(autores[i].fotoUrl!)
                      : null,
                  child: autores[i].fotoUrl == null
                      ? const Icon(Icons.person, size: 16, color: Colors.grey)
                      : null,
                ),
              ),
            ),
          if (extras > 0)
            Positioned(
              left: autores.length * _overlap,
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade400,
                  border: const Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}