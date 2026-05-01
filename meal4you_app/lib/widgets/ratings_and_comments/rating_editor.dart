import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:meal4you_app/models/user_rating_request_dto.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';

class RatingEditor extends StatefulWidget {
  final int restaurantId;
  final UserRatingResponseDTO? existing;
  final void Function(UserRatingResponseDTO)? onSaved;

  const RatingEditor({
    super.key,
    required this.restaurantId,
    this.existing,
    this.onSaved,
  });

  @override
  State<RatingEditor> createState() => _RatingEditorState();
}

class _RatingEditorState extends State<RatingEditor> {
  double _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _rating = widget.existing!.rating;
      _commentController.text = widget.existing!.comment ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final dto = UsuarioAvaliaRequestDTO(
        idRestaurante: widget.restaurantId,
        nota: _rating,
        comentario: _commentController.text.isEmpty
            ? null
            : _commentController.text.trim(),
      );

      debugPrint(
        '📝 [RatingEditor] DTO construído: restaurantId=${dto.idRestaurante}, nota=${dto.nota}, comentario=${dto.comentario}',
      );

      UserRatingResponseDTO response;
      if (widget.existing == null) {
        debugPrint('📝 [RatingEditor] Criando nova avaliação...');
        response = await RatingService.avaliarRestaurante(dto);
      } else {
        debugPrint('📝 [RatingEditor] Atualizando avaliação existente...');
        response = await RatingService.atualizarAvaliacao(dto);
      }

      debugPrint('✅ [RatingEditor] Resposta recebida: $response');

      if (widget.onSaved != null) widget.onSaved!(response);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ [RatingEditor] Erro ao salvar: $e');
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      String userMessage = msg;
      if (msg.contains('No static resource') ||
          msg.contains('Request method')) {
        userMessage =
            'Erro no servidor: endpoint de avaliações indisponível ou método HTTP não suportado. Verifique o backend.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildStar(int index) {
    final selected = index < _rating;
    return GestureDetector(
      onTap: () => setState(() => _rating = index + 1.0),
      child: Icon(
        selected ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Avaliar Restaurante',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Como foi sua experiência?'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (i) => _buildStar(i)),
            ),
            const SizedBox(height: 12),
            const Text('Seu Comentário'),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Conte-nos sobre sua experiência no restaurante...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 157, 0, 255),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enviar Avaliação'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
