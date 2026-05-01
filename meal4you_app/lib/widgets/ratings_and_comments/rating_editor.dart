import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:meal4you_app/models/user_rating_request_dto.dart';
import 'package:meal4you_app/models/user_rating_response_dto.dart';
import 'package:meal4you_app/services/rating/rating_service.dart';

class RatingEditor extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;
  final UserRatingResponseDTO? existing;
  final void Function(UserRatingResponseDTO)? onSaved;

  const RatingEditor({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
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

  String _getRatingLabel() {
    final labels = ['Muito ruim', 'Ruim', 'Regular', 'Muito bom', 'Excelente'];
    return labels[_rating.toInt() - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header com close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Avaliar Restaurante',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subtitle com nome do restaurante
              Text(
                'Como foi sua experiência no ${widget.restaurantName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // Seção: Sua Avaliação
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Sua Avaliação',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Estrelas
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => _buildStar(i)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getRatingLabel(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Seção: Seu Comentário
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Seu Comentário',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Campo de texto com contador
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Conte-nos sobre sua experiência no restaurante...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 157, 0, 255),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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
                          : const Text(
                              'Enviar Avaliação',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
