import 'package:flutter/material.dart';
import 'package:meal4you_app/models/ingredient_response_dto.dart';
import 'package:meal4you_app/widgets/manage_ingredients/restricao_chip.dart';

class IngredienteCard extends StatefulWidget {
  final IngredientResponseDTO ingrediente;
  final Future<bool> Function(int, String, VoidCallback) onDelete;

  const IngredienteCard({
    super.key,
    required this.ingrediente,
    required this.onDelete,
  });

  @override
  State<IngredienteCard> createState() => _IngredienteCardState();
}

class _IngredienteCardState extends State<IngredienteCard> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    try {
      final success = await widget.onDelete(
        widget.ingrediente.idIngrediente,
        widget.ingrediente.nome,
        () {
          if (mounted) {
            setState(() => _isDeleting = true);
          }
        },
      );

      if (!success && mounted) {
        setState(() => _isDeleting = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.ingrediente.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _isDeleting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _handleDelete,
                      ),
              ],
            ),
            if (widget.ingrediente.restricoes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.ingrediente.restricoes
                    .map((restricao) => RestricaoChip(restricao: restricao))
                    .toList(),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Nenhuma restrição alimentar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
