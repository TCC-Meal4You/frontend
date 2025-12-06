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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
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
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _isDeleting
                    ? Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: _handleDelete,
                          iconSize: 22,
                        ),
                      ),
              ],
            ),
            if (widget.ingrediente.restricoes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.ingrediente.restricoes
                    .map((restricao) => RestricaoChip(restricao: restricao))
                    .toList(),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(
                    'Sem restrições alimentares',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
