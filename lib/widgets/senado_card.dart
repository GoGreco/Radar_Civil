import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/materia_senado.dart';

const _kGreen = Color(0xFF4F8F63);
const _kLaranja = Color(0xFFFFA725);
const _kHashtag = Color(0xFF899994);

/// Largura (em dp) abaixo da qual o card usa medidas mais compactas.
const _kLarguraCompacta = 360.0;

class SenadoCard extends StatelessWidget {
  final MateriaSenado materia;

  const SenadoCard(this.materia, {super.key});

  Future<void> _abrirDocumento() async {
    final url = materia.urlDocumento;
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
      padding: EdgeInsets.all(padding),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            materia.identificacao.isEmpty
                ? 'Matéria sem identificação'
                : materia.identificacao,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: compacto ? 17 : 18,
              height: 1.2,
              color: const Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            materia.ementa,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              height: 1.4,
              fontSize: 13.5,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 2,
            children: [
              if (materia.sigla.isNotEmpty) _HashtagText(materia.sigla),
              if (materia.situacaoAtual.isNotEmpty)
                _HashtagText(materia.situacaoAtual),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            materia.autoria,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: _kGreen,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Text(
                  materia.dataApresentacao.isEmpty
                      ? 'Sem data'
                      : materia.dataApresentacao,
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
                onPressed:
                    (materia.urlDocumento?.isNotEmpty ?? false)
                        ? _abrirDocumento
                        : null,
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
