import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/detail_screen.dart';

const _kGreen = Color(0xFF4F8F63);
const _kYellow = Color(0xFFE3C34B);

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard(this.post, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 12),

                // Descrição
                Text(
                  post.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 12),

                // Hashtags
                Wrap(
                  spacing: 8,
                  children: [
                    if (post.tipo.isNotEmpty) _HashtagText(post.tipo),
                    if (post.ano.isNotEmpty) _HashtagText(post.ano),
                  ],
                ),

                const SizedBox(height: 16),

                // Autores
                FutureBuilder<AutoresInfo>(
                  future: Post.buscarAutoresPrincipais(post.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Carregando autores...',
                          style: TextStyle(
                            fontSize: 13,
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
                        const SizedBox(height: 10),
                        Text(
                          nomes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _kGreen,
                          ),
                        ),
                        if (extras > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+$extras autores',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Data + botão
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        post.date.isEmpty ? "Sem data" : post.date,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kYellow,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(post),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Ler mais",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.north_east, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Barra de progresso no rodapé
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
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

class _AvatarStack extends StatelessWidget {
  final List<Autor> autores;
  final int extras;

  const _AvatarStack({required this.autores, required this.extras});

  static const _avatarSize = 34.0;
  static const _overlap = 22.0;

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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGreen,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: Text(
                  '+$extras',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
